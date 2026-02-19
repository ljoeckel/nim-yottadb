import std/[strutils, strformat, streams]
import ydbtypes
import libydb

# Constants for buffer sizes used throughout YottaDB API calls
const
  BUFFER_GLOBAL_SIZE = 256
  BUFFER_IDX_SIZE = 64
  INCRBUF_SIZE = 32
  EMPTY_STRING = ""
  YDB_ERR_TIMEOUT_MSG ="YDB_ERR_TPTIMEOUT raised by db engine"
  YDB_TP_RESTART_MSG = "YDB_TP_RESTART requested by db engine"
  YDB_TP_ROLLBACK_MSG = "YDB_TP_ROLLBACK requested by db engine"


# create a seq that hold the highest possible key
var LAST_INDEX:seq[string]
for i in 0..<31:
  LAST_INDEX.add(repeat(EMPTY_STRING & '\xff', 10))


# Thread-local buffers to avoid re-allocating buffers on every call and keep state per-thread.
var
  buf_initialized {.threadvar.}: bool
  ERRMSG {.threadvar.}: ydb_buffer_t
  DATABUF {.threadvar.}: ydb_buffer_t
  INCRBUF {.threadvar.}: ydb_buffer_t
  GLOBAL {.threadvar.}: ydb_buffer_t
  IDXARR {.threadvar.}: array[0..YDB_MAX_SUBS, ydb_buffer_t]
  NAMES {.threadvar.}: array[0..YDB_MAX_NAMES-1, ydb_buffer_t] # for delete_excl
  rc {.threadvar.}: int


# Register buffer cleanup at process exit (atexit hook).
# Ensures allocated memory is released properly.
{.push header: "<stdlib.h>".}
proc atexit(f: proc() {.noconv.}) {.importc.}
{.pop.}


# -----------------------------------
# Buffer allocation and management
# -----------------------------------
proc allocCString*(s: string): cstring =
  ## Allocate a new C-string (null-terminated) from a Nim string.
  let buf = cast[ptr UncheckedArray[char]](alloc(s.len + 1))
  for i in 0..<s.len:
    buf[i] = s[i]
  result = cast[cstring](buf)

proc deallocBuffer(buffer: ydb_buffer_t) =
  ## Free a single ydb_buffer_t if allocated  
  if buffer.buf_addr != nil:
    dealloc(buffer.buf_addr)

# Overloads to free collections of ydb_buffer_t
proc deallocBuffer(bufferArr: openArray[ydb_buffer_t]) =
  for i in 0..<len(bufferArr):
    deallocBuffer(bufferArr[i])

proc deallocBuffer(bufferSeq: seq[ydb_buffer_t]) =
  for buf in bufferSeq:
    deallocBuffer(buf)

proc deallocBuffer(bufferSeq: seq[seq[ydb_buffer_t]]) =
  for buf in bufferSeq:
    deallocBuffer(buf)

func zeroBuffer(size: int): string =
  ## Returns a string of `size` filled with NUL ('\0')
  '\0'.repeat(size) 


# ------------
# YdbBuffer 
# ------------
proc stringToYdbBuffer(name: string): ydb_buffer_t =
  ## Create a new ydb_buffer_t initialized from a Nim string
  result = ydb_buffer_t()
  result.len_alloc = name.len.uint32
  result.len_used = name.len.uint32
  result.buf_addr = allocCString(name)

proc setYdbBuffer(buffer: var ydb_buffer_t, name: string) =
  ## Assign a string value to an existing ydb_buffer_t
  buffer.len_used = name.len.uint32
  for i in 0..<name.len:
    buffer.buf_addr[i] = name[i]

proc setYdbBuffer(buffer: var openArray[ydb_buffer_t], names: seq[string]) =
  ## Assign multiple string values to an array of ydb_buffer_t
  for idx in 0..<names.len:
    setYdbBuffer(buffer[idx], names[idx])
  for idx in names.len..<buffer.len:
    setYdbBuffer(buffer[idx], EMPTY_STRING)

proc setIdxArr(arr: var array[0..31, ydb_buffer_t], keys: seq[string]) =
  # Populate a fixed-size buffer array with keys (subscripts)
  for idx in 0..<keys.len:
    setYdbBuffer(arr[idx], keys[idx])
  # clear to the end   
  for idx in keys.len..<arr.len:
    arr[idx].len_used = 0.uint32

# ----------------------------------
# Buffer initialization & cleanup
# ----------------------------------
proc check() =
  ## Ensure buffers are allocated before first use.
  if not buf_initialized:
    ERRMSG = stringToYdbBuffer(zeroBuffer(YDB_MAX_ERRORMSG))
    DATABUF = stringToYdbBuffer(zeroBuffer(YDB_MAX_BUF_SIZE))
    INCRBUF = stringToYdbBuffer(zeroBuffer(INCRBUF_SIZE))    
    GLOBAL = stringToYdbBuffer(zeroBuffer(BUFFER_GLOBAL_SIZE))
    for idx in 0..<IDXARR.len:
      IDXARR[idx] = stringToYdbBuffer(zeroBuffer(BUFFER_IDX_SIZE))
    for idx in 0..<YDB_MAX_NAMES:
      NAMES[idx] = stringToYdbBuffer(zeroBuffer(BUFFER_IDX_SIZE))
    buf_initialized = true

proc cleanupBuffers() {.noconv} =
  # Free all thread-local buffers at exit
  deallocBuffer(ERRMSG)
  deallocBuffer(DATABUF)
  deallocBuffer(INCRBUF)
  deallocBuffer(GLOBAL)
  deallocBuffer(IDXARR)
  deallocBuffer(NAMES)

# Register cleanup to run automatically at process exit
atexit(cleanupBuffers)

# ----------------------------------------------------------
# YottaDB API Wrappers (safe Nim procs around C functions)
# ----------------------------------------------------------
proc ydbMessage_db*(status: int, tptoken: uint64 = 0): string =
  ## Return error message text for given status code
  if status == YDB_OK: return
  if not buf_initialized: check()
  when compileOption("threads"):
    rc = ydb_message_t(tptoken, ERRMSG.addr, status.cint, ERRMSG.addr)
  else:
    rc = ydb_message(status.cint, ERRMSG.addr)

  if rc == YDB_OK:
    return fmt"{status}, " & strip($ERRMSG.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc checkRC(tptoken: uint64 = 0) =
  case rc
  of YDB_OK, YDB_ERR_NODEEND, YDB_ERR_GVUNDEF:
    discard
  of YDB_TP_RESTART:
    raise newException(TpRestart, YDB_TP_RESTART_MSG)
  of YDB_ERR_TPTIMEOUT:
    raise newException(TpRestart, YDB_ERR_TIMEOUT_MSG)
  of YDB_TP_ROLLBACK:
    raise newException(TpRollback, YDB_TP_ROLLBACK_MSG)
  elif rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}")
  else:
    discard


proc ydb_tp_start*(myTxn: ydb_tpfnptr_t, param: string, transid:string): int =
  ## Start a single-threaded transaction
  if not buf_initialized: check()
  result = ydb_tp_s(myTxn, cast[pointer](param.cstring), transid, 0, GLOBAL.addr)
  checkRC(0)

proc ydb_tp_start*(myTxn: ydb_tpfnptr_t, param: int, transid:string): int =
  ## Start a single-threaded transaction
  if not buf_initialized: check()
  result = ydb_tp_s(myTxn, cast[pointer](param.cint), transid, 0, GLOBAL.addr)
  checkRC(0)


proc ydb_tp2_start*(myTxn: YDB_tp2fnptr_t, param:string, transid:string): int =
  ## Start a multi-threaded transaction
  if not buf_initialized: check()
  result = ydb_tp_st(0.uint64, ERRMSG.addr, cast[ydb_tp2fnptr_t](myTxn), cast[pointer](param.cstring), transid, 0, GLOBAL.addr)
  checkRC()

proc ydb_tp2_start*(myTxn: YDB_tp2fnptr_t, param:int, transid:string): int =
  ## Start a multi-threaded transaction
  if not buf_initialized: check()
  result = ydb_tp_st(0.uint64, ERRMSG.addr, cast[ydb_tp2fnptr_t](myTxn), cast[pointer](param.cint), transid, 0, GLOBAL.addr)
  checkRC()


proc ydb_set_db*(name: string, keys: Subscripts, value: string, tptoken: uint64) =
  ## Store a value into a local or global node
  if not buf_initialized: check()
  setIdxArr(IDXARR, keys)
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF, value)
  when compileOption("threads"):
    rc = ydb_set_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_set_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)
  checkRC(tptoken)

proc ydb_set_binary_db*(name: string, keys: Subscripts, value: string, tptoken: uint64) =
  if value.len <= YDB_MAX_BUF_SIZE:
    ydb_set_db(name, keys, value, tptoken)
  else:
    var idx = 0
    var endpos = 0
    for i in 0 .. value.len div YDB_MAX_BUF_SIZE:
      endpos += YDB_MAX_BUF_SIZE - (if i == 0: 1 else: 0)
      if endpos >= value.len: 
        endpos = value.len-1
      if idx >= endpos: break
      var subs:Subscripts = keys
      subs.add("___$" & fmt"{i:08}" & "$___")
      ydb_set_db(name, subs, value[idx .. endpos], tptoken)
      idx = endpos + 1


proc ydb_data_db*(name: string, keys: Subscripts, tptoken: uint64): int =
  ## Check existence/type of a global node
  ## Return codes: 0 = no Data, 1 = Data, 10 = child nodes, 11 = both
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)
  var value: cuint = 0

  when compileOption("threads"):
    rc = ydb_data_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, value.addr)
  else:
    rc = ydb_data_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, value.addr)

  checkRC(tptoken)
  return value.int # 0,1,10,11


# --- Delete node/tree ---
proc ydb_delete(name: string, keys: Subscripts, deltype: uint, tptoken: uint64) =
  ## Internal helper to delete either a node or a subtree
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_delete_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, cast[cint](deltype))
  else:
    rc = ydb_delete_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, deltype.cint)
  
  checkRC(tptoken)

proc ydb_delete_node_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Delete a single node
  ydb_delete(name, keys, YDB_DEL_NODE, tptoken)

proc ydb_delete_tree_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Delete a node and its subtree  
  ydb_delete(name, keys, YDB_DEL_TREE, tptoken)


proc ydb_delete_excl_db*(names: seq[string], tptoken: uint64) =
  ## Delete all locals except the specified names  
  if not buf_initialized: check()
  setYdbBuffer(NAMES, names)

  when compileOption("threads"):
    rc = ydb_delete_excl_st(tptoken, ERRMSG.addr, names.len.cint, NAMES[0].addr)
  else:
    rc = ydb_delete_excl_s(names.len.cint, NAMES[0].addr)

  checkRC(tptoken)


proc ydb_increment_db*(name: string, keys: Subscripts, Increment: int, tptoken: uint64): int =
  ## Increment a node value and return new value  
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF, $Increment)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_incr_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr, INCRBUF.addr)
  else:
    rc = ydb_incr_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr, INCRBUF.addr)

  checkRC(tptoken)

  INCRBUF.buf_addr[INCRBUF.len_used] = '\0' # null terminate
  let buf = $INCRBUF.buf_addr
  try:
    result = parseInt(buf)
  except:
    raise newException(YdbError, "Illegal Number. Tried to parseInt(" & buf & ")")


# --- Node traversal (next/previous) ---
proc node_traverse(direction: Direction, name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to the next/previous node and return subscripts  
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)

  var subs: Subscripts
  if direction == Direction.Previous and keys.len == 0:
    subs = LAST_INDEX
  else:
    subs = keys
  setIdxArr(IDXARR, subs)
  var ret_subs_used: cint = YDB_MAX_SUBS

  when compileOption("threads"):
    if direction == Direction.Next:
      rc = ydb_node_next_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs.len.cint, IDXARR[0].addr, ret_subs_used.addr, IDXARR[0].addr)
    else:
      rc = ydb_node_previous_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs.len.cint, IDXARR[0].addr, ret_subs_used.addr, IDXARR[0].addr)
  else:
    if direction == Direction.Next:
      rc = ydb_node_next_s(GLOBAL.addr, subs.len.cint, IDXARR[0].addr, ret_subs_used.addr, IDXARR[0].addr)
    else:
      rc = ydb_node_previous_s(GLOBAL.addr, subs.len.cint, IDXARR[0].addr, ret_subs_used.addr, IDXARR[0].addr)


  # construct the return key sequence
  if rc == YDB_OK:
    var sbscr:seq[string]
    for i in 0..<ret_subs_used:
      let len_used = IDXARR[i].len_used
      if len_used > 0:
        IDXARR[i].buf_addr[len_used] = '\0' # null terminate
        sbscr.add($IDXARR[i].buf_addr)
    if sbscr.len == 0: rc = YDB_ERR_NODEEND
    return (rc, sbscr)
  elif rc == YDB_ERR_NODEEND:
    return (rc.int, @[])
  else:
    checkRC(tptoken)

proc ydb_node_next_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to next node  
  node_traverse(Direction.Next, name, keys, tptoken)

proc ydb_node_previous_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to next node
  node_traverse(Direction.Previous, name, keys, tptoken)


# --- Subscript traversal (next/previous) ---
proc subscript_traverse(direction: Direction, name: string, keys: Subscripts, tptoken: uint64): string =
  ## Traverse subscripts at current level  
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  var subs: Subscripts
  if keys.len == 0:
    subs = @[EMPTY_STRING] # special case for empty subscript
  else:
    subs = keys
  setIdxArr(IDXARR, subs)

  when compileOption("threads"):
    if direction == Direction.Next:
      rc = ydb_subscript_next_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs.len.cint, IDXARR[0].addr,  DATABUF.addr)
    else:
      rc = ydb_subscript_previous_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs.len.cint, IDXARR[0].addr,  DATABUF.addr)    

  else:
    if direction == Direction.Next:
      rc = ydb_subscript_next_s(GLOBAL.addr, subs.len.cint, IDXARR[0].addr,  DATABUF.addr)
    else:
      rc = ydb_subscript_previous_s(GLOBAL.addr, subs.len.cint, IDXARR[0].addr,  DATABUF.addr)    

  if rc == YDB_OK:
    DATABUF.buf_addr[DATABUF.len_used] = '\0' # null terminate
    result = $DATABUF.buf_addr
  elif rc == YDB_ERR_NODEEND:
    result = EMPTY_STRING
  else:
    checkRC(tptoken)


proc ydb_subscript_next_db*(name: string, keys: Subscripts, tptoken: uint64): string =
  ## Traverse to next subscript  
  subscript_traverse(Direction.Next, name, keys, tptoken)

proc ydb_subscript_previous_db*(name: string, keys: Subscripts, tptoken: uint64): string =
  ## Traverse to previous subscript  
  subscript_traverse(Direction.Previous, name, keys, tptoken)


proc ydb_get_db*(name: string, keys: Subscripts = @[], tptoken: uint64, binary: bool = false): string =
  ## Retrieve a value from a local or global node
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_get_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_get_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)

  if rc == YDB_OK:
    if binary:
      result = newString(DATABUF.len_used)
      for idx in 0..<DATABUF.len_used:
        result[idx] = DATABUF.buf_addr[idx].char
    else:
      if DATABUF.len_used >= YDB_MAX_BUF_SIZE:
        raise newException(YdbError, "Record too long. Use \'.binary\' postfix" & " name:" & name & " keys:" & $keys)  
      DATABUF.buf_addr[DATABUF.len_used] = '\0'
      return $DATABUF.buf_addr
  elif rc == YDB_ERR_GVUNDEF:
    return EMPTY_STRING
  else:
    checkRC(tptoken)

proc ydb_getbinary_db*(name: string, keys: Subscripts = @[], tptoken: uint64): string =
  var subs = keys
  if keys.len > 0 and keys.len < 30: # willkürlich festgelegt TODO: Need length calculation of subs
    subs.add("___$00000000$___") # marker for first huge block
    if ydb_data_db(name, subs, tptoken) >= 1:
      var sb = newStringStream()
      rc = YDB_OK
      while rc == YDB_OK:
        if subs[^1].startsWith("___$0"):
          let val = ydb_get_db(name, subs, tptoken, true)
          sb.write(val)
        subs[^1] = ydb_subscript_next_db(name, subs, tptoken)
      sb.setPosition(0)
      return sb.readAll()
    else:
      return ydb_get_db(name, keys, tptoken, true)  
  else:
    return ydb_get_db(name, keys, tptoken, true)


# --- Locks ---
proc ydb_lock_incr_db*(timeout_nsec: int, name: string, keys: Subscripts, tptoken: uint64) =
  ## Increment Lock for variable
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  var subslen: cint
  if keys.len == 1 and IDXARR[0].len_used == 0:
    subslen = 0
  else:
    subslen = keys.len.cint

  when compileOption("threads"):
    rc = ydb_lock_incr_st(tptoken, ERRMSG.addr, timeout_nsec.culonglong, GLOBAL.addr, subslen, IDXARR[0].addr)
  else:
    rc = ydb_lock_incr_s(timeout_nsec.culonglong, GLOBAL.addr, subslen, IDXARR[0].addr)

  if rc == YDB_LOCK_TIMEOUT:
    raise newException(YdbError, fmt"YDB_LOCK_TIMEOUT while setting: {keys}")
  else:
    checkRC(tptoken)


proc ydb_lock_decr_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Increment Lock variable
  if not buf_initialized: check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  var subslen: cint
  if keys.len == 1 and IDXARR[0].len_used == 0:
    subslen = 0
  else:
    subslen = keys.len.cint

  when compileOption("threads"):
    rc = ydb_lock_decr_st(tptoken, ERRMSG.addr, GLOBAL.addr, subslen, IDXARR[0].addr)
  else:
    rc = ydb_lock_decr_s(GLOBAL.addr, subslen, IDXARR[0].addr)

  checkRC(tptoken)


proc ydb_lock_db_variadic(numOfLocks: int, timeout: culonglong, names: seq[ydb_buffer_t], subs: seq[seq[ydb_buffer_t]], tptoken: uint64): cint =
  ## Pass all potential Lock parameters to the variadic c-function
  ## Setting the numOfLocks controls how many parameters are read by c-function
  if numOfLocks == 0:  # release all locks
    when compileOption("threads"):
      rc = ydb_lock_st(tptoken, ERRMSG.addr, timeout, 0.cint) 
    else:
      rc = ydb_lock_s(timeout, 0.cint)
  else:
    # Set subslen to 0 if we pass an empty subscript
    # g.e. Lock: ^gbl will be passed as seq["^gbl", ""]
    var subslen: array[35, cint]
    for i in 0..<35:
      if subs[i].len == 1 and subs[i][0].len_used == 0:  
        subslen[i] = 0
      else:
        subslen[i] = subs[i].len.cint

    when compileOption("threads"):
      rc = ydb_lock_st(tptoken, ERRMSG.addr, timeout, numOfLocks.cint, 
        addr names[0], subslen[0], addr subs[0][0],
        addr names[1], subslen[1], addr subs[1][0],
        addr names[2], subslen[2], addr subs[2][0],
        addr names[3], subslen[3], addr subs[3][0],
        addr names[4], subslen[4], addr subs[4][0],
        addr names[5], subslen[5], addr subs[5][0],
        addr names[6], subslen[6], addr subs[6][0],
        addr names[7], subslen[7], addr subs[7][0],
        addr names[8], subslen[8], addr subs[8][0],
        addr names[9], subslen[9], addr subs[9][0],
        addr names[10], subslen[10], addr subs[10][0],
        addr names[11], subslen[11], addr subs[11][0],
        addr names[12], subslen[12], addr subs[12][0],
        addr names[13], subslen[13], addr subs[13][0],
        addr names[14], subslen[14], addr subs[14][0],
        addr names[15], subslen[15], addr subs[15][0],
        addr names[16], subslen[16], addr subs[16][0],
        addr names[17], subslen[17], addr subs[17][0],
        addr names[18], subslen[18], addr subs[18][0],
        addr names[19], subslen[19], addr subs[19][0],
        addr names[20], subslen[20], addr subs[20][0],
        addr names[21], subslen[21], addr subs[21][0],
        addr names[22], subslen[22], addr subs[22][0],
        addr names[23], subslen[23], addr subs[23][0],
        addr names[24], subslen[24], addr subs[24][0],
        addr names[25], subslen[25], addr subs[25][0],
        addr names[26], subslen[26], addr subs[26][0],
        addr names[27], subslen[27], addr subs[27][0],
        addr names[28], subslen[28], addr subs[28][0],
        addr names[29], subslen[29], addr subs[29][0],
        addr names[30], subslen[30], addr subs[30][0],
        addr names[31], subslen[31], addr subs[31][0],
        addr names[32], subslen[32], addr subs[32][0],
        addr names[33], subslen[33], addr subs[33][0],
        addr names[34], subslen[34], addr subs[34][0]
        )
    else:
      rc = ydb_lock_s(timeout, numOfLocks.cint, 
        addr names[0], subslen[0], addr subs[0][0],
        addr names[1], subslen[1], addr subs[1][0],
        addr names[2], subslen[2], addr subs[2][0],
        addr names[3], subslen[3], addr subs[3][0],
        addr names[4], subslen[4], addr subs[4][0],
        addr names[5], subslen[5], addr subs[5][0],
        addr names[6], subslen[6], addr subs[6][0],
        addr names[7], subslen[7], addr subs[7][0],
        addr names[8], subslen[8], addr subs[8][0],
        addr names[9], subslen[9], addr subs[9][0],
        addr names[10], subslen[10], addr subs[10][0],
        addr names[11], subslen[11], addr subs[11][0],
        addr names[12], subslen[12], addr subs[12][0],
        addr names[13], subslen[13], addr subs[13][0],
        addr names[14], subslen[14], addr subs[14][0],
        addr names[15], subslen[15], addr subs[15][0],
        addr names[16], subslen[16], addr subs[16][0],
        addr names[17], subslen[17], addr subs[17][0],
        addr names[18], subslen[18], addr subs[18][0],
        addr names[19], subslen[19], addr subs[19][0],
        addr names[20], subslen[20], addr subs[20][0],
        addr names[21], subslen[21], addr subs[21][0],
        addr names[22], subslen[22], addr subs[22][0],
        addr names[23], subslen[23], addr subs[23][0],
        addr names[24], subslen[24], addr subs[24][0],
        addr names[25], subslen[25], addr subs[25][0],
        addr names[26], subslen[26], addr subs[26][0],
        addr names[27], subslen[27], addr subs[27][0],
        addr names[28], subslen[28], addr subs[28][0],
        addr names[29], subslen[29], addr subs[29][0],
        addr names[30], subslen[30], addr subs[30][0],
        addr names[31], subslen[31], addr subs[31][0],
        addr names[32], subslen[32], addr subs[32][0],
        addr names[33], subslen[33], addr subs[33][0],
        addr names[34], subslen[34], addr subs[34][0]
        )
  return rc.cint


proc ydb_lock_db*(timeout_nsec: int, keys: seq[Subscripts], tptoken: uint64) =
  ## Acquire Lock on a node(s) with timeout in nsec
  if keys.len > YDB_MAX_NAMES:
    raise newException(YdbError, fmt"Too many arguments. Only {YDB_MAX_NAMES} are allowed")    

  if not buf_initialized: check()

  var locknames: seq[ydb_buffer_t] = newSeq[ydb_buffer_t]()
  var locksubs: seq[seq[ydb_buffer_t]] = newSeq[newSeq[ydb_buffer_t]()]()
  defer:
    deallocBuffer(locknames)
    deallocBuffer(locksubs)

  for subskeys in keys:
    let varname = stringToYdbBuffer(subskeys[0])
    locknames.add(varname)
    var subs = newSeq[ydb_buffer_t]()
    for idx in 1..len(subskeys)-1:
      subs.add(stringToYdbBuffer(subskeys[idx]))
    locksubs.add(subs)
  for i in keys.len ..< 35:
    locknames.add(stringToYdbBuffer(EMPTY_STRING))
    var subs = newSeq[ydb_buffer_t]()
    subs.add(stringToYdbBuffer(EMPTY_STRING))
    locksubs.add(subs)

  let rc = ydb_lock_db_variadic(keys.len, cast[culonglong](timeout_nsec), locknames, locksubs, tptoken)  
  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, {keys})")
  elif rc == YDB_LOCK_TIMEOUT:
    raise newException(YdbError, fmt"YDB_LOCK_TIMEOUT while setting: {keys}")



# ----------- Call In Interface -------------

proc ydb_ci_db*(name: string, tptoken: uint64) =
  ## Call into a M routine (CI = call-in) with NO arguments, and NO return argument  
  ## Pass variables via local or global variables back and forth
  if not buf_initialized: check()

  let c_call_name = allocCstring(name)
  defer:
    dealloc(c_call_name)

  when compileOption("threads"):
    rc = ydb_ci_t(tptoken, ERRMSG.addr, c_call_name)
  else:
    rc = ydb_ci(c_call_name)

  checkRC(tptoken)


proc ydb_str2zwr_db*(name: string, tptoken: uint64): string =
  ## Convert binary string: "hello\9World" -> "hello"_$C(9)_"World"
  if not buf_initialized: check()
  let bufsize = min( (name.len.float * 2.5).int , YDB_MAX_BUF_SIZE)
  var ZWRBUF = stringToYdbBuffer(zeroBuffer(bufsize))
  setYdbBuffer(ZWRBUF, EMPTY_STRING)
  setYdbBuffer(DATABUF, name)

  when compileOption("threads"):
    rc = ydb_str2zwr_st(tptoken, ERRMSG.addr, DATABUF.addr, ZWRBUF.addr)
  else:
    rc = ydb_str2zwr_s(DATABUF.addr, ZWRBUF.addr)

  if rc == YDB_OK:
    ZWRBUF.buf_addr[ZWRBUF.len_used] = '\0'
    result = $ZWRBUF.buf_addr
    deallocBuffer(ZWRBUF)
  else:
    checkRC(tptoken)


proc ydb_zwr2str_db*(name: string, tptoken: uint64): string =
  ## Convert converted binary string: "hello"_$C(9)_"World" -> "hello\9World"
  if not buf_initialized: check()
  setYdbBuffer(DATABUF, name)
  when compileOption("threads"):
    rc = ydb_zwr2str_st(tptoken, ERRMSG.addr, DATABUF.addr, DATABUF.addr)
  else:
    rc = ydb_zwr2str_s(DATABUF.addr, DATABUF.addr)

  if rc == YDB_OK:
    DATABUF.buf_addr[DATABUF.len_used] = '\0'
    result = newString(DATABUF.len_used)
    for idx in 0..<DATABUF.len_used:
      result[idx] = DATABUF.buf_addr[idx].char
  else:
    checkRC(tptoken)

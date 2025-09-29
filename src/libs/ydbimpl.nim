import std/[strutils, strformat]
import ydbtypes
import libydb

# Constants for buffer sizes used throughout YottaDB API calls
const
  BUFFER_DATABUF_SIZE = 1024*1024
  BUFFER_GLOBAL_SIZE = 256
  BUFFER_IDX_SIZE = 64
  INCRBUF_SIZE = 32

# create a seq that hold the highest possible key
var LAST_INDEX:seq[string]
for i in 0..<31:
  LAST_INDEX.add(repeat("" & '\xff', 10))


# Thread-local buffers to avoid re-allocating buffers on every call and keep state per-thread.
var
  buf_initialized {.threadvar.}: bool
  ERRMSG {.threadvar.}: ydb_buffer_t
  DATABUF {.threadvar.}: ydb_buffer_t
  INCRBUF {.threadvar.}: ydb_buffer_t
  GLOBAL {.threadvar.}: ydb_buffer_t
  IDXARR {.threadvar.}: array[0..YDB_MAX_SUBS, ydb_buffer_t]
  NAMES {.threadvar.}: array[0..YDB_MAX_NAMES-1, ydb_buffer_t] # for delete_excl
  rc {.threadvar.}: cint

# Register buffer cleanup at process exit (atexit hook).
# Ensures allocated memory is released properly.
{.push header: "<stdlib.h>".}
proc atexit(f: proc() {.noconv.}) {.importc.}
{.pop.}


# ------------------------------------------------------------------------
# Utility functions for buffer allocation and management
# ------------------------------------------------------------------------

proc allocCString*(s: string): cstring =
  ## Allocate a new C-string (null-terminated) from a Nim string.
  let buf = cast[ptr UncheckedArray[char]](alloc(s.len + 1))
  if s.len > 0:
    copyMem(buf, s[0].addr, s.len)
  buf[s.len] = '\0'
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

proc zeroBuffer(size: int): string =
  ## Returns a string of `size` filled with NUL ('\0')
  '\0'.repeat(size) 


proc stringToYdbBuffer(name: string = "", len_used:int = -1): ydb_buffer_t =
  ## Create a new ydb_buffer_t initialized from a Nim string
  result = ydb_buffer_t()
  result.len_alloc = name.len.uint32
  if len_used != -1:
    result.len_used = len_used.uint32
  else:
    result.len_used = name.len.uint32
  
  result.buf_addr = allocCString(name)


proc setYdbBuffer(buffer: var ydb_buffer_t, name: string = "") =
  ## Assign a string value to an existing ydb_buffer_t
  if name.len > 0:
    buffer.len_used = name.len.uint32
    copyMem(buffer.buf_addr, name[0].addr, name.len)
  else:
    buffer.len_used = 0.uint32
  buffer.buf_addr[name.len] = '\0'


proc setYdbBuffer(buffer: var openArray[ydb_buffer_t], names: seq[string]) =
  ## Assign multiple string values to an array of ydb_buffer_t
  for idx in 0..<names.len:
    setYdbBuffer(buffer[idx], names[idx])
  for idx in names.len..<buffer.len:
    setYdbBuffer(buffer[idx], "")


proc setIdxArr(arr: var array[0..31, ydb_buffer_t], keys: seq[string] = @[]) =
  # Populate a fixed-size buffer array with keys (subscripts)
  for idx in 0..<keys.len:
    setYdbBuffer(arr[idx], keys[idx])
  # clear to the end   
  for idx in keys.len..<arr.len:
    arr[idx].len_used = 0.uint32
    arr[idx].buf_addr[0] = '\0'

# ------------------------------------------------------------------------
# Buffer initialization & cleanup
# ------------------------------------------------------------------------
proc check() =
  ## Ensure buffers are allocated before first use.
  if not buf_initialized:
    ERRMSG = stringToYdbBuffer(zeroBuffer(YDB_MAX_ERRORMSG))
    DATABUF = stringToYdbBuffer(zeroBuffer(BUFFER_DATABUF_SIZE))
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


# ------------------------------------------------------------------------
# YottaDB API Wrappers (safe Nim procs around C functions)
# ------------------------------------------------------------------------

proc ydb_tp_start*(myTxn: ydb_tpfnptr_t, param:string, transid:string): int =
  ## Start a single-threaded transaction
  check()
  setYdbBuffer(GLOBAL)

  result = ydb_tp_s(myTxn, cast[pointer](param.cstring), transid, 0, GLOBAL.addr)

proc ydb_tp2_start*(myTxn: YDB_tp2fnptr_t, param:string, transid:string): int =
  ## Start a multi-threaded transaction
  check()
  setYdbBuffer(GLOBAL)
  setYdbBuffer(ERRMSG)

  result = ydb_tp_st(0.uint64, ERRMSG.addr, cast[ydb_tp2fnptr_t](myTxn), cast[pointer](param.cstring), transid, 0, GLOBAL.addr)


proc ydbMessage_db*(status: cint, tptoken: uint64 = 0): string =
  ## Return error message text for given status code
  if status == YDB_OK: return
  
  check()
  setYdbBuffer(ERRMSG)

  when compileOption("threads"):
    rc = ydb_message_t(tptoken, ERRMSG.addr, status, ERRMSG.addr)
  else:
    rc = ydb_message(status, ERRMSG.addr)
  if rc == YDB_OK:
    return fmt"{status}, " & strip($ERRMSG.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc ydb_set_db*(name: string, keys: Subscripts, value: string, tptoken: uint64) =
  ## Store a value into a local or global node
  check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF, value)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_set_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_set_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)
  if rc < YDB_OK:
    raise newException(YdbError, ydbMessage_db(rc, tptoken) & " name:" & name & " keys:" & $keys & " value:" & $value)


proc ydb_get_db*(name: string, keys: Subscripts = @[], tptoken: uint64): string =
  ## Retrieve a value from a local or global node
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    setYdbBuffer(ERRMSG)
    setYdbBuffer(DATABUF)
    rc = ydb_get_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_get_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)

  if rc == YDB_OK:
    DATABUF.buf_addr[DATABUF.len_used] = '\0'
    result = $DATABUF.buf_addr
  else:
    raise newException(YdbError, ydbMessage_db(rc, tptoken) & " name:" & name & " keys:" & $keys)


proc ydb_get_binary_db*(name: string, keys: Subscripts = @[], tptoken: uint64): string =
  ## Retrieve a value from a local or global node
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    setYdbBuffer(ERRMSG)
    setYdbBuffer(DATABUF)
    rc = ydb_get_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_get_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr)

  if rc == YDB_OK:
    result = newString(DATABUF.len_used)
    for idx in 0..<DATABUF.len_used:
      result[idx] = DATABUF.buf_addr[idx].char
  else:
    raise newException(YdbError, ydbMessage_db(rc, tptoken) & " name:" & name & " keys:" & $keys)


proc ydb_data_db*(name: string, keys: Subscripts, tptoken: uint64): int =
  ## Check existence/type of a global node
  ## Return codes: 0 = no data, 1 = data, 10 = child nodes, 11 = both
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)
  var value: cuint = 0

  when compileOption("threads"):
    rc = ydb_data_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, value.addr)
  else:
    rc = ydb_data_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, value.addr)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, Global:{name}({keys})")
  else:
    return value.int # 0,1,10,11


# --- Delete node/tree ---
proc ydb_delete(name: string, keys: Subscripts, deltype: uint, tptoken: uint64) =
  ## Internal helper to delete either a node or a subtree
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_delete_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, cast[cint](deltype))
  else:
    rc = ydb_delete_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, deltype.cint)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, Global:{name}({keys})")

proc ydb_delete_node_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Delete a single node
  ydb_delete(name, keys, YDB_DEL_NODE, tptoken)

proc ydb_delete_tree_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Delete a node and its subtree  
  ydb_delete(name, keys, YDB_DEL_TREE, tptoken)


proc ydb_delete_excl_db*(names: seq[string], tptoken: uint64) =
  ## Delete all locals except the specified names  
  check()
  setYdbBuffer(NAMES, names)

  when compileOption("threads"):
    rc = ydb_delete_excl_st(tptoken, ERRMSG.addr, names.len.cint, NAMES[0].addr)
  else:
    rc = ydb_delete_excl_s(names.len.cint, NAMES[0].addr)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, names:{names}")


proc ydb_increment_db*(name: string, keys: Subscripts, increment: int, tptoken: uint64): int =
  ## Increment a node value and return new value  
  check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(INCRBUF)
  setYdbBuffer(DATABUF, $increment)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_incr_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr, INCRBUF.addr)
  else:
    rc = ydb_incr_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr, DATABUF.addr, INCRBUF.addr)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, Global:{name}({keys})")
  else:
      INCRBUF.buf_addr[INCRBUF.len_used] = '\0' # null terminate
      let buf = $INCRBUF.buf_addr
      try:
        result = parseInt(buf)
      except:
        raise newException(YdbError, "Illegal Number. Tried to parseInt(" & buf & ")")


# --- Node traversal (next/previous) ---
proc node_traverse(direction: Direction, name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to the next/previous node and return subscripts  
  check()
  setYdbBuffer(GLOBAL, name)

  var subs: Subscripts
  if direction == Direction.Previous and keys == @[] or keys == @[""]:
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
  
    return (rc.int, sbscr)
  else:
    return (rc.int, @[])

proc ydb_node_next_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to next node  
  node_traverse(Direction.Next, name, keys, tptoken)

proc ydb_node_previous_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to next node
  node_traverse(Direction.Previous, name, keys, tptoken)


# --- Subscript traversal (next/previous) ---
proc subscript_traverse(direction: Direction, name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse subscripts at current level  
  check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF)
  var subs: Subscripts
  if keys.len == 0:
    subs = @[""] # special case for empty subscript
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
    # update the key sequence as return value
    DATABUF.buf_addr[DATABUF.len_used] = '\0' # null terminate
    if subs.len == 0:
      subs.add($DATABUF.buf_addr)
    else:
      subs[^1] = $DATABUF.buf_addr
  else:
    subs = @[]

  return (rc.int, subs)

proc ydb_subscript_next_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to next subscript  
  subscript_traverse(Direction.Next, name, keys, tptoken)

proc ydb_subscript_previous_db*(name: string, keys: Subscripts, tptoken: uint64): (int, Subscripts) =
  ## Traverse to previous subscript  
  subscript_traverse(Direction.Previous, name, keys, tptoken)


# --- Locks ---
proc ydb_lock_incr_db*(timeout_nsec: culonglong, name: string, keys: Subscripts, tptoken: uint64) =
  ## Increment lock for variable
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_lock_incr_st(tptoken, ERRMSG.addr, timeout_nsec, GLOBAL.addr, keys.len.cint, IDXARR[0].addr)
  else:
    rc = ydb_lock_incr_s(timeout_nsec, GLOBAL.addr, keys.len.cint, IDXARR[0].addr)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, names:{keys}")


proc ydb_lock_decr_db*(name: string, keys: Subscripts, tptoken: uint64) =
  ## Increment lock variable
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(IDXARR, keys)

  when compileOption("threads"):
    rc = ydb_lock_decr_st(tptoken, ERRMSG.addr, GLOBAL.addr, keys.len.cint, IDXARR[0].addr)
  else:
    rc = ydb_lock_decr_s(GLOBAL.addr, keys.len.cint, IDXARR[0].addr)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, names:{keys}")


proc ydb_lock_db_variadic(numOfLocks: int, timeout: culonglong, names: seq[ydb_buffer_t], subs: seq[seq[ydb_buffer_t]], tptoken: uint64): cint =
  ## Pass all potential lock parameters to the variadic c-function
  ## Setting the numOfLocks controls how many parameters are read by c-function
  if numOfLocks == 0:  # release all locks
    when compileOption("threads"):
      rc = ydb_lock_st(tptoken, ERRMSG.addr, timeout, 0.cint) 
    else:
      rc = ydb_lock_s(timeout, 0.cint)
  else:
    when compileOption("threads"):
      rc = ydb_lock_st(tptoken, ERRMSG.addr, timeout, numOfLocks.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0],
        addr names[9], subs[9].len.cint, addr subs[9][0],
        addr names[10], subs[10].len.cint, addr subs[10][0],
        addr names[11], subs[11].len.cint, addr subs[11][0],
        addr names[12], subs[12].len.cint, addr subs[12][0],
        addr names[13], subs[13].len.cint, addr subs[13][0],
        addr names[14], subs[14].len.cint, addr subs[14][0],
        addr names[15], subs[15].len.cint, addr subs[15][0],
        addr names[16], subs[16].len.cint, addr subs[16][0],
        addr names[17], subs[17].len.cint, addr subs[17][0],
        addr names[18], subs[18].len.cint, addr subs[18][0],
        addr names[19], subs[19].len.cint, addr subs[19][0],
        addr names[20], subs[20].len.cint, addr subs[20][0],
        addr names[21], subs[21].len.cint, addr subs[21][0],
        addr names[22], subs[22].len.cint, addr subs[22][0],
        addr names[23], subs[23].len.cint, addr subs[23][0],
        addr names[24], subs[24].len.cint, addr subs[24][0],
        addr names[25], subs[25].len.cint, addr subs[25][0],
        addr names[26], subs[26].len.cint, addr subs[26][0],
        addr names[27], subs[27].len.cint, addr subs[27][0],
        addr names[28], subs[28].len.cint, addr subs[28][0],
        addr names[29], subs[29].len.cint, addr subs[29][0],
        addr names[30], subs[30].len.cint, addr subs[30][0],
        addr names[31], subs[31].len.cint, addr subs[31][0],
        addr names[32], subs[32].len.cint, addr subs[32][0],
        addr names[33], subs[33].len.cint, addr subs[33][0],
        addr names[34], subs[34].len.cint, addr subs[34][0]
        )
    else:
      rc = ydb_lock_s(timeout, numOfLocks.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0],
        addr names[9], subs[9].len.cint, addr subs[9][0],
        addr names[10], subs[10].len.cint, addr subs[10][0],
        addr names[11], subs[11].len.cint, addr subs[11][0],
        addr names[12], subs[12].len.cint, addr subs[12][0],
        addr names[13], subs[13].len.cint, addr subs[13][0],
        addr names[14], subs[14].len.cint, addr subs[14][0],
        addr names[15], subs[15].len.cint, addr subs[15][0],
        addr names[16], subs[16].len.cint, addr subs[16][0],
        addr names[17], subs[17].len.cint, addr subs[17][0],
        addr names[18], subs[18].len.cint, addr subs[18][0],
        addr names[19], subs[19].len.cint, addr subs[19][0],
        addr names[20], subs[20].len.cint, addr subs[20][0],
        addr names[21], subs[21].len.cint, addr subs[21][0],
        addr names[22], subs[22].len.cint, addr subs[22][0],
        addr names[23], subs[23].len.cint, addr subs[23][0],
        addr names[24], subs[24].len.cint, addr subs[24][0],
        addr names[25], subs[25].len.cint, addr subs[25][0],
        addr names[26], subs[26].len.cint, addr subs[26][0],
        addr names[27], subs[27].len.cint, addr subs[27][0],
        addr names[28], subs[28].len.cint, addr subs[28][0],
        addr names[29], subs[29].len.cint, addr subs[29][0],
        addr names[30], subs[30].len.cint, addr subs[30][0],
        addr names[31], subs[31].len.cint, addr subs[31][0],
        addr names[32], subs[32].len.cint, addr subs[32][0],
        addr names[33], subs[33].len.cint, addr subs[33][0],
        addr names[34], subs[34].len.cint, addr subs[34][0]
        )
  return rc


proc ydb_lock_db*(timeout_nsec: culonglong, keys: seq[Subscripts], tptoken: uint64) =
  ## Acquire lock on a node(s) with timeout in nsec
  if keys.len > YDB_MAX_NAMES:
    raise newException(YdbError, fmt"Too many arguments. Only {YDB_MAX_NAMES} are allowed")    

  check()

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
    locknames.add(stringToYdbBuffer())
    var subs = newSeq[ydb_buffer_t]()
    subs.add(stringToYdbBuffer())
    locksubs.add(subs)
 
  let rc = ydb_lock_db_variadic(keys.len, timeout_nsec, locknames, locksubs, tptoken)  
  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc, tptoken)}, {keys})")


# ----------- Call In Interface -------------

proc ydb_ci_db*(name: string, tptoken: uint64) =
  ## Call into a M routine (CI = call-in) with NO arguments, and NO return argument  
  ## Pass variables via local or global variables back and forth
  check()

  let c_call_name = allocCstring(name)
  defer:
    dealloc(c_call_name)

  when compileOption("threads"):
    rc = ydb_ci_t(tptoken, ERRMSG.addr, c_call_name)
  else:
    rc = ydb_ci(c_call_name)

  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage_db(rc)}") 


proc ydb_str2zwr_db*(name: string, tptoken: uint64): string =
  ## Convert binary string: "hello\9World" -> "hello"_$C(9)_"World"
  check()
  let bufsize = min( (name.len.float * 2.5).int , BUFFER_DATABUF_SIZE)
  var ZWRBUF = stringToYdbBuffer(zeroBuffer(bufsize))
  setYdbBuffer(ZWRBUF)
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
    raise newException(YdbError, ydbMessage_db(rc, tptoken))


proc ydb_zwr2str_db*(name: string, tptoken: uint64): string =
  ## Convert converted binary string: "hello"_$C(9)_"World" -> "hello\9World"
  check()
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
    raise newException(YdbError, ydbMessage_db(rc, tptoken))



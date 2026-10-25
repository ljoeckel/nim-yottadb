import std/[strutils, strformat]
import std/atomics
import ydbtypes
import libydb
import ydberror
import libs/parsers

# Constants for buffer sizes used throughout YottaDB API calls
const
  BUFFER_GLOBAL_SIZE = 256
  BUFFER_IDX_SIZE = 256
  INCRBUF_SIZE = 32
  EMPTY_STRING = ""
  YDB_ERR_TIMEOUT_MSG ="YDB_ERR_TPTIMEOUT raised by db engine"
  YDB_TP_RESTART_MSG = "YDB_TP_RESTART requested by db engine"
  YDB_TP_ROLLBACK_MSG = "YDB_TP_ROLLBACK requested by db engine"


# Thread-local buffers to avoid re-allocating buffers on every call and keep state per-thread.
var
  buf_initialized {.threadvar.}: bool
  ERRMSG {.threadvar.}: ydb_buffer_t
  DATABUF {.threadvar.}: ydb_buffer_t
  INCRBUF {.threadvar.}: ydb_buffer_t
  GLOBAL {.threadvar.}: ydb_buffer_t
  NAMES {.threadvar.}: array[0..YDB_MAX_NAMES-1, ydb_buffer_t] # for delete_excl
  rc {.threadvar.}: int

var stopRequested: Atomic[bool]


# Register buffer cleanup at process exit (atexit hook).
# Ensures allocated memory is released properly.
{.push header: "<stdlib.h>".}
proc atexit(f: proc() {.noconv.}) {.importc.}
{.pop.}


# -----------------------------------
# Buffer allocation and management
# -----------------------------------
template allocCString(s: string): cstring =
  ## Allocate a new C-string (null-terminated) from a Nim string.
  let buf = cast[ptr UncheckedArray[char]](alloc(s.len + 1))
  if s.len > 0:
    copyMem(addr(buf[0]), s[0].addr, s.len)    
  cast[cstring](buf)

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
  ydb_buffer_t(len_alloc: name.len.uint32, len_used: name.len.uint32, buf_addr: allocCString(name))

proc setYdbBuffer(buffer: var ydb_buffer_t, name: string) =
  ## Assign a string value to an existing ydb_buffer_t. If the value does not fit
  ## the buffer's capacity, the buffer is replaced by a larger one (so the common
  ## case stays allocation-free while long names/subscripts no longer overflow).
  if name.len <= int(buffer.len_alloc):
    buffer.len_used = name.len.uint32
    if buffer.len_used > 0:
      copyMem(addr(buffer.buf_addr[0]), name[0].addr, name.len)
  else:
    deallocBuffer(buffer)
    buffer = stringToYdbBuffer(name)
    
template setYdbBuffer(buffer: var openArray[ydb_buffer_t], names: seq[string]) =
  ## Assign multiple string values to an array of ydb_buffer_t
  for idx in 0..<names.len:
    setYdbBuffer(buffer[idx], names[idx])


proc cleanupBuffers() {.noconv} =
  # Free all thread-local buffers at exit
  deallocBuffer(ERRMSG)
  deallocBuffer(DATABUF)
  deallocBuffer(INCRBUF)
  deallocBuffer(GLOBAL)
  deallocBuffer(NAMES)


proc handleCtrlC() {.noconv.} =
    stopRequested.store(true)


# ----------------------------------
# Buffer initialization & cleanup
# ----------------------------------
proc initBuffers() =
    ## Ensure buffers are allocated before first use.
    ERRMSG = stringToYdbBuffer(zeroBuffer(YDB_MAX_ERRORMSG))
    DATABUF = stringToYdbBuffer(zeroBuffer(YDB_MAX_BUF_SIZE))
    INCRBUF = stringToYdbBuffer(zeroBuffer(INCRBUF_SIZE))    
    GLOBAL = stringToYdbBuffer(zeroBuffer(BUFFER_GLOBAL_SIZE))
    for idx in 0..<YDB_MAX_NAMES:
        NAMES[idx] = stringToYdbBuffer(zeroBuffer(BUFFER_IDX_SIZE))

    # Register cleanup to run automatically at process exit
    atexit(cleanupBuffers)
    # Register Control-C hook
    setControlCHook(handleCtrlC)

    buf_initialized = true


template checkBuffers() =
    if not buf_initialized:
        initBuffers()

# ----------------------------------------------------------
# YottaDB API Wrappers (safe Nim procs around C functions)
# ----------------------------------------------------------
proc ydbMessage*(status: int, ): string =
    if stopRequested.load():
        return fmt"{status} : {getYdbError(status)}"
    
    if status == YDB_OK: return

    ## Return error message text for given status code
    checkBuffers()
    when compileOption("threads"):
      rc = ydb_message_t(TPTOKEN, ERRMSG.addr, status.cint, ERRMSG.addr)
    else:
        rc = ydb_message(status.cint, ERRMSG.addr)

    if rc == YDB_OK:
        return fmt"{status}, {strip($ERRMSG.buf_addr)}"
    else:
        return fmt"{status} : {getYdbError(status)}"


template checkRC() =
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
    raise newException(YdbError, ydbMessage(rc))
  else:
    discard


proc ydb_tp_start(myTxn: ydb_tpfnptr_t, param: string, transid:string): int =
  ## Start a single-threaded transaction
  checkBuffers()
  result = ydb_tp_s(myTxn, cast[pointer](param.cstring), transid, 0, GLOBAL.addr)
  checkRC()

proc ydb_tp_start(myTxn: ydb_tpfnptr_t, param: int, transid:string): int =
  ## Start a single-threaded transaction
  checkBuffers()
  result = ydb_tp_s(myTxn, cast[pointer](param.cint), transid, 0, GLOBAL.addr)
  checkRC()

proc ydb_tp2_start(myTxn: YDB_tp2fnptr_t, param:string, transid:string): int =
  ## Start a multi-threaded transaction
  checkBuffers()
  result = ydb_tp_st(0.uint64, ERRMSG.addr, cast[ydb_tp2fnptr_t](myTxn), cast[pointer](param.cstring), transid, 0, GLOBAL.addr)
  checkRC()

proc ydb_tp2_start(myTxn: YDB_tp2fnptr_t, param:int, transid:string): int =
  ## Start a multi-threaded transaction
  checkBuffers()
  result = ydb_tp_st(0.uint64, ERRMSG.addr, cast[ydb_tp2fnptr_t](myTxn), cast[pointer](param.cint), transid, 0, GLOBAL.addr)
  checkRC()

proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string = "", transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)

proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: int, transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)

proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: string = "", transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)

proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: int, transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)


proc ydb_delete_excl*(names: seq[string] = @[]) =
  ## Delete all locals except the specified names  
  checkBuffers()
  setYdbBuffer(NAMES, names)
  
  when compileOption("threads"):
    rc = ydb_delete_excl_st(TPTOKEN, ERRMSG.addr, names.len.cint, NAMES[0].addr)
  else:
    rc = ydb_delete_excl_s(names.len.cint, NAMES[0].addr)

  checkRC()


# --- Locks ---
proc ydb_lock_db_variadic(numOfLocks: int, timeout: culonglong, names: seq[ydb_buffer_t], subs: seq[seq[ydb_buffer_t]]): cint =
  ## Pass all potential Lock parameters to the variadic c-function
  ## Setting the numOfLocks controls how many parameters are read by c-function
  if numOfLocks == 0:  # release all locks
    when compileOption("threads"):
      rc = ydb_lock_st(TPTOKEN, ERRMSG.addr, timeout, 0.cint) 
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
      rc = ydb_lock_st(TPTOKEN, ERRMSG.addr, timeout, numOfLocks.cint, 
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


proc ydb_lock*(timeout_nsec: int, keys: seq[Subscripts]) =
  ## Acquire Lock on a node(s) with timeout in nsec
  if keys.len > YDB_MAX_NAMES:
    raise newException(YdbError, fmt"Too many arguments. Only {YDB_MAX_NAMES} are allowed")    

  checkBuffers()

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

  let rc = ydb_lock_db_variadic(keys.len, cast[culonglong](timeout_nsec), locknames, locksubs)  
  if rc < YDB_OK:
    raise newException(YdbError, fmt"{ydbMessage(rc)}, {keys})")
  elif rc == YDB_LOCK_TIMEOUT:
    raise newException(YdbError, fmt"YDB_LOCK_TIMEOUT while setting: {keys}")



# ----------- Call In Interface -------------

proc ydb_ci*(name: string) =
  ## Call into a M routine (CI = call-in) with NO arguments, and NO return argument  
  ## Pass variables via local or global variables back and forth
  checkBuffers()

  let c_call_name = allocCstring(name)
  defer:
    dealloc(c_call_name)

  when compileOption("threads"):
    rc = ydb_ci_t(TPTOKEN, ERRMSG.addr, c_call_name)
  else:
    rc = ydb_ci(c_call_name)

  checkRC()


proc str2zwr*(name: string): string =
  ## Convert binary string: "hello\9World" -> "hello"_$C(9)_"World"
  checkBuffers()
  let bufsize = min( (name.len.float * 2.5).int , YDB_MAX_BUF_SIZE)
  var ZWRBUF = stringToYdbBuffer(zeroBuffer(bufsize))
  setYdbBuffer(ZWRBUF, EMPTY_STRING)
  setYdbBuffer(DATABUF, name)

  when compileOption("threads"):
    rc = ydb_str2zwr_st(TPTOKEN, ERRMSG.addr, DATABUF.addr, ZWRBUF.addr)
  else:
    rc = ydb_str2zwr_s(DATABUF.addr, ZWRBUF.addr)

  if rc == YDB_OK:
    ZWRBUF.buf_addr[ZWRBUF.len_used] = '\0'
    result = $ZWRBUF.buf_addr
    deallocBuffer(ZWRBUF)
  else:
    checkRC()


proc zwr2str*(name: string): string =
  ## Convert converted binary string: "hello"_$C(9)_"World" -> "hello\9World"
  checkBuffers()
  setYdbBuffer(DATABUF, name)
  when compileOption("threads"):
    rc = ydb_zwr2str_st(TPTOKEN, ERRMSG.addr, DATABUF.addr, DATABUF.addr)
  else:
    rc = ydb_zwr2str_s(DATABUF.addr, DATABUF.addr)

  if rc == YDB_OK:
    DATABUF.buf_addr[DATABUF.len_used] = '\0'
    result = newString(DATABUF.len_used)
    for idx in 0..<DATABUF.len_used:
      result[idx] = DATABUF.buf_addr[idx].char
  else:
    checkRC()


# ----------------------------------------------------------
# YdbKey API (allocation-free variant)
# ----------------------------------------------------------
# A `YdbKey` owns its name and subscript buffers, so these overloads do not
# allocate for the keys themselves. `ydb_node_next` and `ydb_subscript_next`
# write their results directly into the key / a caller-provided string.

const
  BLOB_PREFIX = "___$0"     # start of a large-value block marker
  BLOB_MARKER_LEN = 16      # "___$" & 8 digits & "$___"

proc fetchValue(k: var YdbKey): cint =
  ## Fetch the value of the key's node into DATABUF.
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()
  DATABUF.len_used = 0
  when compileOption("threads"):
    result = ydb_get_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)
  else:
    result = ydb_get_s(gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)

proc setBlockMarker(k: var YdbKey, i: int, blockNo: int) =
  ## Write the block marker `___$nnnnnnnn$___` as subscript `i`.
  var buf: array[BLOB_MARKER_LEN, char]
  buf[0] = '_'; buf[1] = '_'; buf[2] = '_'; buf[3] = '$'
  buf[12] = '$'; buf[13] = '_'; buf[14] = '_'; buf[15] = '_'
  var v = blockNo
  for p in 0..<8:
    buf[11 - p] = char(ord('0') + (v mod 10))
    v = v div 10
  k.setSub(i, buf)

proc ydb_data*(k: var YdbKey): int =
  ## Check existence/type of the key's node.
  ## Return codes: 0 = no data, 1 = data, 10 = child nodes, 11 = both.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()
  var value: cuint = 0

  when compileOption("threads"):
    rc = ydb_data_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, value.addr)
  else:
    rc = ydb_data_s(gbl.addr, k.nsubs.cint, idx[0].addr, value.addr)

  checkRC()
  return value.int

proc ydb_delete*(k: var YdbKey, deltype: uint) =
  ## Delete the node or subtree identified by the key.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()

  when compileOption("threads"):
    rc = ydb_delete_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, cast[cint](deltype))
  else:
    rc = ydb_delete_s(gbl.addr, k.nsubs.cint, idx[0].addr, deltype.cint)

  checkRC()

proc subscriptTraverse(k: var YdbKey, previous: bool, dst: var string): int =
  ## Next/previous subscript at the level of the key's last subscript.
  ## Writes the result into `dst` (its capacity is reused).
  checkBuffers()
  let savedN = k.nsubs
  if savedN == 0:
    k.setSub(0, EMPTY_STRING)   # special case: first/last subscript at this level

  var gbl = k.nameBuffer()
  let idx = k.subBuffers()
  DATABUF.len_used = 0

  when compileOption("threads"):
    if previous:
      rc = ydb_subscript_previous_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)
    else:
      rc = ydb_subscript_next_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)
  else:
    if previous:
      rc = ydb_subscript_previous_s(gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)
    else:
      rc = ydb_subscript_next_s(gbl.addr, k.nsubs.cint, idx[0].addr, DATABUF.addr)

  k.setSubsLen(savedN)
  result = rc

  if rc == YDB_OK:
    let n = DATABUF.len_used.int
    dst.setLen(n)
    if n > 0:
      copyMem(addr dst[0], DATABUF.buf_addr[0].addr, n)
    # Move the cursor: the key now points at the returned subscript, so the
    # next call continues after it (like ydb_node_next).
    if savedN == 0:
      k.setSub(0, dst)
    else:
      k.setSub(savedN - 1, dst)
  elif rc == YDB_ERR_NODEEND:
    dst.setLen(0)
  else:
    checkRC()

proc ydb_subscript_next*(k: var YdbKey, dst: var string): int =
  ## Write the next subscript at the current level into `dst` and move `k` to
  ## that subscript. Repeated calls therefore traverse all subscripts of the
  ## level:
  ##
  ## .. code-block:: nim
  ##   var k = initYdbKey("^orders")
  ##   var sub = ""
  ##   while ydb_subscript_next(k, sub) == YDB_OK:
  ##     echo sub
  ##
  ## Returns `YDB_OK` or `YDB_ERR_NODEEND`; raises on real errors.
  subscriptTraverse(k, false, dst)

proc ydb_subscript_previous*(k: var YdbKey, dst: var string): int =
  ## Write the previous subscript at the current level into `dst` and move `k`
  ## to that subscript.
  ## Returns `YDB_OK` or `YDB_ERR_NODEEND`; raises on real errors.
  subscriptTraverse(k, true, dst)

proc ydb_subscript_next*(k: var YdbKey): string =
  ## Convenience variant of `ydb_subscript_next` that returns the subscript.
  discard subscriptTraverse(k, false, result)

proc ydb_subscript_previous*(k: var YdbKey): string =
  ## Convenience variant of `ydb_subscript_previous` that returns the subscript.
  discard subscriptTraverse(k, true, result)

proc nodeTraverse(k: var YdbKey, previous: bool): int =
  ## Advance the key in place to the next/previous node of the tree.
  checkBuffers()
  let savedN = k.nsubs

  # YottaDB rejects NULL buf_addr entries in ret_subsarray.
  for i in 0..<YDB_MAX_SUBS:
    if k.cbufs[i].buf_addr == nil:
      k.reserveSub(i, YDB_KEY_INITIAL_CAP)
  if previous and savedN == 0:
    k.setMaxSubscripts()

  var gbl = k.nameBuffer()
  let idx = k.subBuffers()
  var retUsed: cint = YDB_MAX_SUBS

  while true:
    retUsed = YDB_MAX_SUBS

    when compileOption("threads"):
      if previous:
        rc = ydb_node_previous_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, retUsed.addr, idx[0].addr)
      else:
        rc = ydb_node_next_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, retUsed.addr, idx[0].addr)
    else:
      if previous:
        rc = ydb_node_previous_s(gbl.addr, k.nsubs.cint, idx[0].addr, retUsed.addr, idx[0].addr)
      else:
        rc = ydb_node_next_s(gbl.addr, k.nsubs.cint, idx[0].addr, retUsed.addr, idx[0].addr)

    if rc == YDB_ERR_INVSTRLEN:
      # retUsed is the index of the subscript buffer that was too small and
      # its len_used holds the required size. Grow and retry.
      let i = retUsed.int
      doAssert i >= 0 and i < YDB_MAX_SUBS
      let need = idx[i].len_used.int
      if need > k.subs[i].len:
        k.reserveSub(i, need)
        continue
      break                    # defensive: avoid an endless retry loop
    break

  result = rc
  if rc == YDB_OK and retUsed.int == 0:
    # YottaDB returned the unsubscripted variable itself (a node with a value
    # but no subscripts). Treat it as the end of the tree, like the former
    # Subscripts based API did. Without this a reverse walk would position the
    # key at 0 subscripts and the next call would wrap around to the last node
    # forever.
    k.setSubsLen(savedN)
    result = YDB_ERR_NODEEND
  elif rc == YDB_OK:
    k.nsubs = retUsed.int
    for i in 0..<k.nsubs:
      k.subUsed[i] = idx[i].len_used.int
    for i in k.nsubs ..< YDB_MAX_SUBS:
      idx[i].len_used = 0
  else:
    k.setSubsLen(savedN)

proc ydb_node_next*(k: var YdbKey): int =
  ## Advance `k` in place to the next node of its tree.
  ## Returns `YDB_OK` or `YDB_ERR_NODEEND`; raises on real errors.
  ## The key is unchanged when the end of the tree is reached.
  nodeTraverse(k, false)

proc ydb_node_previous*(k: var YdbKey): int =
  ## Move `k` in place to the previous node of its tree. With no subscripts,
  ## the key is positioned at the last node of the tree.
  ## Returns `YDB_OK` or `YDB_ERR_NODEEND`; raises on real errors.
  nodeTraverse(k, true)

proc getBlob(k: var YdbKey): string =
  ## Reassemble a value that `ydb_set` split into 1 MiB blocks.
  let savedN = k.nsubs
  defer: k.setSubsLen(savedN)

  result = newStringOfCap(YDB_MAX_BUF_SIZE)
  k.addSub(EMPTY_STRING)
  k.setBlockMarker(k.nsubs - 1, 0)
  var nextSub = ""

  while true:
    rc = fetchValue(k)
    if rc != YDB_OK:
      if rc == YDB_ERR_GVUNDEF: break
      checkRC()

    let n = DATABUF.len_used.int
    if n > 0:
      let oldLen = result.len
      result.setLen(oldLen + n)
      copyMem(addr result[oldLen], DATABUF.buf_addr[0].addr, n)

    discard ydb_subscript_next(k, nextSub)
    if not nextSub.startsWith(BLOB_PREFIX): break
    k.setSub(k.nsubs - 1, nextSub)

proc ydb_get*(k: var YdbKey): string =
  ## Retrieve the value of the key's node. Returns an empty string if the node
  ## does not exist or has no value.
  ##
  ## A special variable (`$JOB`, `$TRESTART`, ...) that yields no value raises
  ## `YdbError`, because reading such a variable is an error rather than a
  ## missing node.
  checkBuffers()
  rc = fetchValue(k)
  if rc == YDB_OK:
    if DATABUF.len_used > 0:
      let n = DATABUF.len_used.int
      result.setLen(n)
      copyMem(addr result[0], DATABUF.buf_addr[0].addr, n)
    elif k.nameUsed > 0 and k.name[0] == '$':
      raise newException(YdbError, "Cannot access special var: " & k.globalName)
  elif rc == YDB_ERR_GVUNDEF:
    # A node without a value may still hold a large value split into blocks.
    if ydb_data(k) == YDB_DATA_NOVALUE_DESC:
      result = getBlob(k)
    else:
      result = EMPTY_STRING
  else:
    checkRC()

proc ydb_set*(k: var YdbKey, value: string) =
  ## Set the value of the key's node.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()

  if value.len <= YDB_MAX_BUF_SIZE:
    # YottaDB only reads the value, so point directly into `value`
    var vbuf = ydb_buffer_t(
      len_alloc: value.len.uint32,
      len_used: value.len.uint32,
      buf_addr: (if value.len == 0: nil else: cast[cstring](unsafeAddr value[0])))
    when compileOption("threads"):
      rc = ydb_set_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, vbuf.addr)
    else:
      rc = ydb_set_s(gbl.addr, k.nsubs.cint, idx[0].addr, vbuf.addr)
    checkRC()
  else:
    # Remove the old node/tree, then write 1 MiB blocks as child subscripts.
    ydb_delete(k, YDB_DEL_TREE)

    let savedN = k.nsubs
    defer: k.setSubsLen(savedN)
    k.addSub(EMPTY_STRING)

    var offset = 0
    var blockNo = 0
    while offset < value.len:
      let n = min(YDB_MAX_BUF_SIZE, value.len - offset)
      k.setBlockMarker(k.nsubs - 1, blockNo)
      var vbuf = ydb_buffer_t(
        len_alloc: n.uint32,
        len_used: n.uint32,
        buf_addr: cast[cstring](unsafeAddr value[offset]))
      when compileOption("threads"):
        rc = ydb_set_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, vbuf.addr)
      else:
        rc = ydb_set_s(gbl.addr, k.nsubs.cint, idx[0].addr, vbuf.addr)
      checkRC()
      inc offset, n
      inc blockNo

proc ydb_increment*(k: var YdbKey, value: int = 1): int =
  ## Atomically increment the key's node and return the new value.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()

  var ibuf: array[24, char]
  let start = formatInt(ibuf, value)
  var incbuf = ydb_buffer_t(
    len_alloc: uint32(ibuf.len - start),
    len_used: uint32(ibuf.len - start),
    buf_addr: cast[cstring](addr ibuf[start]))

  INCRBUF.len_used = 0
  when compileOption("threads"):
    rc = ydb_incr_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr, incbuf.addr, INCRBUF.addr)
  else:
    rc = ydb_incr_s(gbl.addr, k.nsubs.cint, idx[0].addr, incbuf.addr, INCRBUF.addr)

  checkRC()

  try:
    result = parseFastInt(cast[ptr UncheckedArray[char]](INCRBUF.buf_addr), INCRBUF.len_used.int)
  except:
    raise newException(YdbError, "Illegal Number. Tried to parse increment result")

proc ydb_lock_incr*(timeout_nsec: int, k: var YdbKey) =
  ## Increment the lock for the key's node.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()

  when compileOption("threads"):
    rc = ydb_lock_incr_st(TPTOKEN, ERRMSG.addr, timeout_nsec.culonglong, gbl.addr, k.nsubs.cint, idx[0].addr)
  else:
    rc = ydb_lock_incr_s(timeout_nsec.culonglong, gbl.addr, k.nsubs.cint, idx[0].addr)

  if rc == YDB_LOCK_TIMEOUT:
    raise newException(YdbError, "YDB_LOCK_TIMEOUT while setting: " & $k)
  else:
    checkRC()

proc ydb_lock_decr*(k: var YdbKey) =
  ## Decrement the lock for the key's node.
  checkBuffers()
  var gbl = k.nameBuffer()
  let idx = k.subBuffers()

  when compileOption("threads"):
    rc = ydb_lock_decr_st(TPTOKEN, ERRMSG.addr, gbl.addr, k.nsubs.cint, idx[0].addr)
  else:
    rc = ydb_lock_decr_s(gbl.addr, k.nsubs.cint, idx[0].addr)

  checkRC()

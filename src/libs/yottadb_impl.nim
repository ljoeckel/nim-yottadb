import strutils, std/strformat
import yottadb_types

when defined(futhark):
  import futhark, os
  importc:
    outputPath currentSourcePath.parentDir / "yottadb.nim"
    path "/usr/local/lib/yottadb/r202"
    "libyottadb.h"
else:
  include "yottadb.nim"

proc stringToYdbBuffer(name: string = "", len_used:int = -1): ydb_buffer_t {.gcsafe.}
proc zeroBuffer(size: int): string {.gcsafe.}

var
  buf_initialized {.threadvar.}: bool
  ERRMSG {.threadvar.}: ydb_buffer_t
  DATABUF {.threadvar.}: ydb_buffer_t
  GLOBAL {.threadvar.}: ydb_buffer_t
  IDXARR {.threadvar.}: array[0..31, ydb_buffer_t]
  tptoken {.threadvar.}: uint64
  rc {.threadvar.}: cint

proc check() =
  if not buf_initialized:
    ERRMSG = stringToYdbBuffer(zeroBuffer(1024))
    DATABUF = stringToYdbBuffer(zeroBuffer(1024*1024))
    GLOBAL = stringToYdbBuffer(zeroBuffer(256))
    buf_initialized = true
    for idx in 0..<IDXARR.len:
      IDXARR[idx] = stringToYdbBuffer(zeroBuffer(32))


proc allocCString*(s: string): cstring =
  let len = s.len
  let buf = cast[ptr UncheckedArray[char]](alloc(len + 1))
  if len > 0:
    copyMem(buf, s[0].addr, len)
  buf[len] = '\0'
  result = cast[cstring](buf)

proc deallocBuffer(buffer: ydb_buffer_t) =
  if buffer.buf_addr != nil:
    dealloc(buffer.buf_addr)

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
  '\0'.repeat(size) 

proc stringToYdbBuffer(name: string = "", len_used:int = -1): ydb_buffer_t =
  result = ydb_buffer_t()
  result.len_alloc = name.len.uint32
  if len_used != -1:
    result.len_used = len_used.uint32
  else:
    result.len_used = name.len.uint32
  
  result.buf_addr = allocCString(name)

proc setYdbBuffer(buffer: var ydb_buffer_t, name: string = "") =
  let len = name.len
  if len > 0:
    buffer.len_used = len.uint32
    copyMem(buffer.buf_addr, name[0].addr, len)
    buffer.buf_addr[len] = '\0'
  else:
    buffer.len_used = 0.uint32


proc setIdxArr(keys: seq[string]) =
  for idx in 0..<keys.len:
    setYdbBuffer(IDXARR[idx], keys[idx])
  for idx in keys.len..<IDXARR.len:
    IDXARR[idx].len_used = 0.uint32
    

proc ydbMessage_db*(status: cint): string =
  if status == YDB_OK: return
  let rc = ydb_message(status, ERRMSG.addr)
  if rc == YDB_OK:
    return fmt"{status}, " & strip($ERRMSG.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"
  

# ------------ YottaDB internal API calls -----------------------

proc ydb_set_db*(name: string, keys: Subscripts = @[], value: string = "") =
  check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF, value)
  setIdxArr(keys)

  when compileOption("threads"):
    rc = ydbSet_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydbSet_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)

  if rc < YDB_OK:
    raise newException(YottaDbError, ydbMessage_db(rc) & " name:" & name & " keys:" & $keys & " value:" & $value)


proc ydb_get_db*(name: string, keys: Subscripts = @[]): string =
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(keys)
  
  when compileOption("threads"):
    rc = ydb_get_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)
  else:
    rc = ydb_get_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr)

  if rc == YDB_OK:
    DATABUF.buf_addr[DATABUF.len_used] = '\0'
    result = $DATABUF.buf_addr


proc ydb_data_db*(name: string, keys: Subscripts): int =
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(keys)
  var value: cuint = 0

  when compileOption("threads"):
    rc = ydbData_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, value.addr)
  else:
    rc = ydbData_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, value.addr)

  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}({keys})")
  else:
    return cast[int](value) # 0,1,10,11

proc ydb_delete(name: string, keys: Subscripts, deltype: uint): int =
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(keys)

  when compileOption("threads"):
    rc = ydb_delete_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, cast[cint](deltype))
  else:
    rc = ydb_delete_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, cast[cint](deltype))

  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}({keys})")
  else:
    return rc.int

proc ydb_delete_node_db*(name: string, keys: Subscripts): int =
  return ydb_delete(name, keys, YDB_DEL_NODE)

proc ydb_delete_tree_db*(name: string, keys: Subscripts): int =
  return ydb_delete(name, keys, YDB_DEL_TREE)

proc ydb_increment_db*(name: string, keys: Subscripts, increment: int): string =
  check()
  setYdbBuffer(GLOBAL, name)
  setYdbBuffer(DATABUF, $increment)
  setIdxArr(keys)
  var value = stringToYdbBuffer(zeroBuffer(32))
  defer:
    deallocBuffer(value)

  when compileOption("threads"):
    rc = ydb_incr_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr, value.addr)
  else:
    rc = ydb_incr_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, DATABUF.addr, value.addr)

  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}({keys})")
  else:
    return $value.buf_addr

proc node_traverse(direction: Direction, name: string, keys: Subscripts): Subscripts =
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(keys)
  var ret_subs_used: cint = 0
  var tmp = stringToYdbBuffer()
  var ret_subsarray: array[0..31, ydb_buffer_t]
  defer:
    deallocBuffer(tmp)
    deallocBuffer(ret_subsarray)

  when compileOption("threads"):
      # 1. call to get ret_subs_used
    if direction == Direction.Next:
      rc = ydb_node_next_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, tmp.addr)
    else:
      rc = ydb_node_previous_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, tmp.addr)
  
    for i in 0..<cast[int](ret_subs_used):
      ret_subsarray[i] = stringToYdbBuffer(zeroBuffer(64), len_used=0) # TODO: max length of index
    
    # 2. call to get the data
    if direction == Direction.Next:
      rc = ydb_node_next_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
    else:
      rc = ydb_node_previous_st(tptoken, ERRMSG.addr, GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)

  else:
    # 1. call to get ret_subs_used
    if direction == Direction.Next:
      rc = ydb_node_next_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, tmp.addr)
    else:
      rc = ydb_node_previous_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, tmp.addr)

    for i in 0..<cast[int](ret_subs_used):
      ret_subsarray[i] = stringToYdbBuffer(zeroBuffer(64), len_used=0) # TODO: max length of index

    # 2. call to get the data
    if direction == Direction.Next:
      rc = ydb_node_next_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
    else:
      rc = ydb_node_previous_s(GLOBAL.addr, cast[cint](keys.len), IDXARR[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
  
  # construct the return key sequence
  var sbscr = newSeq[string]()
  for item in ret_subsarray:
    if item.len_used > 0:
      sbscr.add($item.buf_addr)

  return sbscr

proc ydb_node_next_db*(name: string, keys: Subscripts): Subscripts =
  return node_traverse(Direction.Next, name, keys)

proc ydb_node_previous_db*(name: string, keys: Subscripts): Subscripts =
  return node_traverse(Direction.Previous, name, keys)

proc subscript_traverse(direction: Direction, name: string, keys: var Subscripts): int =
  check()
  setYdbBuffer(GLOBAL, name)
  setIdxArr(keys)
  let subs_used = cast[cint](keys.len)
  var ret_value = stringToYdbBuffer(zeroBuffer(64), len_used=0) # TODO: max length of index
  defer:
    deallocBuffer(ret_value)

  when compileOption("threads"):
    # 1. call to get ret_subs_used
    if direction == Direction.Next:
      rc = ydb_subscript_next_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs_used, IDXARR[0].addr,  ret_value.addr)
    else:
      rc = ydb_subscript_previous_st(tptoken, ERRMSG.addr, GLOBAL.addr, subs_used, IDXARR[0].addr,  ret_value.addr)    
  else:
    # 1. call to get ret_subs_used
    if direction == Direction.Next:
      rc = ydb_subscript_next_s(GLOBAL.addr, subs_used, IDXARR[0].addr,  ret_value.addr)
    else:
      rc = ydb_subscript_previous_s(GLOBAL.addr, subs_used, IDXARR[0].addr,  ret_value.addr)    
  
  # update the key sequence as return value
  let level = keys.len - 1
  if level < 0:
    keys.add($ret_value.buf_addr)
  else:
    keys[level] = $ret_value.buf_addr

  return rc.int

proc ydb_subscript_next_db*(name: string, keys: var Subscripts): int =
  return subscript_traverse(Direction.Next, name, keys)

proc ydb_subscript_previous_db*(name: string, keys: var Subscripts): int =
  return subscript_traverse(Direction.Previous, name, keys)

# macro ydbLockDbVariadicMacro(timeout: culonglong; names: typed; subs: typed): untyped =
#   result = newCall(ident("ydbLock_s"))
#   result.add newCall(ident("culonglong"), timeout)
#   result.add newCall(ident("cint"), newDotExpr(names, ident("len")))
#   for i in 0 ..< names.len:
#     result.add newCall(ident("addr"), newTree(nnkBracketExpr, names, newLit(i)))
#     result.add newCall(ident("cint"), newDotExpr(newTree(nnkBracketExpr, subs, newLit(i)), ident("len")))
#     result.add newCall(ident("addr"), newTree(nnkBracketExpr, newTree(nnkBracketExpr, subs, newLit(i)), newLit(0)))


proc ydb_lock_db_variadic(timeout: culonglong, names: seq[ydb_buffer_t], subs: seq[seq[ydb_buffer_t]]): cint =
  check()
  
  if names.len == 0:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint) # release all locks
    else:
      rc = ydbLock_s(timeout, names.len.cint) # release all locks
  elif names.len == 1:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, addr names[0], subs.len.cint, addr subs[0][0])  
    else:
      rc = ydbLock_s(timeout, names.len.cint, addr names[0], subs.len.cint, addr subs[0][0])  
  elif names.len == 2:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0])
  elif names.len == 3:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0])
  elif names.len == 4:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0])
  elif names.len == 5:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0])
  elif names.len == 6:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0])
  elif names.len == 7:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0])
  elif names.len == 8:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0])
  elif names.len == 9:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0])
  elif names.len == 10:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0],
        addr names[9], subs[9].len.cint, addr subs[9][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0],
        addr names[7], subs[7].len.cint, addr subs[7][0],
        addr names[8], subs[8].len.cint, addr subs[8][0],
        addr names[9], subs[9].len.cint, addr subs[9][0])
  elif names.len == 11:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[10], subs[10].len.cint, addr subs[10][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[10], subs[10].len.cint, addr subs[10][0])
  elif names.len == 12:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[11], subs[11].len.cint, addr subs[11][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[11], subs[11].len.cint, addr subs[11][0])
  elif names.len == 13:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[12], subs[12].len.cint, addr subs[12][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[12], subs[12].len.cint, addr subs[12][0])
  elif names.len == 14:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[13], subs[13].len.cint, addr subs[13][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[13], subs[13].len.cint, addr subs[13][0])
  elif names.len == 15:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[14], subs[14].len.cint, addr subs[14][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[14], subs[14].len.cint, addr subs[14][0])
  elif names.len == 16:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[15], subs[15].len.cint, addr subs[15][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[15], subs[15].len.cint, addr subs[15][0])
  elif names.len == 17:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[16], subs[16].len.cint, addr subs[16][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[16], subs[16].len.cint, addr subs[16][0])
  elif names.len == 18:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[17], subs[17].len.cint, addr subs[17][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[17], subs[17].len.cint, addr subs[17][0])
  elif names.len == 19:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[18], subs[18].len.cint, addr subs[18][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[18], subs[18].len.cint, addr subs[18][0])
  elif names.len == 20:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[19], subs[19].len.cint, addr subs[19][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[19], subs[19].len.cint, addr subs[19][0])
  elif names.len == 21:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[20], subs[20].len.cint, addr subs[20][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[20], subs[20].len.cint, addr subs[20][0])
  elif names.len == 22:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[21], subs[21].len.cint, addr subs[21][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[21], subs[21].len.cint, addr subs[21][0])
  elif names.len == 23:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[22], subs[22].len.cint, addr subs[22][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[22], subs[22].len.cint, addr subs[22][0])
  elif names.len == 24:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[23], subs[23].len.cint, addr subs[23][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[23], subs[23].len.cint, addr subs[23][0])
  elif names.len == 25:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[24], subs[24].len.cint, addr subs[24][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[24], subs[24].len.cint, addr subs[24][0])
  elif names.len == 26:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[25], subs[25].len.cint, addr subs[25][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[25], subs[25].len.cint, addr subs[25][0])
  elif names.len == 27:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[26], subs[26].len.cint, addr subs[26][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[26], subs[26].len.cint, addr subs[26][0])
  elif names.len == 28:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[27], subs[27].len.cint, addr subs[27][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[27], subs[27].len.cint, addr subs[27][0])
  elif names.len == 29:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[28], subs[28].len.cint, addr subs[28][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[28], subs[28].len.cint, addr subs[28][0])
  elif names.len == 30:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[29], subs[29].len.cint, addr subs[29][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[29], subs[29].len.cint, addr subs[29][0])
  elif names.len == 31:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[30], subs[30].len.cint, addr subs[30][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[30], subs[30].len.cint, addr subs[30][0])
  elif names.len == 32:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[31], subs[31].len.cint, addr subs[31][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[31], subs[31].len.cint, addr subs[31][0])
  elif names.len == 33:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[32], subs[32].len.cint, addr subs[32][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[32], subs[32].len.cint, addr subs[32][0])
  elif names.len == 34:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[33], subs[33].len.cint, addr subs[33][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[33], subs[33].len.cint, addr subs[33][0])
  elif names.len == 35:
    when compileOption("threads"):
      rc = ydbLock_st(tptoken, ERRMSG.addr, timeout, names.len.cint, 
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
        addr names[34], subs[34].len.cint, addr subs[34][0])
    else:
      rc = ydbLock_s(timeout, names.len.cint, 
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
        addr names[34], subs[34].len.cint, addr subs[34][0])
  else:
    echo "Too many arguments names.len=", names.len
    echo "names:", names
    rc = YDB_ERR_NAMECOUNT2HI

  return rc

proc ydb_lock_db*(timeout_nsec: culonglong, keys: seq[Subscripts]): int =
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

  return ydb_lock_db_variadic(timeout_nsec, locknames, locksubs)
  #TODO: Use macro instead! return ydbLockDbVariadicMacro(timeout_nsec, locknames, locksubs)



import strutils, std/strformat
import yottadb_types
import macros

when defined(futhark):
  import futhark, os
  importc:
    outputPath currentSourcePath.parentDir / "yottadb.nim"
    path "/usr/local/lib/yottadb/r202"
    "libyottadb.h"
else:
  include "yottadb.nim"

proc zeroBuffer(size: int): string =
  '\0'.repeat(size)

var 
  BUF_1024 = zeroBuffer(1024)
const 
  EXPECTED_ERRORS_NEXT_NODE: array[0..4, int] = [YDB_ERR_INSUFFSUBS, YDB_ERR_INVSTRLEN, YDB_ERR_NODEEND, YDB_ERR_PARAMINVALID, YDB_OK]


# Helper to test for a unexpected error condition when traversing with ydb_next_node etc.
proc isExpectedErrorNextNode(rc: cint): bool =
  let return_code = cast[int](rc)
  for error in EXPECTED_ERRORS_NEXT_NODE:
    if return_code == error:
      return true
  return false

proc stringToYdbBuffer(name: string = "", len_used:int = -1): ydb_buffer_t =
  result = ydb_buffer_t()
  result.len_alloc = name.len.uint32
  if len_used != -1:
    result.len_used = len_used.uint32
  else:
    result.len_used = name.len.uint32
  result.buf_addr = name.cstring

proc initSubscripts(keys: seq[string]): array[32, ydb_buffer_t] =
  # setup index array (max 31)
  var idxarr: array[0..31, ydb_buffer_t]
  for idx in 0 .. keys.len-1:
    idxarr[idx] = stringToYdbBuffer(keys[idx])
  return idxarr

proc printArray(a: openArray[ydb_buffer_t]) =
  for item in a:
    if item.len_used > 0 or item.len_alloc > 0:
      echo item

proc ydbMessage_db*(status: cint): string =
  if status == YDB_OK: return
  var buf = stringToYdbBuffer(BUF_1024)
  buf.len_used = cast[uint32](0)
  let rc = ydb_message(status, buf.addr)
  if rc == YDB_OK:
    return fmt"{status}, " & strip($buf.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"

# ------------ YottaDB internal API calls -----------------------

proc ydb_set_db*(name: string, keys: seq[string] = @[], value: string = "") =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  let value = stringToYdbBuffer(value)

  # Save in yottadb
  let rc = ydbSet_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, ydbMessage_db(rc))

proc ydb_get_db*(name: string, keys: seq[string] = @[]): string =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var value = stringToYdbBuffer("")

  # get the length from yottadb signaled with an exception to avoid passing a huge buffer over
  var rc = ydbGet_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  value = stringToYdbBuffer(zeroBuffer(value.len_used.int))

  rc = ydbGet_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr

proc ydb_data_db*(name: string, keys: seq[string]): int =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var value: cuint = 0
  var rc = ydbData_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")
  else:
    return cast[int](value) # 0,1,10,11

proc ydb_delete(name: string, keys: seq[string], deltype: uint): cint =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var rc = ydb_delete_s(global.addr, cast[cint](keys.len), idxarr[0].addr, cast[cint](deltype))
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")
  else:
    return rc

proc ydb_delete_node_db*(name: string, keys: seq[string]): cint =
  return ydb_delete(name, keys, YDB_DEL_NODE)

proc ydb_delete_tree_db*(name: string, keys: seq[string]): cint =
  return ydb_delete(name, keys, YDB_DEL_TREE)

proc ydb_increment_db*(name: string, keys: seq[string], increment: int): string =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  let incr = stringToYdbBuffer($increment)
  var value = stringToYdbBuffer(zeroBuffer(32))
  var rc = ydb_incr_s(global.addr, cast[cint](keys.len), idxarr[0].addr, incr.addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr

proc node_traverse(direction: Direction, name: string, keys: seq[string]): (int, seq[string]) =
  var varname = stringToYdbBuffer(name)
  var idxarr = initSubscripts(keys)
  var ret_subs_used: cint = 0
  var tmp = stringToYdbBuffer()
  var rc: cint = YDB_OK
  # 1. call to get ret_subs_used
  if direction == Direction.Next:
    rc = ydb_node_next_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, tmp.addr)
  else:
    rc = ydb_node_previous_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, tmp.addr)
  var ret_subsarray: array[0..31, ydb_buffer_t]
  for i in 0..cast[int](ret_subs_used) - 1:
    ret_subsarray[i] = stringToYdbBuffer(zeroBuffer(64), len_used=0) # TODO: max length of index
  # 2. call to get the data
  if direction == Direction.Next:
    rc = ydb_node_next_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
  else:
    rc = ydb_node_previous_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
  
  # construct the return key sequence
  var sbscr = newSeq[string]()
  for item in ret_subsarray:
    if item.len_used > 0:
      sbscr.add($item.buf_addr)

  if not isExpectedErrorNextNode(rc):  
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")

  return (rc: cast[int](rc), subscript: sbscr)

proc ydb_node_next_db*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Next, name, keys)

proc ydb_node_previous_db*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Previous, name, keys)

proc subscript_traverse(direction: Direction, name: string, keys: var seq[string]): int =
  var varname = stringToYdbBuffer(name)
  var subsarr = initSubscripts(keys)
  let subs_used = cast[cint](keys.len)
  var ret_value = stringToYdbBuffer(zeroBuffer(64), len_used=0) # TODO: max length of index
  var rc: cint = YDB_OK
  # 1. call to get ret_subs_used
  if direction == Direction.Next:
    rc = ydb_subscript_next_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)
  else:
    rc = ydb_subscript_previous_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)    
  
  if not isExpectedErrorNextNode(rc):  
    raise newException(YottaDbError, fmt"{ydbMessage_db(rc)}, Global:{name}{keys}")

  # update the key sequence as return value
  let level = keys.len - 1
  if level < 0:
    keys.add($ret_value.buf_addr)
  else:
    keys[level] = $ret_value.buf_addr
  return rc

proc ydb_subscript_next_db*(name: string, keys: var seq[string]): int =
  return subscript_traverse(Direction.Next, name, keys)

proc ydb_subscript_previous_db*(name: string, keys: var seq[string]): int =
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
  var rc: cint = 0
  if names.len == 0:
    rc = ydbLock_s(timeout, names.len.cint) # release all locks
  elif names.len == 1:
    rc = ydbLock_s(timeout, names.len.cint, addr names[0], subs.len.cint, addr subs[0][0])  
  elif names.len == 2:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0])
  elif names.len == 3:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0])
  elif names.len == 4:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0])
  elif names.len == 5:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0])
  elif names.len == 6:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0])
  elif names.len == 7:
    rc = ydbLock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0],
        addr names[4], subs[4].len.cint, addr subs[4][0],
        addr names[5], subs[5].len.cint, addr subs[5][0],
        addr names[6], subs[6].len.cint, addr subs[6][0])
  elif names.len == 8:
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

proc ydb_lock_db*(timeout_nsec: culonglong, keys: seq[seq[string]]): int =
  var locknames: seq[ydb_buffer_t] = newSeq[ydb_buffer_t]()
  var locksubs: seq[seq[ydb_buffer_t]] = newSeq[newSeq[ydb_buffer_t]()]()
  for subskeys in keys:
    let varname = stringToYdbBuffer(subskeys[0])
    locknames.add(varname)
    var subs = newSeq[ydb_buffer_t]()
    for idx in 1..len(subskeys)-1:
      subs.add(stringToYdbBuffer(subskeys[idx]))
    locksubs.add(subs)

  return ydb_lock_db_variadic(timeout_nsec, locknames, locksubs)
  #TODO: Use macro instead! return ydbLockDbVariadicMacro(timeout_nsec, locknames, locksubs)



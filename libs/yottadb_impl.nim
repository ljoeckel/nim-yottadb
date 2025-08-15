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

var 
  BUF_1024 = '\0'.repeat(1024)
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

proc ydbmsg_db*(status: cint): string =
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
  let rc = ydb_set_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, ydbmsg_db(rc))

proc ydb_get_db*(name: string, keys: seq[string] = @[]): string =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var value = stringToYdbBuffer("")

  # get the length from yottadb signaled with an exception to avoid passing a huge buffer over
  var rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  value = stringToYdbBuffer('\0'.repeat(value.len_used))

  rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr

proc ydb_data_db*(name: string, keys: seq[string]): int =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var value: cuint = 0
  var rc = ydb_data_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")
  else:
    return cast[int](value) # 0,1,10,11

proc ydb_delete(name: string, keys: seq[string], deltype: uint): cint =
  let global = stringToYdbBuffer(name)
  let idxarr = initSubscripts(keys)
  var rc = ydb_delete_s(global.addr, cast[cint](keys.len), idxarr[0].addr, cast[cint](deltype))
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")
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
  var value = stringToYdbBuffer(' '.repeat(28))
  var rc = ydb_incr_s(global.addr, cast[cint](keys.len), idxarr[0].addr, incr.addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")
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
    ret_subsarray[i] = stringToYdbBuffer('\0'.repeat(64), len_used=0) # TODO: max length of index
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
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")

  return (rc: cast[int](rc), subscript: sbscr)

proc ydb_node_next_db*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Next, name, keys)

proc ydb_node_previous_db*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Previous, name, keys)

proc subscript_traverse(direction: Direction, name: string, keys: var seq[string]): int =
  var varname = stringToYdbBuffer(name)
  var subsarr = initSubscripts(keys)
  let subs_used = cast[cint](keys.len)
  var ret_value = stringToYdbBuffer('\0'.repeat(64), len_used=0) # TODO: max length of index
  var rc: cint = YDB_OK
  # 1. call to get ret_subs_used
  if direction == Direction.Next:
    rc = ydb_subscript_next_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)
  else:
    rc = ydb_subscript_previous_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)    
  
  if not isExpectedErrorNextNode(rc):  
    raise newException(YottaDbError, fmt"{ydbmsg_db(rc)}, Global:{name}{keys}")

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



# Create the variatic call to ydb_lock_s
# return ydb_lock_s(timeout, names.len.cint, addr names[0], subs.len.cint, addr subs[0][0])  
import macros

macro ydbLockDbVariadic(timeout: uint; names: typed; subs: typed): untyped =
  result = newCall(ident("ydb_lock_s"))
  result.add newCall(ident("culonglong"), timeout)
  result.add newCall(ident("cint"), newDotExpr(names, ident("len")))
  for i in 0 ..< names.len:
    result.add newCall(ident("addr"), newTree(nnkBracketExpr, names, newLit(i)))
    result.add newCall(ident("cint"), newDotExpr(newTree(nnkBracketExpr, subs, newLit(i)), ident("len")))
    result.add newCall(ident("addr"), newTree(nnkBracketExpr, newTree(nnkBracketExpr, subs, newLit(i)), newLit(0)))


proc ydb_lock_db_variadic(timeout: uint, names: seq[ydb_buffer_t], subs: seq[seq[ydb_buffer_t]]): cint =
  var rc: cint = 0
  if names.len == 1:
    rc = ydb_lock_s(timeout, names.len.cint, addr names[0], subs.len.cint, addr subs[0][0])  
  elif names.len == 2:
    rc = ydb_lock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0])
  elif names.len == 3:
    rc = ydb_lock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0])
  elif names.len == 4:
    rc = ydb_lock_s(timeout, names.len.cint, 
        addr names[0], subs[0].len.cint, addr subs[0][0],
        addr names[1], subs[1].len.cint, addr subs[1][0],
        addr names[2], subs[2].len.cint, addr subs[2][0],
        addr names[3], subs[3].len.cint, addr subs[3][0])
  return rc

proc ydb_lock_db*(timeout_nsec: uint, keys: seq[seq[string]]): cint =
  #if keys.len > 35:
  #  return 
  let tout = cast[uint](timeout_nsec)
  let namecount = keys.len.cint

  var locknames: seq[ydb_buffer_t] = newSeq[ydb_buffer_t]()
  var locksubs: seq[seq[ydb_buffer_t]] = newSeq[newSeq[ydb_buffer_t]()]()

  for subskeys in keys:
    let varname = stringToYdbBuffer(subskeys[0])
    locknames.add(varname)
    var subs = newSeq[ydb_buffer_t]()
    for idx in 1..len(subskeys)-1:
      subs.add(stringToYdbBuffer(subskeys[idx]))
    locksubs.add(subs)

  return ydbLockDbVariadic(timeout_nsec, locknames, locksubs)
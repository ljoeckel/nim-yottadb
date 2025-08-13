import strutils, std/strformat
import std/sequtils

when defined(futhark):
  import futhark, os
  importc:
    outputPath currentSourcePath.parentDir / "yottadb.nim"
    path "/usr/local/lib/yottadb/r202"
    "libyottadb.h"
else:
  include "yottadb.nim"

type 
  Direction = enum
    Next,
    Previous

  YottaDbError* = object of CatchableError


var BUF_1024 = '\0'.repeat(1024)
const EXPECTED_ERRORS_NEXT_NODE: array[0..4, int] = [YDB_ERR_INSUFFSUBS, YDB_ERR_INVSTRLEN, YDB_ERR_NODEEND, YDB_ERR_PARAMINVALID, YDB_OK]

# Helper to test for a unexpected error condition when traversing with ydb_next_node etc.
proc isExpectedErrorNextNode(rc: cint): bool =
  let return_code = cast[int](rc)
  for error in EXPECTED_ERRORS_NEXT_NODE:
    if return_code == error:
      return true
  return false


proc stringToBuffer(name: string = "", len_used:int = -1): ydb_buffer_t =
  var buf = ydb_buffer_t()
  buf.buf_addr = name.cstring
  buf.len_alloc = cast[uint32](len(name))
  if len_used != -1:
    buf.len_used = cast[uint32](len_used)
  else:
    buf.len_used = cast[uint32](len(name))
  return buf


proc setupIndex(keys: seq[string]): array[32, ydb_buffer_t] =
  # setup index array (max 31)
  var idxarr: array[0..31, ydb_buffer_t]
  for idx in 0 .. keys.len-1:
    idxarr[idx] = stringToBuffer(keys[idx])
  return idxarr


proc printArray(a: openArray[ydb_buffer_t]) =
  for item in a:
    if item.len_used > 0 or item.len_alloc > 0:
      echo item


proc ydbmsg*(status: cint): string =
  if status == YDB_OK: return
  var buf = stringToBuffer(BUF_1024)
  buf.len_used = cast[uint32](0)
  let rc = ydb_message(status, buf.addr)
  if rc == YDB_OK:
    return fmt"{status}, " & strip($buf.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc ydb_set*(name: string, keys: seq[string] = @[], value: string = "") =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  let value = stringToBuffer(value)

  # Save in yottadb
  let rc = ydb_set_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, ydbmsg(rc))


proc ydb_get*(name: string, keys: seq[string] = @[]): string =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  var value = stringToBuffer("")

  # get the length from yottadb signaled with an exception to avoid passing a huge buffer over
  var rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  value = stringToBuffer('\0'.repeat(value.len_used))

  rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr


proc ydb_data*(name: string, keys: seq[string]): int =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  var value: cuint = 0
  var rc = ydb_data_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return cast[int](value)


proc ydb_delete(name: string, keys: seq[string], deltype: uint): cint =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  var rc = ydb_delete_s(global.addr, cast[cint](keys.len), idxarr[0].addr, cast[cint](deltype))
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return rc

proc ydb_delete_node*(name: string, keys: seq[string]): cint =
  return ydb_delete(name, keys, YDB_DEL_NODE)

proc ydb_delete_tree*(name: string, keys: seq[string]): cint =
  return ydb_delete(name, keys, YDB_DEL_TREE)


proc ydb_increment*(name: string, keys: seq[string], increment: int): string =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  let incr = stringToBuffer($increment)
  var value = stringToBuffer(' '.repeat(28))
  var rc = ydb_incr_s(global.addr, cast[cint](keys.len), idxarr[0].addr, incr.addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr


proc node_traverse(direction: Direction, name: string, keys: seq[string]): (int, seq[string]) =
  var varname = stringToBuffer(name)
  var idxarr = setupIndex(keys)
  var ret_subs_used: cint = 0
  var tmp = stringToBuffer()
  var rc: cint = YDB_OK
  # 1. call to get ret_subs_used
  if direction == Direction.Next:
    rc = ydb_node_next_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, tmp.addr)
  else:
    rc = ydb_node_previous_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, tmp.addr)
  var ret_subsarray: array[0..31, ydb_buffer_t]
  for i in 0..cast[int](ret_subs_used) - 1:
    ret_subsarray[i] = stringToBuffer('\0'.repeat(64), len_used=0) # TODO: max length of index
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
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")

  return (rc: cast[int](rc), subscript: sbscr)


proc ydb_node_next*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Next, name, keys)

proc ydb_node_previous*(name: string, keys: seq[string]): (int, seq[string]) =
  return node_traverse(Direction.Previous, name, keys)

proc subscript_traverse(direction: Direction, name: string, keys: var seq[string]): int =
  var varname = stringToBuffer(name)
  var subsarr = setupIndex(keys)
  let subs_used = cast[cint](keys.len)
  var ret_value = stringToBuffer('\0'.repeat(64), len_used=0) # TODO: max length of index
  var rc: cint = YDB_OK
  # 1. call to get ret_subs_used
  if direction == Direction.Next:
    rc = ydb_subscript_next_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)
  else:
    rc = ydb_subscript_previous_s(varname.addr, subs_used, subsarr[0].addr,  ret_value.addr)    
  
  if not isExpectedErrorNextNode(rc):  
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")

  # update the key sequence as return value
  let level = keys.len - 1
  if level < 0:
    keys.add($ret_value.buf_addr)
  else:
    keys[level] = $ret_value.buf_addr
  return rc

proc ydb_subscript_next*(name: string, keys: var seq[string]): int =
  return subscript_traverse(Direction.Next, name, keys)

proc ydb_subscript_previous*(name: string, keys: var seq[string]): int =
  return subscript_traverse(Direction.Previous, name, keys)

import strutils, std/strformat
import std/sequtils

var BUF_1024 = '\0'.repeat(1024)


when defined(futhark):
  import futhark, os
  importc:
    outputPath currentSourcePath.parentDir / "yottadb.nim"
    path "/usr/local/lib/yottadb/r202"
    "libyottadb.h"
else:
  include "yottadb.nim"


type 
  YottaDbError* = object of CatchableError


proc stringToBuffer(name: string = "", len_used:int = -1): ydb_buffer_t =
  var buf: ydb_buffer_t = ydb_buffer_t()
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


proc ydbmsg*(status: cint): string =
  if status == YDB_OK: return
  var buf = stringToBuffer(BUF_1024)
  buf.len_used = cast[uint32](0)
  let rc = ydb_message(status, buf.addr)
  if rc == YDB_OK:
    return fmt"{status}, " & strip($buf.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc ydb_set*(name: string, keys: seq[string], value: string) =
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  let value = stringToBuffer(value)

  # Save in yottadb
  let rc = ydb_set_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, ydbmsg(rc))


proc ydb_get*(name: string, keys: seq[string]): string =
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


proc printArray(a: openArray[ydb_buffer_t]) =
  for item in a:
    if item.len_used > 0 or item.len_alloc > 0:
      echo item

proc ydb_node_next*(name: string, keys: seq[string]): seq[string] =
  var varname = stringToBuffer(name)
  var idxarr = setupIndex(keys)
  var ret_subs_used: cint = 0
  var ret_subsarray: array[0..31, ydb_buffer_t]
  ret_subsarray[0] = stringToBuffer('\0'.repeat(64), len_used=0)
  ret_subsarray[1] = stringToBuffer('\0'.repeat(64), len_used=0)
  ret_subsarray[2] = stringToBuffer('\0'.repeat(64), len_used=0)
  ret_subsarray[3] = stringToBuffer('\0'.repeat(64), len_used=0)

  var rc:cint = ydb_node_next_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
  rc = ydb_node_next_s(varname.addr, cast[cint](keys.len), idxarr[0].addr, ret_subs_used.addr, ret_subsarray[0].addr)
  #printArray(ret_subsarray)

  if rc == YDB_ERR_INSUFFSUBS:
    echo "INSUFFSUBS2"
  if rc == YDB_ERR_INVSTRLEN:
    echo "INVSTRLEN"
  if rc == YDB_ERR_NODEEND:
    echo "NODEEND"
  if rc == YDB_ERR_PARAMINVALID:
    echo "PARAMINVALID"

  var s = newSeq[string]()
  for item in ret_subsarray:
    if item.len_used > 0:
      s.add($item.buf_addr)
  return s
  #if rc < YDB_OK:
  #  raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  #else:
  #  return $ret_subsarray.buf_addr

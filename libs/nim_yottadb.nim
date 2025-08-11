import strutils, std/strformat


var BUF_32767 = '\0'.repeat(32767)
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


proc stringToBuffer(name: string): ydb_buffer_t =
  var buf = ydb_buffer_t()
  buf.buf_addr = name.cstring
  buf.len_alloc = cast[uint32](len(name)+1)
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
  # setup the global
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  let value = stringToBuffer(value)

  # Save in yottadb
  let rc = ydb_set_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, ydbmsg(rc))


proc ydb_get*(name: string, keys: seq[string]): string =
  # setup the data structures
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  var value = stringToBuffer("")

  # get the length from yottadb signaled with an exception to avoid passing a huge buffer over
  var rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  value = stringToBuffer(' '.repeat(value.len_used))
  rc = ydb_get_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return $value.buf_addr


proc ydb_data*(name: string, keys: seq[string]): int =
  # setup the data structures
  let global = stringToBuffer(name)
  let idxarr = setupIndex(keys)
  var value: cuint = 0
  var rc = ydb_data_s(global.addr, cast[cint](keys.len), idxarr[0].addr, value.addr)
  if rc < YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return cast[int](value)
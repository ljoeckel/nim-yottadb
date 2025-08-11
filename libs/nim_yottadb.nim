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


proc ydbmsg*(status: cint): string =
  if status == YDB_OK: return
  var buf = stringToBuffer(BUF_1024)
  buf.len_used = cast[uint32](0)
  let rc = ydb_message(status, buf.addr)
  if rc == 0:
    return fmt"{status}, " & strip($buf.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc ydb_set*(name: string, keys: openArray[string], value: string) =
  # setup the global
  let global = stringToBuffer(name)
  
  # setup index array (max 31)
  var idxcnt: cint = cast[cint](keys.len)
  var idxarr: array[0..31, ydb_buffer_t]
  for idx in 0 .. keys.len-1:
    idxarr[idx] = stringToBuffer(keys[idx])
  
  # The Value
  let value = stringToBuffer(value)

  # Save in yottadb
  let rc = ydb_set_s(global.addr, idxcnt, idxarr[0].addr, value.addr)
  if rc != YDB_OK:
    raise newException(YottaDbError, ydbmsg(rc))


proc ydb_get*(name: string, keys: varargs[string]): string =
  # setup the global
  let global = stringToBuffer(name)
  
  # setup index array (max 31)
  var idxcnt: cint = cast[cint](keys.len)
  var idxarr: array[0..31, ydb_buffer_t]
  for idx in 0 .. keys.len-1:
    idxarr[idx] = stringToBuffer(keys[idx])

  var buf = stringToBuffer("")
  # get the length from yottadb signaled with an exception to avoid passing a huge buffer over
  var rc = ydb_get_s(global.addr, idxcnt, idxarr[0].addr, buf.addr)
  buf = stringToBuffer(' '.repeat(buf.len_used))
  rc = ydb_get_s(global.addr, idxcnt, idxarr[0].addr, buf.addr)
  if rc != YDB_OK:
    raise newException(YottaDbError, fmt"{ydbmsg(rc)}, Global:{name}{keys}")
  else:
    return $buf.buf_addr
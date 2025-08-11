import strutils, std/strformat


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
  var buf = stringToBuffer(' '.repeat(1024))
  buf.len_used = cast[uint32](0)
  let rc = ydb_message(status, buf.addr)
  if rc == 0:
    return fmt"{status}, " & strip($buf.buf_addr)
  else:
    return fmt"Invalid result from ydb_message for status {status}, result-code: {rc}"


proc ydb_set*(name: string, value: string, keys: varargs[string]) =
  # setup the global
  let global = stringToBuffer(name)
  
  # setup index array
  var idxcnt: cint = cast[cint](keys.len)
  var idxarr: array[0..5, ydb_buffer_t]
  for idx in 0 .. keys.len-1:
    idxarr[idx] = stringToBuffer(keys[idx])
  
  # The Value
  let value = stringToBuffer(value)

  # Save in yottadb
  let rc = ydb_set_s(global.addr, idxcnt, idxarr[0].addr, value.addr)
  if rc != YDB_OK:
    raise newException(YottaDbError, ydbmsg(rc))

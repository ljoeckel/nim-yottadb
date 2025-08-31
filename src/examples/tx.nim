import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import utils

let THS = when compileOption("threads"): "M" else: "S"
let GLOBAL = "^TX" & THS

when compileOption("threads"):
  proc myTxn*(a0: uint64; a1: ptr ydb_buffer_t; p0: pointer): cint {.cdecl, exportc.} =
    let param = $cast[cstring](p0)
    echo "p0:", param, " transaction ID: ", a0, " a1:", repr(a1)
    if a1 != nil:
      echo "Buffer - allocated: ", a1[].len_alloc, ", used: ", a1[].len_used
      if a1[].buf_addr != nil and a1[].len_used > 0:
        echo "Buffer content: ", $a1[].buf_addr
      else:
        echo "Buffer is empty or nil"

    return YDB_OK
else:
# -d:threads:off
  proc myTxn(p0: pointer): cint {.cdecl.} =
    let someParam = $cast[cstring](p0)
    let restarted = parseInt(ydbGet("$TRESTART")) # How many times the proc was called from yottadb

    try:
      let (ms, fibresult) = timed:
        let fib = rand(30..44)
        fibonacci_recursive(fib) # do some cpu intense work
      
      # Increment transaction counter and save application data
      let txid = ydbIncrement("^CNT", @[THS])
      let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}"
      ydbSet(GLOBAL, @[$txid], $data)
    except:
      # Retry a aborted transaction one time, otherwise roll back
      if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

    return YDB_OK # commit the transaction


  # Set transaction timeout to 1 second
  ydbSet("$ZMAXTPTIME", value="1")
  while true:
    let (ms, rc) = timed:
      ydbTxRun(myTxn, "SomeParam")
  
    let txid = ydbGet("^CNT", @[THS]) # get last transaction id
    var data = newYdbVar(GLOBAL, @[$txid])
    data[] = data.value & " overall-time:" & $ms # append overall
    echo "rc=", rc, " ", ms, "ms. txid:", txid, " data:", data
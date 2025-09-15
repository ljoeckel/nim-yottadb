import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import ../libs/utils

when compileOption("threads"):
  {.fatal: "Must be compiled with --threads:off".}

const
  MAX = 1000
  THS = "S"
  GLOBAL = "^TX" & THS

proc myTxn(p0: pointer): cint {.cdecl.} =
  let someParam = $cast[cstring](p0)
  let restarted = parseInt(ydb_get("$TRESTART")) # How many times the proc was called from yottadb

  try:
    let (ms, fibresult) = timed_rc:
      let fib = rand(30..38)
      fibonacci_recursive(fib) # do some cpu intense work
    
    # Increment transaction counter and save application data
    let txid = ydb_increment("^CNT", @[THS])
    let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}"
    ydb_set(GLOBAL, @[$txid], $data)
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  return YDB_OK # commit the transaction


# Set transaction timeout to 1 second
ydb_set("$ZMAXTPTIME", value="1")
for i in 1..MAX:
  let (ms, rc) = timed_rc:
    ydb_tp(myTxn, "SomeParam")

  let txid = ydb_get("^CNT", @[THS]) # get last transaction id
  var data = newYdbVar(GLOBAL, @[$txid])
  data[] = data.value & " overall-time:" & $ms # append overall
  echo "i:", i, " rc=", rc, " ", ms, "ms. txid:", txid, " data:", data
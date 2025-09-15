import std/[random, strformat, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/dsl
import ../libs/yottadb_api
import ../libs/utils

when compileOption("threads"):
  {.fatal: "Must be compiled with --threads:off".}

const
  MAX = 100
  THS = "S"

proc myTxn(p0: pointer): cint {.cdecl.} =
  let someParam = $cast[cstring](p0)
  let restarted = get: $TRESTART().int

  try:
    let (ms, fibresult) = timed_rc:
      let fib = rand(30..43)
      fibonacci_recursive(fib) # do some cpu intense work
    
    # Increment transaction counter and save application data
    let txid = incr: ^CNT(THS)
    let data = fmt"{someParam}, restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}"
    set: ^TXS(txid)=data
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  YDB_OK # commit the transaction


# Set transaction timeout to 1 second
set: $ZMAXTPTIME()="1"
for i in 1..MAX:
  let (ms, rc) = timed_rc:
    ydb_tp(myTxn, "SomeParam" & $i)
  
  let txid = get: ^CNT(THS)
  var data = get: ^TXS(txid)
  data.add(" overall-time:" & $ms)
  set: ^TXS(txid)=data
  echo "i:", i, " rc=", rc, " ", ms, "ms. txid:", txid, " data:", data
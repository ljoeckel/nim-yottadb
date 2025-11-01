when compileOption("threads"):
  {.fatal: "Must be compiled with --threads:off".}

import std/[random, strformat, times]
import yottadb
import ydbutils


const
  MAX = 20
  THS = "S"

# Calculate the highest value to enforce a timeout
let minFibonacci = calcFibonacciValueFor1000ms(50)
let maxFibonacci = calcFibonacciValueFor1000ms(1200)

proc myTxn(p0: pointer): cint {.cdecl.} =
  let someParam = $cast[cstring](p0)
  let restarted = getvar  $TRESTART().int
  if restarted > 0:
    discard increment: ^TXS("restarted")

  try:
    let (ms, fibresult) = timed_rc:
      let fib = rand(minFibonacci .. maxFibonacci)
      fibonacci_recursive(fib) # do some cpu intense work
    
    # Increment transaction counter and save application data
    let txid = increment: ^CNT(THS)
    let data = fmt"{someParam}, restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}"
    setvar: ^TXS(txid)=data
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  YDB_OK # commit the transaction


setvar: $ZMAXTPTIME()="1"
for i in 1..MAX:
  let (ms, rc) = timed_rc:
    ydb_tp(myTxn, "SomeParam" & $i)
  
  let txid = getvar  ^CNT(THS)
  var data = getvar  ^TXS(txid)
  data.add(" overall-time:" & $ms)
  setvar: ^TXS(txid)=data
  echo "i:", i, " rc=", rc, " ", ms, "ms. txid:", txid, " data:", data

assert (getvar ^TXS("restarted").int) > 2
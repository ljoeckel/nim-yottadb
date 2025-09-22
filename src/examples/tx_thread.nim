import std/[random, strformat, strutils, times]
import yottadb
import utils
import malebolgia

# Demonstrates that the txid counter ^CNT("M") stays in a consitent state
# All txid^s must be consecutive.

when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

const
  NUM_OF_THREADS = 4
  ITERATIONS = 10
  THS = "M"
  GLOBAL = "^TX" & THS

# Calculate the highest value to enforce a timeout
let minFibonacci = calcFibonacciValueFor1000ms(50)
let maxFibonacci = calcFibonacciValueFor1000ms(1200)


# tptoken supplied from yottadb. Must be propagated with each call to ydb_set,....
proc myTxnMT*(tptoken: uint64; buff: ptr ydb_buffer_t; param: pointer): cint  {.cdecl.} =
  let tn = $cast[cstring](param)
  let restarted = parseInt(ydb_get("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb

  # Do cpu intense work
  let (ms, fibresult) = timed_rc:
    let fib = rand(minFibonacci .. maxFibonacci)
    fibonacci_recursive(fib) # do some cpu intense work

  try:  
    # Increment a serial number and save application data
    let txid = ydb_increment("^CNT", @[THS], 1, tptoken)
    let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}, tptoken:{tptoken}"
    ydb_set(GLOBAL, @[$txid, tn], $data, tptoken)
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  return YDB_OK # commit the transaction

proc worker(tn: int, iterations: int) =
  ydb_set("$ZMAXTPTIME", value="1") # Set transaction timeout to 1 second
  for cnt in 0..<ITERATIONS:
    let (ms, rc) = timed_rc:
      ydb_tp_mt(myTxnMT, $tn, $cnt)
    
    if rc == YDB_OK:
      let txid = ydb_get("^CNT", @[THS]) # get last transaction id
      var data = newYdbVar(GLOBAL, @[$txid, $tn])
      data[] = data.value & " overall-time:" & $ms # append overall
      echo "tn:", tn, " cnt:", cnt, " txid:", txid, " data: ", data
    else:
      # Should not happen
      echo "Error ", rc, " after running ydb_tp_mt"
      break


when isMainModule:
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

  echo "all finished"
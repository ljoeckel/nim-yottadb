when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

import std/[random, strformat, strutils, times]
import yottadb
import ydbutils
import malebolgia

# Demonstrates that the txid counter ^CNT("M") stays in a consitent state
# All txid^s must be consecutive.


const
  NUM_OF_THREADS = 4
  ITERATIONS = 25
  THS = "M"
  GLOBAL = "^TX" & THS

kill: @GLOBAL
kill: ^CNT

let minFibonacci = calcFibonacciValueFor1000ms(10)
let maxFibonacci = calcFibonacciValueFor1000ms(300)

proc worker(tn: int, iterations: int) =
  setvar: $ZMAXTPTIME = 1 # Set transaction timeout to 1 second

  for cnt in 0..<ITERATIONS:
    # Do cpu intense work
    let (ms, fibresult) = timed_rc:
      let fib = rand(minFibonacci .. maxFibonacci)
      fibonacci_recursive(fib) # do some cpu intense work

    # Save data
    let info = $tn & "," & $fibresult & "," & $ms
    let rc = TransactionMT(info):
      let info = $cast[cstring](param)
      let tnr = info.split(",")[0]
      let fibresult = info.split(",")[1]
      let ms = info.split(",")[2]
      let restarted = parseInt(ydb_get("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb
      let txid = ydb_increment("^CNT", @[THS, tnr], 1, tptoken)
      let data = fmt"tn:{tnr}, restarts:{restarted}, fibresult:{fibresult}, ms:{ms}, tptoken:{tptoken}"
      ydb_set(GLOBAL, @[$txid, $tnr], $data, tptoken)
    
    if rc == YDB_OK:
      let rc = TransactionMT($tn & "," & $ms):
        let info = $cast[cstring](param)
        let tn = info.split(",")[0]
        let ms = info.split(",")[1]
        let txid = ydb_get("^CNT", @[THS, $tn], tptoken=tptoken) # get last transaction id for this thread
        var data = newYdbVar(GLOBAL, @[$txid, $tn], tptoken=tptoken)
        data[] = data.value & " overall-time:" & $ms # append overall
    else:
      # Should not happen
      echo "Error ", rc, " after running ydb_tp_mt"
      break


when isMainModule:
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

  echo "All threads finished"
  listVar("^TXM")
  
  # test results
  for i in 0..<NUM_OF_THREADS:
    let txs = getvar ^CNT("M", i).int
    assert txs == ITERATIONS
  for i in 1..ITERATIONS:
    for tn in 0..<NUM_OF_THREADS:
      assert 1 == data ^TXM(i, tn)

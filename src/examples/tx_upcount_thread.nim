when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

import std/[strutils]
import yottadb
import malebolgia

# Demonstrates that the txid counter ^CNT("M") stays in a consitent state
# All txid^s must be consecutive.

const
  NUM_OF_THREADS = 10
  ITERATIONS = 100000
  GLOBAL = "^CNT"

kill: ^CNT

proc worker(tn: int, iterations: int) =
  setvar: $ZMAXTPTIME = 1 # Set transaction timeout to 1 second

  for cnt in 0..<ITERATIONS:
    # Save data
    let rc = TransactionMT($tn):
      let tptoken = tptoken
      let tn = $cast[cstring](param)
      let txid = ydb_increment("^CNT", @["UPCOUNT"], 1, tptoken)
      ydb_set("^CNT", @[$txid, tn], $txid, tptoken)
      if txid mod 100000 == 0:
        echo "txid=", txid

when isMainModule:
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

  echo "All threads finished"

  assert NUM_OF_THREADS * ITERATIONS == getvar ^CNT("UPCOUNT").int
  assert "" == getvar ^CNT("RESTARTS")

  var cnt = 0
  for keys in nextKeys("^CNT"):
    if keys[0] == "UPCOUNT": continue
    let txid = parseInt(keys[0])
    if txid - cnt == 1:
      cnt = txid
    else:
      raise newException(YdbError, "Numbers are not in sequence")

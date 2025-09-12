import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import ../libs/utils
import malebolgia

# Code serializes the transactions.
# Threads should not do any cpu-bound work
# TODO: Works as expected?

when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

const
  THS = "M"
  GLOBAL = "^TX" & THS

# tptoken supplied from yottadb. Must be propagated with each call to ydb_set,....
proc myTxnMT*(tptoken: uint64; buff: ptr ydb_buffer_t; param: pointer): cint  {.cdecl.} =
  let tn = $cast[cstring](param)
  #echo "a1: alloc:", buff[].len_alloc, ", used: ", buff[].len_used, " addr:", $buff[].buf_addr

  let restarted = parseInt(ydb_get("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb
  let zstatus = ydb_get("$ZSTATUS", tptoken=tptoken)
  echo "restarted:", restarted, " zstatus:", zstatus
  let (ms, fibresult) = timed_rc:
    let fib = rand(30..42)
    fibonacci_recursive(fib) # do some cpu intense work
  try:  
    # Increment a serial number and save application data
    let txid = ydb_increment("^CNT", @[THS], 1, tptoken)
    let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}, tptoken:{tptoken}"
    ydb_set(GLOBAL, @[$txid, tn], $data, tptoken)
  except:
    # Retry a aborted transaction one time, otherwise roll back
    echo "restarted:", restarted, " TP_RESTART/ROLLBACK"
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  return YDB_OK # commit the transaction

proc worker(tn: int, iterations: int) =
  var counter = iterations
  # Set transaction timeout to 1 second
  ydb_set("$ZMAXTPTIME", value="1")
  var tx = 100000
  while counter > 0:
    inc(tx)
    let (ms, rc) = timed_rc:
      ydb_tp_mt(myTxnMT, $tn, $tx)
    
    if rc == YDB_OK:
      try:
        let txid = ydb_get("^CNT", @[THS]) # get last transaction id
        var data = newYdbVar(GLOBAL, @[$txid, $tn])
        data[] = data.value & " overall-time:" & $ms # append overall
        echo "tn:", tn, " counter:", counter, " ms:", ms, " txid:", txid, " data:", data
      except:
        echo "Exception: ", getCurrentExceptionMsg()
    else:
      echo "Error ", rc, " after running ydb_tp_mt"
    
    dec(counter)


when isMainModule:
  const NUM_OF_THREADS = 4
  const ITERATIONS = 100
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

  echo "all finished"
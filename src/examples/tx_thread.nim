import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import utils

const
  THS = "M"
  GLOBAL = "^TX" & THS

# tptoken supplied from yottadb. Must be propagated with each call to ydbSet,....
proc myTxnMT*(tptoken: uint64; buff: ptr ydb_buffer_t; param: pointer): cint  {.cdecl.} =
  let param = $cast[cstring](param)
  if buff != nil:
    echo "a1: alloc:", buff[].len_alloc, ", used: ", buff[].len_used, " addr:", $buff[].buf_addr

  let restarted = parseInt(ydbGet("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb
  let (ms, fibresult) = timed:
    let fib = rand(30..38)
    fibonacci_recursive(fib) # do some cpu intense work
  try:  
    # Increment transaction counter and save application data
    let txid = ydbIncrement("^CNT", @[THS], 1, tptoken)
    let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}, tptoken:{tptoken}"
    ydbSet(GLOBAL, @[$txid], $data, tptoken)
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  return YDB_OK # commit the transaction

# Set transaction timeout to 1 second
ydbSet("$ZMAXTPTIME", value="1")
var tx = 100000
while true:
  inc(tx)
  let (ms, rc) = timed:
    ydbTxRunMT(myTxnMT, "SomeParam", $tx)
  
  echo "after timed: ms:", ms, " rc:", rc
  try:
    let txid = ydbGet("^CNT", @[THS]) # get last transaction id
    var data = newYdbVar(GLOBAL, @[$txid])
    data[] = data.value & " overall-time:" & $ms # append overall
    echo "rc=", rc, " ", ms, "ms. txid:", txid, " data:", data
  except:
    echo "Some problem after call"
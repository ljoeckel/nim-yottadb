# YottaDB commands

## Enable / Disable Journaling
Show current status:
```bash
mupip journal -show=all -fo yottadb.mjl
```
Enable or Disable journaling
```bash
mupip set -journal=enable -region '*'
mupip set -journal=disable -region '*'
```
Extract the journal. Use -global if you want to see a specific global. See `mupip help` for all options
```bash
mupip journal -forward -extract -global="^x.." yottadb.mjl 
```

## Transactions
Transactions are implemented in a callable proc

```nim
proc myTxnMT*(tptoken: uint64; buff: ptr ydb_buffer_t; param: pointer): cint  {.cdecl.} =
  let param = $cast[cstring](param)
  if buff != nil:
    echo "a1: alloc:", buff[].len_alloc, ", used: ", buff[].len_used, " addr:", $buff[].buf_addr

  let restarted = parseInt(ydb_get("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb
  let (ms, fibresult) = timed:
    let fib = rand(30..38)
    fibonacci_recursive(fib) # do some cpu intense work
  try:  
    # Increment a counter and save application data
    let txid = ydb_increment("^CNT", @[THS], 1, tptoken)
    let data = fmt"restarts:{restarted}, fib:{fib} result:{fibresult} time:{ms}, tptoken:{tptoken}"
    ydb_set(GLOBAL, @[$txid], $data, tptoken)
  except:
    # Retry a aborted transaction one time, otherwise roll back
    if restarted == 0: return YDB_TP_RESTART else: return YDB_TP_ROLLBACK

  return YDB_OK # commit the transaction
  ```

This proc will be called by YottaDB. A **tptoken** will be passed to the proc. The **tptoken** must then be passed to all subsequent calls that involves YottaDB.

A call to **ydb_tp_mt** initiates the processing inside a database transaction.
```nim
# Set transaction timeout to 1 second
ydb_set("$ZMAXTPTIME", value="1")
let (ms, rc) = timed:
  ydb_tp(myTxn, "SomeParam")

let txid = ydb_get("^CNT", @[THS]) # get last transaction id
var data = newYdbVar(GLOBAL, @[$txid])
data[] = data.value & " overall-time:" & $ms # append overall
echo "rc=", rc, " ", ms, "ms. txid:", txid, " data:", data
```

The following output is extracted from the journal. Command is *mupip journal -forward -extract -global="^TXM" yottadb.mjl*

05\67449,41297\1172603860\306121\0\1314779683618836\0\0\2\0\^TXM(795)="restarts:0, fib:33 result:3524578 time:144, tptoken:144115188075855892"
09\67449,41297\1172603860\306121\0\1314779683618836\0\0\1\ **100020**

The bold parameter is the user supplied 'user_transaction_id'
```nim
ydb_tp_mt(myTxnMT, "SomeParam", user_transaction_id)
  ```

This applies only to the Multi-Threaded environmen (nim c --threads:on tx_thread.nim)


## Transaction Timeout
$ZMAXTPTI[ME] contains an integer value indicating the time duration, in seconds, YottaDB should wait for the completion of all activities fenced by the current transaction's outermost TSTART/TCOMMIT pair.

$ZMAXTPTIME takes its value from the environment variable ydb_maxtptime. If ydb_maxtptime is not defined, the initial value of $ZMAXTPTIME is zero (0) seconds which indicates "no timeout" (unlimited time). The value of $ZMAXTPTIME when a transaction's outermost TSTART operation executes determines the timeout setting for that transaction.
import strutils
import std/[os]
import ../yottadb

proc myTxn(p0: pointer): cint {.cdecl.} =
  let param = $cast[cstring](p0)
  let restarted = parseInt(ydbGet("$TRESTART"))
  echo "ztrap:", ydbGet("$ZTRAP"), " etrap:", ydbGet("$ETRAP")
  echo "stack:", ydbGet("$STACK")
  
  echo "Inside YottaDB transaction, got param: <", $param, "> restarted:", restarted

  if restarted < 3:
    let maxval = parseInt(param)
    for i in 0..<maxval:
      sleep(100)
      try:
        ydbSet("^TX", @[$param, $i], $i)
      except:
        echo "Rolling back the transaction on exception ", getCurrentExceptionMsg()
        return YDB_TP_ROLLBACK
      echo "saved ", $i
    return YDB_TP_RESTART
  return YDB_OK

let rc = TxStart(myTxn, "11", "txid4711")
echo "rc=", rc

import std/[os, cmdline]
import yottadb
import ydbutils

let pid = getvar $JOB
const STEPS = 100
const CLIENTS = 10

proc businessTransaction(p0: pointer): cint {.cdecl.} =
  try:
    var value = increment ^CNT("up").int
  except:
      echo getCurrentExceptionMsg(), " # of restarts:", $(getvar $TRESTART)
      return YDB_TP_RESTART
  YDB_OK

proc runClient() =
  for i in 1..STEPS:
    var rc = ydb_tp(businessTransaction, $pid & $i)
  setvar: ^Pids(pid) = pid # mark complete


if isMainModule:
    let params = commandLineParams()
    if params.len == 0:
      kill: ^CNT
      kill: ^Pids 

      var clients = CLIENTS
      for i in 1..clients:
          let processID = job("./tx_upcount", @[$i])

      # Wait for client's
      while clients > 0:
        var (rc, gbl) = nextnode ^Pids
        while rc == YDB_OK:
          if 1 == data @gbl:
            let pid = getvar @gbl.int
            closeJob(pid)
            killnode: @gbl
            dec clients
          (rc, gbl) = nextnode @gbl
        nimSleep(100)
      echo "All clients have stoped"

      # Read Result
      echo "^CNT(up)=", getvar ^CNT("up")
      assert CLIENTS * STEPS == getvar ^CNT("up").int

    else:
      # init the client here
      let logFile = open("log" & params[0] & ".log", fmWrite)
      stdout = logFile
      stderr = logFile
      runClient()

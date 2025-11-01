when compileOption("threads"):
  {.fatal: "Must be compiled with --threads:off".}

import std/[os, cmdline, strutils]
import yottadb
import ydbutils


let pid = getvar $JOB
const 
  STEPS = 1000
  CLIENTS = 10
  cntUp = "^CNT(UPCOUNT)"
  cntRestart = "^CNT(RESTART)"
  cntData = "^CNTDATA"

proc runClient() =
  for i in 1..STEPS:
    let rc = Transaction(pid):
      var value = increment @cntUp
      setvar: @cntData(value, pid) = value
      let pid = cast[cstring](param)
      let restart = getvar $TRESTART.int
      if restart > 0:
        discard increment @cntRestart
      
  setvar: ^Pids(pid) = pid # mark complete


if isMainModule:
    let params = commandLineParams()
    if params.len == 0:
      kill: 
        ^CNT
        ^CNTDATA
        ^Pids 

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
      echo "^CNT(up)=", getvar @cntUp
      assert (CLIENTS * STEPS) == getvar @cntUp.int
      echo "^CNT(restart)=", getvar @cntRestart

      var cnt = 0
      for keys in nextKeys(cntData):
        let txid = parseInt(keys[0])
        if txid - cnt == 1:
          cnt = txid
        else:
          raise newException(YdbError, "Numbers are not in sequence")


    else:
      # init the client here
      # let logFile = open("log" & params[0] & ".log", fmWrite)
      # stdout = logFile
      # stderr = logFile
      runClient()

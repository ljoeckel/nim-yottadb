when compileOption("threads"):
  {.fatal: "Must be compiled with --threads:off".}

import std/[os, cmdline, strutils]
import yottadb
import ydbutils


let pid = Get $JOB
const 
  STEPS = 1000
  CLIENTS = 10
  cntUp = "^CNT(UPCOUNT)"
  cntRestart = "^CNT(RESTART)"
  cntData = "^CNTDATA"

proc runClient() =
  for i in 1..STEPS:
    let rc = Transaction(pid):
      var value = Increment @cntUp
      Set: @cntData(value, pid) = value
      let pid = cast[cstring](param)
      let restart = Get $TRESTART.int
      if restart > 0:
        discard Increment @cntRestart
      
  Set: ^Pids(pid) = pid # mark complete


if isMainModule:
    let params = commandLineParams()
    if params.len == 0:
      Kill: 
        ^CNT
        ^CNTDATA
        ^Pids 

      var clients = CLIENTS
      for i in 1..clients:
          let processID = job("./tx_upcount", @[$i])

      # Wait for client's
      while clients > 0:
        for pid in QueryItr ^Pids.val:
            closeJob(parseInt(pid))
            Killnode: ^Pids(pid)
            dec clients
        nimSleep(100)
      echo "All clients have stoped"

      # Read Result
      echo "^CNT(up)=", Get @cntUp
      assert (CLIENTS * STEPS) == Get @cntUp.int
      echo "^CNT(restart)=", Get @cntRestart

      var cnt = 0
      for keys in QueryItr @cntData.keys:
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

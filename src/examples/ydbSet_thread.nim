import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import utils
import malebolgia

when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

const
  GLOBAL = "^ydbSet"

proc worker(tn: int, iterations: int) =
  var counter = iterations
  while counter > 0:
    try:
      let txid = ydbIncrement("^CNT", @["ydbSet"])
      #echo "tn:", tn, " tx:", txid, " cnt:", counter
      ydbSet(GLOBAL, @[$txid], "This is some test from thread " & $tn)
    except:
      echo "Exception: ", getCurrentExceptionMsg()
    dec(counter)


when isMainModule:
  const NUM_OF_THREADS = 4
  const ITERATIONS = 1000000
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

  echo "all finished"
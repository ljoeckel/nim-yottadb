import std/[random, strformat, strutils, times]
import ../libs/yottadb_types
import ../libs/libyottadb
import ../libs/yottadb_api
import ../libs/dsl
import ../libs/utils
import malebolgia

when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

proc worker(tn: int, iterations: int) = # Duration 25264 ms.
  var counter = iterations
  while counter > 0:
    try:
      let txid = ydbIncrement("^CNT", @["ydbSet"])
      ydbSet("^ydbSet", @[$txid], "This is some test from thread " & $tn)
    except:
      echo "Exception: ", getCurrentExceptionMsg()
    dec(counter)

proc worker_dsl(tn: int, iterations: int) = # Duration 24606 ms.
  var counter = iterations
  while counter > 0:
    try:
      let txid = incr: ^CNT("ydbSet")
      set: ^ydbSet(txid) = "This is some test from thread " & $tn
    except:
      echo "Exception: ", getCurrentExceptionMsg()
    dec(counter)

proc main(): int =
  const NUM_OF_THREADS = 4
  const ITERATIONS = 1000000
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

proc main_dsl(): int =
  const NUM_OF_THREADS = 4
  const ITERATIONS = 1000000
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker_dsl(tn, ITERATIONS)


when isMainModule:
  var (ms, rc) = timed:
    main()

  (ms, rc) = timed:
    main_dsl()
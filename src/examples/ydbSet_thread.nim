import std/[times]
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
      let txid = ydb_increment("^CNT", @["ydb_set"])
      ydb_set("^YDB", @[$txid], "This is some test from thread " & $tn)
    except:
      echo "Exception simple-api: ", getCurrentExceptionMsg()
    dec(counter)

proc worker_dsl(tn: int, iterations: int) = # Duration 24606 ms.
  var counter = iterations
  while counter > 0:
    try:
      let txid = incr: ^CNT("ydb_set")
      set: ^YDB(txid) = "This is some test from thread " & $tn
    except:
      echo "Exception dsl: ", getCurrentExceptionMsg()
    dec(counter)

proc main() =
  const NUM_OF_THREADS = 2
  const ITERATIONS = 100000
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker(tn, ITERATIONS)

proc main_dsl() =
  const NUM_OF_THREADS = 2
  const ITERATIONS = 100000
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn worker_dsl(tn, ITERATIONS)


proc count_data(): int =
  var cnt = 0
  var rc = YDB_OK
  var node:Subscripts = @[]
  while rc == YDB_OK:
    (rc, node) = nextn: ^YDB(node)
    if rc == YDB_OK:
      inc(cnt)
  cnt

when isMainModule:
  # Reset counter
  delnode: ^CNT("ydb_set")

  timed("main"): main()
  timed("main_dsl"): main_dsl()
  timed_rc("count_data"): count_data()
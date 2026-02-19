when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

import std/[times]
import tables
import yottadb
import ydbutils
import malebolgia


const
  NUM_OF_THREADS = 2
  ITERATIONS = 100000

template worker(body: untyped) =
  for i in 0..<ITERATIONS:
    try:
      body
    except:
      echo "Exception: ", getCurrentExceptionMsg()

proc api(tn: int) =
  worker:
    let txid = ydb_increment("^CNT", @["ydb_set"])
    ydb_set("^YDB", @[$txid], "This is some test from api thread " & $tn)

proc dsl(tn: int) =
  worker:
    let txid = Increment: ^CNT("ydb_set")
    Set: ^YDB(txid) = "This is some test from dsl thread " & $tn

template main(workerProc: untyped) =
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<NUM_OF_THREADS:
      m.spawn: workerProc(tn)


proc count_data(): int =
  var
    cnt, rc:int = 0
    node:Subscripts
    thm = initCountTable[char]()

  for (key, value) in QueryItr ^YDB.kv:
    inc(cnt)
    let tn = value[^1]
    thm.inc(tn)

  echo "Count by thread: ", thm
  cnt


when isMainModule:
  # Reset counters
  Killnode: ^CNT("ydb_set")

  timed("main"): main(api)
  timed("main_dsl"): main(dsl)
  timed_rc("count_data"): count_data()
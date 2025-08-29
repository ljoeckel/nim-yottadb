import std/[strutils, unittest]
import std/[times]
import std/threadpool
import std/sets

import ../yottadb

# nim -c r --threads:on yottadb_test_threaded

const
  MAX = 1000
  NUM_OF_THREADS = 2

template timed(body: untyped): untyped =
  let t1 = getTime()
  body
  echo getTime() - t1

proc initDB() =
  for i in 0..<NUM_OF_THREADS:
    assert YDB_OK == ydbDeleteTree("^COUNTERS", @[$i])

  assert YDB_OK == ydbDeleteNode("^COUNTERS", @["cnt"])

proc testIncrement(tn: int): int =
  timed:
    let key = @["cnt"]
    #ydbSet("^COUNTERS", key, "0")
    for i in 0..<MAX:
      result = ydbIncrement("^COUNTERS", key)
      ydbSet("^COUNTERS", @[$tn, $i], $result)

proc validateCounters() =
  var results = initHashSet[int](MAX*NUM_OF_THREADS+1)
  var key = @[""]
  for key in nextNodeIter("^COUNTERS", key):
    let value = parseInt(ydbGet("^COUNTERS", key))
    results.incl(value)

  # Test the number of entries (must be 2xMAX)
  assert results.len == MAX * NUM_OF_THREADS
  # Test if each number is found in the set
  for i in 1..MAX*NUM_OF_THREADS:
    assert results.contains(i) == true
  
# -------------------------------------------------------------------

proc incrementTest() =
  echo "incrementTest"
  var results = newSeq[FlowVar[int]](NUM_OF_THREADS)
  for i in 0..<NUM_OF_THREADS:
    results[i] = spawn testIncrement(i)

  for i in 0..<NUM_OF_THREADS:
    let res = ^results[i]
    echo "result ",i, $res

  validateCounters()

when isMainModule:
  initDB()
  incrementTest()


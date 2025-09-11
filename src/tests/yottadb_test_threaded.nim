import std/[strutils, unittest]
import std/[times]
import malebolgia
import std/sets

import ../yottadb

# nim -c r --threads:on yottadb_test_threaded

const
  MAX = 100
  NUM_OF_THREADS = 4
  GLOBAL = "^COUNTERS"
  MAX_FIBONACCI_NUMBER = 32

template timed(body: untyped): untyped =
  let t1 = getTime()
  body
  echo getTime() - t1

proc initDB() =
  ## Clean the database
  var keys:Subscripts = @[]
  for keys in nextNodeIter(GLOBAL, keys):
    ydbDeleteNode(GLOBAL, keys)

proc fibonacci_recursive(n: int): int =
  ## Simulate some CPU intense work
  if n <= 1:
    result = n
  else:
    result = fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)

proc calcFinonacciSum(): int =
  for j in 0..<MAX_FIBONACCI_NUMBER:
    let x = fibonacci_recursive(j)
    result += x

proc testIncrement(tn: int) =
  ## For each thread iterate to MAX and calculate the fibonacci and save in db
  let key = @["cnt"]
  for i in 0..<MAX:
    let result = ydbIncrement(GLOBAL, key)
    let sum = calcFinonacciSum()
    ydbSet(GLOBAL, @[$tn, $result], $sum)

proc validateCounters() =
  ## Validate if all data is correctly saved in the db
  
  # Check increment in db
  assert MAX * NUM_OF_THREADS == parseInt(ydbGet(GLOBAL, @["cnt"]))

  var results = initHashSet[int](MAX*NUM_OF_THREADS+1)
  var key = @[""]
  var cntidx = 0
  let fibo = calcFinonacciSum()

  for key in nextNodeIter(GLOBAL, key):
    if key[0] == "cnt": continue
    results.incl(parseInt(key[1])) # 1..max*num_of_threads
    inc(cntidx)
    let value = parseInt(ydbGet(GLOBAL, key))
    assert value == fibo

  # check the number of results in the db
  assert cntidx == MAX * NUM_OF_THREADS

  # Test if each number is found in the set
  for i in 1..MAX*NUM_OF_THREADS:
    assert results.contains(i) == true

# -------------------------------------------------------------------

proc fibonacciTest() =
  ## Main test that starts NUM_OF_THREADS to calculate and save result in db
  var m = createMaster()
  m.awaitAll:
    for i in 0..<NUM_OF_THREADS:
      m.spawn testIncrement(i)

  validateCounters()

  
when isMainModule:
  timed: test "initdb": initDB()
  timed: test "fibonacci": fibonacciTest()
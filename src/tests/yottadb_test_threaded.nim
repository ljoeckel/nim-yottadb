when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

import std/[strutils, unittest, times, sets]
import malebolgia
import yottadb
import ydbutils


const
  MAX = 50
  NUM_OF_THREADS = 4
  MAX_FIBONACCI_NUMBER = 30
  gbl = "^COUNTERS"
  counter = "^COUNTERS(cnt)"

proc initDB() =
  Kill: @gbl

proc fibonacci_recursive(n: int): int =
  ## Simulate some CPU intense work
  if n <= 1:
    result = n
  else:
    result = fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)

proc calcFibonacciSum(): int =
  for j in 0..<MAX_FIBONACCI_NUMBER:
    result += fibonacci_recursive(j)

proc testIncrement(tn: int) =
  ## For each thread iterate to MAX and calculate the fibonacci and save in db
  for i in 0..<MAX:
    withlock(0):
      discard Increment: COUNTER(0)     # Increment thread shared counter

    let result = Increment @counter
    let sum = calcFibonacciSum()
    Set: @gbl($tn, $result) = sum

proc validateCounters() =
  # Validate if all Data is correctly saved in the db
  assert MAX * NUM_OF_THREADS == Get @counter.int

  var results = initHashSet[int](MAX*NUM_OF_THREADS+20)
  var cntidx = 0
  let fibo = calcFibonacciSum()

  for keys in QueryItr(@gbl.keys):
    if keys[0] == "cnt": continue
    inc cntidx
    results.incl(parseInt( keys[1])) # 0..max
  assert cntidx == MAX * NUM_OF_THREADS

  # check the number of results in the db
  assert Get(COUNTER(0).int) == cntidx

  # Test if each number is found in the set
  for i in 1..<MAX*NUM_OF_THREADS - 1:
    assert results.contains(i)

# -------------------------------------------------------------------

proc fibonacciTest() =
  ## Main test that starts NUM_OF_THREADS to calculate and save result in db
  Set: COUNTER(0) = 0 # ydb local variable is visible for all threads, must be synchronized

  var m = createMaster()
  m.awaitAll:
    for i in 0..<NUM_OF_THREADS:
      m.spawn testIncrement(i)

  validateCounters()

  
when isMainModule:
  timed: test "initdb": initDB()
  timed: test "fibonacci": fibonacciTest()
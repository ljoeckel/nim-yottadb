import std/strutils
import std/sets
import std/[unittest]
import yottadb
import ydbutils

proc setup() =
    Kill:
      ^tmp
      ^images

const
    BLOCKSIZES = [512, 1024, 1025, 2048, 2049, 8192, 16384, 32767, 65535, 131073, 262146]
var KB = newStringOfCap(1024)
for j in 0..<4:
    for i in 0 .. 255:
        KB.add(i.char)


proc createBinData(kb: int): string =
  # create a binary string
  result = newStringOfCap(1024*kb)
  for i in 0..<kb:
    result.add(KB)


proc testBinaryPostfix() =
  Set: ^tmp("binary") = createBinData(1)
  let dbval = Get ^tmp("binary").binary
  assert dbval == createBinData(1)

  # Create binary Data upto 1MB
  for i in 4095 .. 4096:
    Set: ^tmp("binary", i) = createBinData(i)

  # Read back an compare
  for i in 4095 .. 4096:
    let dbval = Get ^tmp("binary", i).binary
    assert dbval == createBinData(i)


proc testBinaryPostfixHugeWrite(): int =
  Kill: ^tmphuge
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    Set: ^tmphuge(size) = data
  return totalBytes

proc testBinaryPostfixHugeRead(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmphuge(size).binary
    inc(totalBytes, data.len)
  return totalBytes

proc testBinaryPostfixHugeVerify(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    let dbval = Get ^tmphuge(size).binary
    inc(totalBytes, dbval.len)
    assert data == dbval
  return totalBytes

proc testOrderedSetPostfix() =
  var os = initOrderedSet[int]()
  for i in 0 .. 255:
    os.incl(i)
  
  # os: {0, 1, 2, 3, 4, ...}
  Set: ^tmp("set1") = os
  let dbset = Get ^tmp("set1")
  assert dbset == $os
  let osdb = Get ^tmp("set1").OrderedSet
  assert $type(osdb) == $type(OrderedSet[int])
  assert osdb == os

  # os 0,1,2,3,...
  var str = ($os)[1..^2] # remove {}
  Set: ^tmp("set2") = str.replace(" ","") # trim spaces
  let osdb2 = Get ^tmp("set2").OrderedSet
  assert $type(osdb2) == $type(OrderedSet[int])
  assert osdb2 == os
  


proc testGetFast(iterations: int) =
  Set: ^tmp(4711)="01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  echo "Using 'get.binary' with ", iterations, " iterations."
  timed:
    for i in 0 .. iterations:
      discard Get ^tmp(4711).binary

  echo "Using 'get' with ", iterations, " iterations."
  timed:
    for i in 0 .. iterations:
      discard Get ^tmp(4711)
  

proc testGetWithException() =
  var maxlen = 1024*1024 - 1
  Set: ^tmp(4711) = repeat(".", maxlen)
  var val = Get ^tmp(4711)
  assert val.len == maxlen

  Set: ^tmp(4712) = repeat(".", maxlen+1)
  doAssertRaises(YdbError): val = Get ^tmp(4712)

if isMainModule:
  test "binary": testBinaryPostfix()
  test "binary huge write": 
      var (ms, rc) = timed_rc: testBinaryPostfixHugeWrite()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024

  test "binary huge read": 
      var (ms, rc) = timed_rc: testBinaryPostfixHugeRead()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

  test "binary huge verify": 
      var (ms, rc) = timed_rc: testBinaryPostfixHugeVerify()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

  test "setOrderedSetPostfix": testOrderedSetPostfix()
  test "get with recordlen 1MB - 1", testGetWithException()
  test "getfast": testGetFast(1_000_000)
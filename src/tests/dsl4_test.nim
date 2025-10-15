import std/strutils
import std/sets
import std/[unittest]
import yottadb
import utils

proc testSetGet() =
  setvar: gbl(1) = 1
  assert get(gbl(1)) == "1"
  assert get(gbl(1).int) == 1
  assert get(gbl(1).float) == 1.0

  setvar: gbl(1, 1) = 1
  assert get(gbl(1, 1)) == "1"
  assert get(gbl(1, 1).int) == 1
  assert get(gbl(1, 1).float) == 1.0

  setvar: gbl("11") = 11
  assert get(gbl("11")) == "11"
  assert get(gbl("11").int) == 11
  assert get(gbl("11").float) == 11.0

  setvar: gbl("11", "1") = 11.1
  assert get(gbl("11", "1")) == "11.1"
  doAssertRaises(ValueError): discard get(gbl("11", "1").int)
  assert get(gbl("11", "1").float) == 11.1

  let id = 2
  setvar: gbl(id) = id
  assert get(gbl(id)) == "2"
  assert get(gbl(id).int) == 2
  assert get(gbl(id).float) == 2.0

  setvar: gbl(id + 10) = 12
  assert get(gbl(id + 10)) == "12"
  assert get(gbl(id + 10).int) == 12
  assert get(gbl(id + 10).float) == 12.0

  setvar: gbl(id + 10, id) = 12
  assert get(gbl(id + 10, id)) == "12"
  assert get(gbl(id + 10, id).int) == 12
  assert get(gbl(id + 10, id).float) == 12.0

  setvar: gbl(id + 10, id, "x") = 12
  assert get(gbl(id + 10, id, "x")) == "12"
  assert get(gbl(id + 10, id, "x").int) == 12
  assert get(gbl(id + 10, id, "x").float) == 12.0

  let id2 = @["3"]
  setvar: gbl(id2) = 3
  assert get(gbl(id2)) == "3"
  assert get(gbl(id2).int) == 3
  assert get(gbl(id2).float) == 3.0

  let id3 = @["3", "x"]
  setvar: gbl(id3) = 3
  assert get(gbl(id3)) == "3"
  assert get(gbl(id3).int) == 3
  assert get(gbl(id3).float) == 3.0

proc testSetGetSingleVar() =
  setvar: localvar="xyz"
  assert "xyz" == get(localvar)
  assert "xyz" == get localvar

  setvar:
      localvar2 = "abc"
      localvar3 = "def"
  assert "abc" & "def" == get(localvar2) & get(localvar3)
  assert "abc" & "def" == (get localvar2) & (get localvar3)

  setvar: ^gbl = "abc"
  assert "abc" == get(^gbl)
  assert "abc" == get ^gbl 

  setvar:
      ^gbl1="gbl1"
      ^gbl2="gbl2"
  assert "gbl1" & "gbl2" == get(^gbl1) & get(^gbl2)
  assert "gbl1" & "gbl2" == (get ^gbl1) & (get ^gbl2)

  setvar:
      ^gbl(1)="gbl1"
      ^gbl(2)="gbl2"
  assert "gbl1" & "gbl2" == get(^gbl(1)) & get(^gbl(2))
  assert "gbl1" & "gbl2" == (get ^gbl(1)) & (get ^gbl(2))


proc teststr2zwr() =
  discard str2zwr("hello\9World")
  assert str2zwr("hello\9World") == """"hello"_$C(9)_"World""""
  assert str2zwr("\0hello\9World") == """$C(0)_"hello"_$C(9)_"World""""
  assert str2zwr("\0hello\9World\0\0") == """$C(0)_"hello"_$C(9)_"World"_$C(0,0)"""

  let s = "\0hello\9World\0\0"
  assert str2zwr(s) == """$C(0)_"hello"_$C(9)_"World"_$C(0,0)"""
  doAssertRaises(YdbError): discard str2zwr(repeat("\0", 520223)) # we limit that to max 1mb output TODO: membuffers grow dynamically

proc testzwr2str() =
  assert zwr2str(""""hello"_$C(9)_"World"""") == "hello\9World"
  assert zwr2str("""$C(0)_"hello"_$C(9)_"World"""") == "\0hello\9World"
  assert zwr2str("""$C(0)_"hello"_$C(9)_"World"_$C(0,0)""") == "\0hello\9World\0\0"
  let s = str2zwr(repeat("\1", 520222))
  assert s.len == 1048575
  assert zwr2str(s) == repeat("\1", 520222)
  assert zwr2str(s).len == 520222

proc createBinData(kb: int): string =
  # create a binary string
  var binval: string
  for i in 0 .. 255:
    binval.add(i.char)
  repeat(binval, kb*4)


proc testBinaryPostfix() =
  setvar: ^tmp("binary") = createBinData(1)
  let dbval = getblob: ^tmp("binary")
  assert dbval == createBinData(1)

  # Create binary data upto 1MB
  for i in 4095 .. 4096:
    setvar: ^tmp("binary", i) = createBinData(i)

  # Read back an compare
  for i in 4095 .. 4096:
    let dbval = getblob(^tmp("binary", i))
    assert dbval == createBinData(i)


proc testBinaryPostfixHugeWrite(): int =
  deleteGlobal("^tmphuge")
  var totalBytes = 0
  for size in [512, 1024, 1025, 2048, 2049, 8192, 16384, 32767, 65535, 131073]:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    setvar: ^tmphuge(size) = data
  return totalBytes

proc testBinaryPostfixHugeRead(): int =
  var totalBytes = 0
  for size in [512, 1024, 1025, 2048, 2049, 8192, 16384, 32767, 65535, 131073]:
    let data = getblob(^tmphuge(size))
    inc(totalBytes, data.len)
  return totalBytes

proc testBinaryPostfixHugeVerify(): int =
  var totalBytes = 0
  for size in [512, 1024, 1025, 2048, 2049, 8192, 16384, 32767, 65535, 131073]:
    let data = createBinData(size)
    let dbval = getblob(^tmphuge(size))
    inc(totalBytes, dbval.len)
    assert data == dbval
  return totalBytes

proc testOrderedSetPostfix() =
  var os = initOrderedSet[int]()
  for i in 0 .. 255:
    os.incl(i)
  
  # os: {0, 1, 2, 3, 4, ...}
  setvar: ^tmp("set1") = os
  let dbset = get: ^tmp("set1")
  assert dbset == $os
  let osdb = get: ^tmp("set1").OrderedSet
  assert $type(osdb) == $type(OrderedSet[int])
  assert osdb == os

  # os 0,1,2,3,...
  var str = ($os)[1..^2] # remove {}
  setvar: ^tmp("set2") = str.replace(" ","") # trim spaces
  let osdb2 = get: ^tmp("set2").OrderedSet
  assert $type(osdb2) == $type(OrderedSet[int])
  assert osdb2 == os
  
proc testIncrementLocalsByOne() =
  setvar: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    let keys = @["X","Y","Z"]
    CNT(keys)=3000

  # Increment by 1
  for i in 1..10:
    let cnt = increment: CNT("1,1")
    assert cnt == 1000 + i
    assert get(CNT("1,1").int) == 1000 + i

    let c = increment: CNT(2,2)
    assert c == 2000 + i
    assert get(CNT(2,2).int) == 2000 + i

    let d = increment(CNT(keys))
    assert d == 3000 + i
    assert get(CNT(keys).int) == 3000 + i

    assert 1 == increment(CNT(i))

proc testIncrementLocalsByTen() =
  setvar: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    let keys = @["X","Y","Z"]
    CNT(keys)=3000

  # Increment by 10
  for i in 1..10:
    let cnt = increment: CNT("1,1", by=10)
    assert cnt == 1000 + i*10
    assert get(CNT("1,1").int) == 1000 + i*10

    let c = increment: CNT(2,2, by=10)
    assert c == 2000 + i*10
    assert get(CNT(2,2).int) == 2000 + i*10

    let d = increment: CNT(keys, by=10)
    assert d == 3000 + i*10
    assert get(CNT(keys).int) == 3000 + i*10

    let e = increment: CNT(i, by=10)
    assert 11 == e

proc testIncrementBy() =
    delnode: ^CNT("XXX")
    var x = increment: ^CNT("XXX")
    assert x == 1
    x = increment: ^CNT("XXX", by=100)
    assert x == 101

    for i in 0..10:
        var z = increment local("abc", by=5)
        assert z == i * 5 + 5

    delnode ^CNT("XXX")
    for i in 0..10:
        var z = increment ^CNT("XXX", by=5)
        assert z == i * 5 + 5


proc testGetFast(iterations: int) =
  setvar: ^tmp(4711)="01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  echo "Using 'getblob' with ", iterations, " iterations."
  timed:
    for i in 0 .. iterations:
      let val = getblob(^tmp(4711))

  echo "Using 'get' with ", iterations, " iterations."
  timed:
    for i in 0 .. iterations:
      let val = get(^tmp(4711))
  

proc testGetWithException() =
  var maxlen = 1024*1024 - 1
  setvar: ^tmp(4711) = repeat(".", maxlen)
  var val = get(^tmp(4711))
  assert val.len == maxlen

  setvar: ^tmp(4712) = repeat(".", maxlen+1)
  doAssertRaises(YdbError): val = get(^tmp(4712))

when isMainModule:
  suite "Locals Tests":
    test "set/get": testSetGet()
    test "set/get single var", testSetGetSingleVar()
    test "str2zwr": teststr2zwr()
    test "zwr2str": testzwr2str()
    test "binary": testBinaryPostfix()
    test "binary huge write": 
      var (ms, rc) = timed_rc: 
        testBinaryPostfixHugeWrite()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read": 
      var (ms, rc) = timed_rc: 
        testBinaryPostfixHugeRead()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge verify": 
      var (ms, rc) = timed_rc: 
        testBinaryPostfixHugeVerify()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "setOrderedSetPostfix": testOrderedSetPostfix()
    test "increment by": testIncrementBy()
    test "increment locals by one": testIncrementLocalsByOne()
    test "increment locals by ten": testIncrementLocalsByTen()

    test "get with recordlen 1MB - 1", testGetWithException()
    test "getfast": testGetFast(10_000_000)
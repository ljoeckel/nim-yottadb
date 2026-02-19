import std/[times, unittest, strformat]
import yottadb


proc setGetSingleMulti() =
    Set: ^tmp = 1
    Set:
        ^tmp1 = 1
        ^tmp2 = 2
    Set:
        ^tmp2=2
        ^tmp3=3
    
    assert "1" == Get ^tmp
    assert "1" == Get ^tmp1
    assert "2" == Get ^tmp2
    assert "3" == Get ^tmp3

proc setGetInfix() =
    Set: ^tmp = 1
    Set:
        ^tmp(10) = 10
        ^tmp(20) = 20
    
    let id = 10
    assert "10" == Get ^tmp(id)
    assert "20" == Get ^tmp(id + 10)

    Set: ^tmp(id + 30) = 30
    assert "30" == Get ^tmp(id + 30)

    for i in 0..100:
      Set: ^tmp(i + 1000 * 2) = i + 1000 * 2
    for i in 0..100:
      assert (i + 1000 * 2) == Get ^tmp(i + 1000 * 2).int

    let subs: Subscripts = @[$id]
    assert "10" == Get ^tmp(subs)
    let subs2: Subscripts = @[$(id + 10)]
    assert "20" == Get ^tmp(subs2)
   
    # With infix
    Set: ^X(id + 10) = 10
    assert 10 == Get ^X(id + 10).int
    echo fmt("echo ^X(id + 10).float = {Get ^X(id + 10).float}")
  

proc setWithSubscript() =
  var sub: Subscripts
  sub = @["A"]
  Set:
    ^hello(sub) = "A"
    ^hello(@["B"]) = 4711
  assert "A" == Get ^hello(sub)
  assert "4711" == Get ^hello(@["B"])
  assert 4711 == Get ^hello(@["B"]).int
  assert 4711.0 == Get ^hello(@["B"]).float

  sub = @["A","B"]
  Set: ^hello(sub)="AB"
  assert "AB" == Get ^hello(sub)

  sub = @["users", "46", "name"]
  Set: ^hello(sub) = "Martina"
  assert "Martina" == Get ^hello(sub)



proc testSetGetGlobal() =
  Kill: ^global

  Set: ^global(1) = 1
  assert "1" == Get ^global(1)
  assert 1 == Get ^global(1).int
  assert 1.0 == Get ^global(1).float

  Set: ^global(1.1) = 1.1
  assert "1.1" == Get ^global(1.1)
  assert 1.1 == Get ^global(1.1).float
  doAssertRaises(ValueError): discard Get ^global(1.1).int

  Set: ^global(1, 1) = 1
  assert "1" == Get ^global(1, 1)
  assert 1 == Get ^global(1, 1).int
  assert 1.0 == Get ^global(1, 1).float

  Set: ^global("11") = 11
  assert "11" == Get ^global("11")
  assert 11 == Get ^global("11").int
  assert 11.0 == Get ^global("11").float

  Set: ^global("11", "1") = 11.1
  assert "11.1" == Get ^global("11", "1")
  doAssertRaises(ValueError): discard Get ^global("11", "1").int
  assert 11.1 == Get ^global("11", "1").float

  var id = 2
  Set: ^global(id) = id
  assert "2" == Get ^global(id)
  assert 2 == Get ^global(id).int
  assert 2.0 == Get ^global(id).float
  
  id = 12
  Set: ^global(id, id) = 12
  assert "12" == Get ^global(id, id)
  assert 12 == Get ^global(id, id).int
  assert 12.0 == Get ^global(id, id).float

  Set: ^global(id, id, "x") = 12
  assert "12" == Get ^global(id, id, "x")
  assert 12 == Get ^global(id, id, "x").int
  assert 12.0 == Get ^global(id, id, "x").float

  let id2 = @["3"]
  Set: ^global(id2) = 3
  assert "3" == Get ^global(id2)
  assert 3 == Get ^global(id2).int
  assert 3.0 == Get ^global(id2).float

  let id3 = @["4", "x"]
  Set: ^global(id3) = 4
  assert "4" == Get ^global(id3)
  assert 4 == Get ^global(id3).int
  assert 4.0 == Get ^global(id3).float

  Set: ^global(@["5", "x"]) = 5
  assert "5" == Get ^global(@["5", "x"])
  assert 5 == Get ^global(@["5", "x"]).int
  assert 5.0 == Get ^global(@["5", "x"]).float

  let x = "xx22xx"
  Set: ^global(@["6", $x]) = 6
  assert "6" == Get ^global(@["6", $x])
  assert 6 == Get ^global(@["6", $x]).int
  assert 6.0 == Get ^global(@["6", $x]).float

  let id7 = @["7", "x"]
  var global = fmt"^global({id7})"
  echo "global=", global
  Set: @global = "7"
  assert "7" == Get @global
  assert 7 == Get @global.int
  assert 7.0 == Get @global.float

proc testSetGet() =
  let id = 123
  Set:
    ^X(id, "s") = "pi"
    ^X(id, "i", 4711) = 3
    ^X(id, id, 4711, "i") = 33
    ^X(id, "f") = 3.1414

  assert "pi" == Get ^X(id, "s")
  assert 3 == Get ^X(id, "i", 4711).int
  assert 33 == Get ^X(id, id, 4711, "i").int
  assert Get(^X(id, "f").float) == 3.1414
  
  # Set multiple items
  Set:
      ^X(id, 1) = "pi" # First call to setxxx
      ^X(id, 2) = "pi" # Second call to setxxx
      ^X(id, 3) = "pi" # Third call to setxxx
      #^X(id, ...) = "pi" # ... call to setxxx

  for i in 1..<3:
    assert "pi" == Get ^X(id, i)

  # Set loop
  for id in 0..<5:
    let tm = cpuTime()
    Set: ^TMP(id, "Timestamp") = tm
    assert tm == Get ^TMP(id, "Timestamp").float

  # Set with exception, too many subscripts
  doAssertRaises(YdbError):
    Set: ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)="xxx"
  
  # Should work without exception
  Set: ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)="xxx"
  let s2 = Get ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
  assert "xxx" == s2

  let s = @["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
  Set: ^TMP(s) = "xy"
  assert "xy" == Get ^TMP(s)

  let gbl = "^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)"
  Set: @gbl = "zz"
  assert "zz" == Get @gbl

  let gbl2 = "^TMP(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,1,2,3)"
  Set: @gbl2 = "ab"
  assert "ab" == Get @gbl2
  
proc testGetUpdate() =
  let subs = @["4711", "Acc123"]
  block:
    # Get and Update .int
    Set: ^CUST(subs) = 1500
    var amount = Get ^CUST(subs).int
    amount += 1500
    Set: ^CUST(subs) = amount
    let dbamount = Get ^CUST(subs).int  # read from db
    assert dbamount == amount

  block:
    # Get and Update .float
    Set: ^CUST(subs) = 1500.50
    var amount = Get ^CUST(subs).float
    amount += 1500.50
    Set: ^CUST(subs) = amount
    let dbamount = Get ^CUST(subs).float  # read from db
    assert dbamount == amount

proc testSetMixed() =
  Set:
    ^hello(1)=1
    ^hello(1.5)=1.5
    ^hello(2.0)=2.0
    ^hello("2.0")=2.0
    ^hello("a")="a"
    ^hello(1,"a")="1a"
    ^hello("a","b")="ab"
    ^hello("a",1,"b")="a1b"

  assert 1 == Get ^hello(1).int
  assert 1 == Get ^hello(1).int
  assert "1" == Get ^hello(1)
  assert "1.5" == Get ^hello("1.5")
  assert 2.0 == Get ^hello(2.0).float
  assert "2.0" == Get ^hello(2.0)
  assert "a" == Get ^hello("a")
  assert "1a" == Get ^hello(1, "a")
  assert "ab" == Get ^hello("a", "b")
  assert "a1b" == Get ^hello("a", 1, "b")
  var sub:Subscripts = @["a", "1", "b"]
  assert "a1b" == Get ^hello(sub)

  var (id1,id2,id3) = ("users", "46", "name")
  Set: ^hello(id1, id2, id3) = "Martina"
  sub = @["users", "46", "name"]
  assert "Martina" == Get ^hello(sub)
  assert "Martina" == Get ^hello(id1, id2, id3)
  assert "Martina" == Get ^hello("users", "46", "name")
  assert "" == Get ^hello("users", "47", "name") # empty string if global does not exists
  assert "" == Get ^hello(id1, id2, id2)
  sub = @["users", "47", "name"]
  assert "" ==  Get ^hello(sub)


proc ifVariants() =
  Kill: ^hello
  Set:
    ^hello("a") = "a"
    ^hello(1) = 1
    ^hello(1.5) = 1.5
    ^hello("a","1","b") = "a1b"


  if Get(^hello("a")) == "a": assert true else: assert false
  if "a" == Get ^hello("a"): assert true else: assert false 
  if 1 == Get ^hello(1).int: assert true else: assert false
  if Get(^hello(1).int) == 1: assert true else: assert false
  if 1.5 == Get ^hello("1.5").float: assert true else: assert false
  if Get(^hello("1.5").float) == 1.5: assert true else: assert false

  if (Get ^hello(1).int) == 1: assert true else: assert false
  if 1 == Get ^hello(1).int: assert true else: assert false
  var sub:Subscripts = @["a", "1", "b"]
  if "a1b" == Get ^hello(sub): assert true else: assert false
  if Get(^hello(sub)) == "a1b": assert true else: assert false

proc echoTest() =
  # ----------------------
  # Expression-context macros
  # ----------------------
  # GET directly in echo
  echo "echo , ^hello2(\"users\", \"42\", \"name\")=", Get ^test("users", "42", "name")
  let (id0, id2, id3) = ("users", "42", "name")
  echo fmt"echo fmt ^hello2(id0,id2,id3)={Get ^test(id0,id2,id3)}"
  var subs:Subscripts = @["users", "42", "name"]
  echo fmt"echo fmt ^hello2(subs)={Get ^test(subs)}"


proc intUpdate() =
  let subs = @["4711", "Acc123"]
  # Get and Update .int
  Set: ^hello2(subs) = 1500
  assert Get(^hello2(subs)) == "1500"
  var amount = Get ^hello2(subs).int
  amount += 1500
  Set: ^hello2(subs) = amount
  let dbamount = Get ^hello2(subs).int  # read from db
  assert dbamount == amount

proc intSetUpdate() =
  let subs = @["4711", "Acc123"]
  Set: ^hello2(subs) = 1500
  # Get and Update .int
  assert Get(^hello2(subs)) == "1500"
  var amount = Get ^hello2(subs).int
  amount += 1500
  Set: ^hello2(subs) = amount
  let dbamount = Get ^hello2(subs).int  # read from db
  assert dbamount == amount

proc testSetGetTuple() =
  Set: ^gbl = "abc"
  assert "abc" == Get(^gbl)
  assert "abc" == Get ^gbl 

  Set:
      ^gbl1="gbl1"
      ^gbl2="gbl2"
  assert "gbl1" & "gbl2" == Get(^gbl1) & Get(^gbl2)
  assert "gbl1" & "gbl2" == (Get ^gbl1) & (Get ^gbl2)

  Set:
      ^gbl(1)="gbl1"
      ^gbl(2)="gbl2"
  assert "gbl1" & "gbl2" == Get(^gbl(1)) & Get(^gbl(2))
  assert "gbl1" & "gbl2" == (Get ^gbl(1)) & (Get ^gbl(2))

proc testExtendSubscriptWithString =
  Set:
    ^images("4711") = "imagedata"
    ^images("4711", "path") = "imagepath"

  var subs = @["4711"]
  let image = Get ^images(subs)
  assert image == "imagedata"
  let path = Get ^images(subs, "path")
  assert path == "imagepath"
  
  Kill: ^images(4711)

proc testNumbersRange() =
  Set:
    ^tmp("-1") = -1
    ^tmp("00") = 00
    ^tmp("+1") = +1
    ^tmp("-0") = -0
  assert Get(^tmp("-1").int) == -1
  assert Get(^tmp("00").int) == 0
  assert Get(^tmp("+1").int) == 1
  assert Get(^tmp("-0").int) == 0

  Set:
    ^tmp("int64") = high(int64)
    ^tmp("int8.high") = int8.high
    ^tmp("int8.low") = int8.low
    ^tmp("int16.high") = int16.high
    ^tmp("int16.low") = int16.low
    ^tmp("int32.high") = int32.high
    ^tmp("int32.low") = int32.low

  assert Get(^tmp("int64").int) == int.high
  doAssertRaises(RangeDefect): discard Get ^tmp("int64").int8
  doAssertRaises(RangeDefect): discard Get ^tmp("int64").int16
  doAssertRaises(RangeDefect): discard Get ^tmp("int64").int32

  assert Get(^tmp("int8.high").int8) == int8.high
  assert Get(^tmp("int8.low").int8) == int8.low
  assert Get(^tmp("int16.high").int16) == int16.high
  assert Get(^tmp("int16.low").int16) == int16.low
  assert Get(^tmp("int32.high").int32) == int32.high
  assert Get(^tmp("int32.low").int32) == int32.low
  assert Get(^tmp("int64").int64) == int64.high

  Set:
    ^tmp("uint") = uint.high
    ^tmp("uint,-1") = -1
    ^tmp("uint64") = uint64.high
    ^tmp("uint64,-1") = -1
    ^tmp("uint8.high") = uint8.high
    ^tmp("uint8.low") = uint8.low
    ^tmp("uint16.high") = uint16.high
    ^tmp("uint16.low") = uint16.low
    ^tmp("uint32.high") = uint32.high
    ^tmp("uint32.low") = uint32.low

  assert Get(^tmp("uint64").uint) == uint.high
  doAssertRaises(ValueError): discard Get ^tmp("uint64").int8
  doAssertRaises(RangeDefect): discard Get ^tmp("uint64").uint16
  doAssertRaises(RangeDefect): discard Get ^tmp("uint64").uint32

  assert Get(^tmp("uint32.high").uint32) == uint32.high
  assert Get(^tmp("uint8.high").uint8) == uint8.high
  assert Get(^tmp("uint8.low").uint8) == uint8.low
  assert Get(^tmp("uint16.high").uint16) == uint16.high
  assert Get(^tmp("uint16.low").uint16) == uint16.low
  assert Get(^tmp("uint32.low").uint32) == uint32.low
  assert Get(^tmp("uint64").uint64) == uint64.high

  Set:
    ^tmp("float") = (10.0 / 3.0).float
    ^tmp("float64") = (10.0 / 3.0).float64
    ^tmp("float32") = (10.0 / 3.0).float32

  assert Get(^tmp("float").float) == (10.0 / 3.0).float
  #assert Get(^tmp("float32").float32) == (10.0 / 3.0).float32 TODO: cast float32 gives strange result
  assert Get(^tmp("float64").float64) == (10.0 / 3.0).float64


proc setGet() =
  var
    id = 4711
    id1 = "4713"
    id2 = "A"
    ids:Subscripts = @["5"]

  Set:
    ^tmp(id) = 1
    ^tmp(2) = 2
    ^tmp("3") = 3
    ^tmp(@["4"]) = 4
    ^tmp(ids) = 5
    ^tmp(id, 4711) = 4711
    ^tmp(id, "4712") = "4712"
    ^tmp(id, "4713", "A") = "4713,A"
    #^tmp(id + 10) = id + 10 #TODO: Not supported anymore
    ^tmp("X") = "X"

  assert "1" == Get ^tmp(id)
  assert "1" == Get ^tmp($id)
  assert 1 == Get ^tmp(id).int
  assert 1.0 == Get ^tmp(id).float

  assert "4711" == Get ^tmp(id, 4711)
  assert 4711 == Get ^tmp(id, 4711).int
  assert 4711.0 == Get ^tmp(id, 4711).float
  assert "4711" == Get ^tmp(id, "4711")
  assert 4711 == Get ^tmp(id, "4711").int
  assert 4711.0 == Get ^tmp(id, "4711").float
  
  assert "4712" == Get ^tmp(id, 4712)
  assert 4712 == Get ^tmp(id, 4712).int
  assert 4712.0 == Get ^tmp(id, 4712).float
  assert "4712" == Get ^tmp(id, "4712")
  assert 4712 == Get ^tmp(id, "4712").int
  assert 4712.0 == Get ^tmp(id, "4712").float
  
  assert "4713,A" == Get ^tmp(id, "4713", "A")
  assert "4713,A" == Get ^tmp(id, 4713, "A")
  assert "4713,A" == Get ^tmp(id, id1, "A")
  assert "4713,A" == Get ^tmp(id, id1, id2)
  assert "4713,A" == Get ^tmp(@[$id, $id1, $id2])
  doAssertRaises(ValueError): discard Get ^tmp(@[$id, $id1, id2]).int
  doAssertRaises(ValueError): discard Get ^tmp(@[$id, id1, id2]).float

  var sub:Subscripts = @[$id, id1, id2]
  assert "4713,A" == Get ^tmp(sub)
  doAssertRaises(ValueError): discard Get ^tmp(sub).int
  doAssertRaises(ValueError): discard Get ^tmp(sub).float
 
  assert "2" == Get ^tmp(2)
  assert 2 == Get ^tmp(2).int
  assert 2.0 == Get ^tmp(2).float

  assert "3" == Get ^tmp("3")
  assert 3 == Get ^tmp("3").int
  assert 3.0 == Get ^tmp("3").float

  assert "4" ==  Get ^tmp(@["4"])
  assert 4 == Get ^tmp(@["4"]).int
  assert 4.0 == Get ^tmp(@["4"]).float

  assert "5" == Get ^tmp(ids)
  assert 5 == Get ^tmp(ids).int
  assert 5.0 == Get ^tmp(ids).float

proc testIndirection() =
    var gbl = "^GBL"
    Set: @gbl = "TheValue"
    assert "TheValue" == Get @gbl

    let gbl123 = "^GBL(123, 4711)"
    Set: @gbl123 = "123-4711"
    assert "123-4711" == Get @gbl123


proc testIndexExtension() =
    var gbl = "^GBL"
    Set: @gbl(1) = 1
    assert "1" == Get ^GBL(1)
    assert "1" == Get @gbl(1)

    Set: @gbl(1,"A") = "1A"
    assert "1A" == Get ^GBL(1, "A")
    assert "1A" == Get @gbl(1, "A")
    
    gbl = "^GBL(1,A)"
    assert "1A" == Get @gbl


    # ---- test with index in the variable ----
    gbl = "^GBL(123815)"
    Set: @gbl = "TheValue123815"
    assert "TheValue123815" == Get @gbl

    # Index extension
    Set: @gbl(1) = "TheValue123815,1" # ^GBL(123815,1)
    assert "TheValue123815,1" == Get @gbl(1)

    Set: @gbl("ABC") = "TheValueABC"
    assert "TheValueABC" == Get @gbl("ABC")

    Set: @gbl(123, "ABC") = "TheValue123ABC"
    assert "TheValue123ABC" == Get @gbl(123, "ABC")

    let id = "4714"
    Set: @gbl(id, "ABC") = "TheValueidABC"
    assert "TheValueidABC" == Get @gbl(id, "ABC")

    Set: @gbl(@["XYZ", id, "ABC"]) = "TheValueXYZABC"
    assert "TheValueXYZABC" == Get @gbl("XYZ", id, "ABC")
    assert "TheValueXYZABC" == Get @gbl(@["XYZ", id, "ABC"])

proc testCallMixIntStringInfix() =
    const MAX = 2
    Kill: ^BENCHMARK3

    let gbl = "^BENCHMARK3"
    for id in 0..<MAX:
        Set:
            @gbl(id) = id
            @gbl("X", id) = id
            @gbl(id + 1000) = id + 1000
            @gbl($id, id) = id
            @gbl($(id + 2000), id) = id + 2000

    block:
        let gblexpct = @["^BENCHMARK3(0)","^BENCHMARK3(1)","^BENCHMARK3(1000)","^BENCHMARK3(1001)","^BENCHMARK3(2000)","^BENCHMARK3(2001)","^BENCHMARK3(X)"]
        var gbldb: seq[string]
        var gbl = Order ^BENCHMARK3.key
        while gbl != "":
          gbldb.add(gbl) 
          gbl = Order @gbl.key
        assert gblexpct == gbldb

    block:
        var gblexpct = @["^BENCHMARK3(0)=0","^BENCHMARK3(0,0)=0","^BENCHMARK3(1)=1","^BENCHMARK3(1,1)=1","^BENCHMARK3(1000)=1000","^BENCHMARK3(1001)=1001","^BENCHMARK3(2000,0)=2000","^BENCHMARK3(2001,1)=2001","^BENCHMARK3(X,0)=0","^BENCHMARK3(X,1)=1"]
        var gbldb: seq[string]
        for gbl in QueryItr ^BENCHMARK3:
            let s = gbl & "=" & Get @gbl
            gbldb.add(s)
        assert gblexpct == gbldb

proc testDefaults() =
  Kill: ^GBL 
  assert "" == Get ^GBL(4711)

  let valdefault = Get (^GBL(4711), default=4711)
  assert valdefault == "4711"
  let valint = Get (^GBL(4711), default=4711).int
  assert valint == 4711

  let gbl = "^GBL(4712)"
  assert "" == Get @gbl
  var valindirekt = Get (@gbl, default=4712).int
  assert valindirekt == 4712

  assert "" == Get @gbl("Test2")
  let valstr = Get (@gbl("Test2"), default="test2")
  assert valstr == "test2"


proc testNewName() = 
  Set: ^x(1) = 1

if isMainModule:
    test "setGetSingleMulti": setGetSingleMulti()
    test "Infix": setGetInfix()
    test "testSetgetGlobal": testSetgetGlobal()
    test "setWithSubscript": setWithSubscript()
    test "SetGet": testSetGet()
    test "IfVariants": ifVariants()
    test "GetUpdate": testGetUpdate()
    test "SetMixed": testSetMixed()
    test "echo": echoTest()
    test "Update": intUpdate()
    test "SetUpdate": intSetUpdate()
    test "SetGetTuple": testSetGetTuple()
    test "ExtendSubscriptWithString": testExtendSubscriptWithString()
    test "NumbersRange": testNumbersRange()
    test "setget": setGet()
    test "Indirection": testIndirection()
    test "Indirection Index extension": testIndexExtension()
    test "Indirection MixIntStringInfix": testCallMixIntStringInfix()
    test "Defaults": testDefaults()
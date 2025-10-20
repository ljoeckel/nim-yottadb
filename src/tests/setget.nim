import std/[times, unittest, strformat]
import yottadb


proc setGetSingleMulti() =
    setvar: ^tmp = 1
    setvar:
        ^tmp1 = 1
        ^tmp2 = 2
    setvar:
        ^tmp2=2
        ^tmp3=3
    
    assert "1" == get ^tmp
    assert "1" == get ^tmp1
    assert "2" == get ^tmp2
    assert "3" == get ^tmp3

proc setGetInfix() =
    setvar: ^tmp = 1
    setvar:
        ^tmp(10) = 10
        ^tmp(20) = 20
    
    let id = 10
    assert "10" == get ^tmp(id)
    assert "20" == get ^tmp(id + 10)

    setvar: ^tmp(id + 30) = 30
    assert "30" == get ^tmp(id + 30)

    for i in 0..100:
      setvar: ^tmp(i + 1000 * 2) = i + 1000 * 2
    for i in 0..100:
      assert (i + 1000 * 2) == get ^tmp(i + 1000 * 2).int

    let subs: Subscripts = @[$id]
    assert "10" == get ^tmp(subs)
    let subs2: Subscripts = @[$(id + 10)]
    assert "20" == get ^tmp(subs2)
   
proc setWithSubscript() =
  var sub: Subscripts
  sub = @["A"]
  setvar:
    ^hello(sub) = "A"
    ^hello(@["B"]) = 4711
  assert "A" == get ^hello(sub)
  assert "4711" == get ^hello(@["B"])
  assert 4711 == get ^hello(@["B"]).int
  assert 4711.0 == get ^hello(@["B"]).float

  sub = @["A","B"]
  setvar: ^hello(sub)="AB"
  assert "AB" == get ^hello(sub)

  sub = @["users", "46", "name"]
  setvar: ^hello(sub) = "Martina"
  assert "Martina" == get ^hello(sub)



proc testSetGetGlobal() =
  deletevar: ^global

  setvar: ^global(1) = 1
  assert "1" == get ^global(1)
  assert 1 == get ^global(1).int
  assert 1.0 == get ^global(1).float

  setvar: ^global(1.1) = 1.1
  assert "1.1" == get ^global(1.1)
  assert 1.1 == get ^global(1.1).float
  doAssertRaises(ValueError): discard get ^global(1.1).int

  setvar: ^global(1, 1) = 1
  assert "1" == get ^global(1, 1)
  assert 1 == get ^global(1, 1).int
  assert 1.0 == get ^global(1, 1).float

  setvar: ^global("11") = 11
  assert "11" == get ^global("11")
  assert 11 == get ^global("11").int
  assert 11.0 == get ^global("11").float

  setvar: ^global("11", "1") = 11.1
  assert "11.1" == get ^global("11", "1")
  doAssertRaises(ValueError): discard get ^global("11", "1").int
  assert 11.1 == get ^global("11", "1").float

  var id = 2
  setvar: ^global(id) = id
  assert "2" == get ^global(id)
  assert 2 == get ^global(id).int
  assert 2.0 == get ^global(id).float
  
  id = 12
  setvar: ^global(id, id) = 12
  assert "12" == get ^global(id, id)
  assert 12 == get ^global(id, id).int
  assert 12.0 == get ^global(id, id).float

  setvar: ^global(id, id, "x") = 12
  assert "12" == get ^global(id, id, "x")
  assert 12 == get ^global(id, id, "x").int
  assert 12.0 == get ^global(id, id, "x").float

  let id2 = @["3"]
  setvar: ^global(id2) = 3
  assert "3" == get ^global(id2)
  assert 3 == get ^global(id2).int
  assert 3.0 == get ^global(id2).float

  let id3 = @["4", "x"]
  setvar: ^global(id3) = 4
  assert "4" == get ^global(id3)
  assert 4 == get ^global(id3).int
  assert 4.0 == get ^global(id3).float

  setvar: ^global(@["5", "x"]) = 5
  assert "5" == get ^global(@["5", "x"])
  assert 5 == get ^global(@["5", "x"]).int
  assert 5.0 == get ^global(@["5", "x"]).float

  let x = "xx22xx"
  setvar: ^global(@["6", $x]) = 6
  assert "6" == get ^global(@["6", $x])
  assert 6 == get ^global(@["6", $x]).int
  assert 6.0 == get ^global(@["6", $x]).float

  let id7 = @["7", "x"]
  var global = fmt"^global({id7})"
  echo "global=", global
  setvar: @global = "7"
  assert "7" == get @global
  assert 7 == get @global.int
  assert 7.0 == get @global.float

proc testSetGet() =
  let id = 123
  setvar:
    ^X(id, "s") = "pi"
    ^X(id, "i", 4711) = 3
    ^X(id, id, 4711, "i") = 33
    ^X(id, "f") = 3.1414

  assert "pi" == get ^X(id, "s")
  assert 3 == get ^X(id, "i", 4711).int
  assert 33 == get ^X(id, id, 4711, "i").int
  assert get(^X(id, "f").float) == 3.1414
  
  # Set multiple items
  setvar:
      ^X(id, 1) = "pi" # First call to setxxx
      ^X(id, 2) = "pi" # Second call to setxxx
      ^X(id, 3) = "pi" # Third call to setxxx
      #^X(id, ...) = "pi" # ... call to setxxx

  for i in 1..<3:
    assert "pi" == get ^X(id, i)

  # Set loop
  for id in 0..<5:
    let tm = cpuTime()
    setvar: ^TMP(id, "Timestamp") = tm
    assert tm == get ^TMP(id, "Timestamp").float

  # Set with exception, too many subscripts
  doAssertRaises(YdbError):
    setvar: ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)="xxx"
  
  # Should work without exception
  setvar: ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)="xxx"
  let s2 = get: ^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
  assert "xxx" == s2

  let s = @["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
  setvar: ^TMP(s) = "xy"
  assert "xy" == get ^TMP(s)

  let gbl = "^TMP(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)"
  setvar: @gbl = "zz"
  assert "zz" == get @gbl

  let gbl2 = "^TMP(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,1,2,3)"
  setvar: @gbl2 = "ab"
  assert "ab" == get @gbl2
  
proc testGetUpdate() =
  let subs = @["4711", "Acc123"]
  block:
    # Get and Update .int
    setvar: ^CUST(subs) = 1500
    var amount = get: ^CUST(subs).int
    amount += 1500
    setvar: ^CUST(subs) = amount
    let dbamount = get: ^CUST(subs).int  # read from db
    assert dbamount == amount

  block:
    # Get and Update .float
    setvar: ^CUST(subs) = 1500.50
    var amount = get: ^CUST(subs).float
    amount += 1500.50
    setvar: ^CUST(subs) = amount
    let dbamount = get: ^CUST(subs).float  # read from db
    assert dbamount == amount

proc testSetMixed() =
  setvar:
    ^hello(1)=1
    ^hello(1.5)=1.5
    ^hello(2.0)=2.0
    ^hello("2.0")=2.0
    ^hello("a")="a"
    ^hello(1,"a")="1a"
    ^hello("a","b")="ab"
    ^hello("a",1,"b")="a1b"

  assert 1 == get ^hello(1).int
  assert 1 == get(^hello(1).int)
  assert "1" == get ^hello(1)
  assert "1.5" == get ^hello("1.5")
  assert 2.0 == get ^hello(2.0).float
  assert "2.0" == get ^hello(2.0)
  assert "a" == get ^hello("a")
  assert "1a" == get ^hello(1, "a")
  assert "ab" == get ^hello("a", "b")
  assert "a1b" == get ^hello("a", 1, "b")
  var sub:Subscripts = @["a", "1", "b"]
  assert "a1b" == get(^hello(sub))

  var (id1,id2,id3) = ("users", "46", "name")
  setvar: ^hello(id1, id2, id3) = "Martina"
  sub = @["users", "46", "name"]
  assert "Martina" == get(^hello(sub))
  assert "Martina" == get(^hello(id1, id2, id3))
  assert "Martina" == get(^hello("users", "46", "name"))
  doAssertRaises(YdbError): discard get(^hello("users", "47", "name"))
  doAssertRaises(YdbError): discard get(^hello(id1, id2, id2))
  sub = @["users", "47", "name"]
  doAssertRaises(YdbError): discard get(^hello(sub))


proc ifVariants() =
  deletevar: ^hello
  setvar:
    ^hello("a") = "a"
    ^hello(1) = 1
    ^hello(1.5) = 1.5
    ^hello("a","1","b") = "a1b"


  if get(^hello("a")) == "a": assert true else: assert false
  if "a" == get ^hello("a"): assert true else: assert false 
  if 1 == get ^hello(1).int: assert true else: assert false
  if get(^hello(1).int) == 1: assert true else: assert false
  if 1.5 == get ^hello("1.5").float: assert true else: assert false
  if get(^hello("1.5").float) == 1.5: assert true else: assert false

  if (get ^hello(1).int) == 1: assert true else: assert false
  if 1 == get ^hello(1).int: assert true else: assert false
  var sub:Subscripts = @["a", "1", "b"]
  if "a1b" == get ^hello(sub): assert true else: assert false
  if get(^hello(sub)) == "a1b": assert true else: assert false

proc echoTest() =
  # ----------------------
  # Expression-context macros
  # ----------------------
  # GET directly in echo
  echo "echo , ^hello2(\"users\", \"42\", \"name\")=", get(^test("users", "42", "name"))
  let (id0, id2, id3) = ("users", "42", "name")
  echo fmt"echo fmt ^hello2(id0,id2,id3)={get(^test(id0,id2,id3))}"
  var subs:Subscripts = @["users", "42", "name"]
  echo fmt"echo fmt ^hello2(subs)={get(^test(subs))}"
  
  if get(^test(id0,id2,id3)) == "Alice": assert true else: assert false
  if "Alice" == get(^test(id0,id2,id3)): assert true else: assert false
  if get(^test("users", "43", "name")) == "Bob": assert true else: assert false
  if "Bob" == get(^test("users", "43", "name")): assert true else: assert false
  subs = @["users", "43", "name"]
  if get(^test(subs)) == "Bob": assert true else: assert false
  if "Bob" == get(^test(subs)): assert true else: assert false

proc intUpdate() =
  let subs = @["4711", "Acc123"]
  # Get and Update .int
  setvar: ^hello2(subs) = 1500
  assert get(^hello2(subs)) == "1500"
  var amount = get: ^hello2(subs).int
  amount += 1500
  setvar: ^hello2(subs) = amount
  let dbamount = get: ^hello2(subs).int  # read from db
  assert dbamount == amount

proc intSetUpdate() =
  let subs = @["4711", "Acc123"]
  setvar: ^hello2(subs) = 1500
  # Get and Update .int
  assert get(^hello2(subs)) == "1500"
  var amount = get: ^hello2(subs).int
  amount += 1500
  setvar: ^hello2(subs) = amount
  let dbamount = get: ^hello2(subs).int  # read from db
  assert dbamount == amount

proc testSetGetTuple() =
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

proc testExtendSubscriptWithString =
  setvar:
    ^images("4711") = "imagedata"
    ^images("4711", "path") = "imagepath"

  var subs = @["4711"]
  let image = get ^images(subs)
  assert image == "imagedata"
  let path = get ^images(subs, "path")
  assert path == "imagepath"
  
  deltree: ^images(4711)

proc testNumbersRange() =
  setvar:
    ^tmp("-1") = -1
    ^tmp("00") = 00
    ^tmp("+1") = +1
    ^tmp("-0") = -0
  assert get(^tmp("-1").int) == -1
  assert get(^tmp("00").int) == 0
  assert get(^tmp("+1").int) == 1
  assert get(^tmp("-0").int) == 0

  setvar:
    ^tmp("int64") = high(int64)
    ^tmp("int8.high") = int8.high
    ^tmp("int8.low") = int8.low
    ^tmp("int16.high") = int16.high
    ^tmp("int16.low") = int16.low
    ^tmp("int32.high") = int32.high
    ^tmp("int32.low") = int32.low

  assert get(^tmp("int64").int) == int.high
  doAssertRaises(RangeDefect): discard get ^tmp("int64").int8
  doAssertRaises(RangeDefect): discard get ^tmp("int64").int16
  doAssertRaises(RangeDefect): discard get ^tmp("int64").int32

  assert get(^tmp("int8.high").int8) == int8.high
  assert get(^tmp("int8.low").int8) == int8.low
  assert get(^tmp("int16.high").int16) == int16.high
  assert get(^tmp("int16.low").int16) == int16.low
  assert get(^tmp("int32.high").int32) == int32.high
  assert get(^tmp("int32.low").int32) == int32.low
  assert get(^tmp("int64").int64) == int64.high

  setvar:
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

  assert get(^tmp("uint64").uint) == uint.high
  assert uint8.high ==  get ^tmp("uint64").uint8
  assert uint16.high == get ^tmp("uint64").uint16
  assert uint32.high == get ^tmp("uint64").uint32

  assert get(^tmp("uint32.high").uint32) == uint32.high
  assert get(^tmp("uint8.high").uint8) == uint8.high
  assert get(^tmp("uint8.low").uint8) == uint8.low
  assert get(^tmp("uint16.high").uint16) == uint16.high
  assert get(^tmp("uint16.low").uint16) == uint16.low
  assert get(^tmp("uint32.low").uint32) == uint32.low
  assert get(^tmp("uint64").uint64) == uint64.high

  setvar:
    ^tmp("float") = (10.0 / 3.0).float
    ^tmp("float64") = (10.0 / 3.0).float64
    ^tmp("float32") = (10.0 / 3.0).float32
  assert get(^tmp("float").float) == (10.0 / 3.0).float
  assert get(^tmp("float32").float32) == (10.0 / 3.0).float32


proc setget() =
  var
    id = 4711
    id1 = "4713"
    id2 = "A"
    ids:Subscripts = @["5"]

  setvar:
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

  assert "1" == get ^tmp(id)
  assert "1" == get ^tmp($id)
  assert 1 == get ^tmp(id).int
  assert 1.0 == get ^tmp(id).float

  assert "4711" == get ^tmp(id, 4711)
  assert 4711 == get ^tmp(id, 4711).int
  assert 4711.0 == get ^tmp(id, 4711).float
  assert "4711" == get ^tmp(id, "4711")
  assert 4711 == get ^tmp(id, "4711").int
  assert 4711.0 == get ^tmp(id, "4711").float
  
  assert "4712" == get ^tmp(id, 4712)
  assert 4712 == get ^tmp(id, 4712).int
  assert 4712.0 == get ^tmp(id, 4712).float
  assert "4712" == get ^tmp(id, "4712")
  assert 4712 == get ^tmp(id, "4712").int
  assert 4712.0 == get ^tmp(id, "4712").float
  
  assert "4713,A" == get ^tmp(id, "4713", "A")
  assert "4713,A" == get ^tmp(id, 4713, "A")
  assert "4713,A" == get ^tmp(id, id1, "A")
  assert "4713,A" == get ^tmp(id, id1, id2)
  assert "4713,A" == get ^tmp(@[$id, $id1, $id2])
  doAssertRaises(ValueError): discard get ^tmp(@[$id, $id1, id2]).int
  doAssertRaises(ValueError): discard get ^tmp(@[$id, id1, id2]).float

  var sub:Subscripts = @[$id, id1, id2]
  assert "4713,A" == get ^tmp(sub)
  doAssertRaises(ValueError): discard get ^tmp(sub).int
  doAssertRaises(ValueError): discard get ^tmp(sub).float
 
  assert "2" == get ^tmp(2)
  assert 2 == get ^tmp(2).int
  assert 2.0 == get ^tmp(2).float

  assert "3" == get ^tmp("3")
  assert 3 == get ^tmp("3").int
  assert 3.0 == get ^tmp("3").float

  assert "4" ==  get ^tmp(@["4"])
  assert 4 == get ^tmp(@["4"]).int
  assert 4.0 == get ^tmp(@["4"]).float

  assert "5" == get ^tmp(ids)
  assert 5 == get ^tmp(ids).int
  assert 5.0 == get ^tmp(ids).float

proc testIndirection() =
    let gbl = "^GBL"
    setvar: @gbl = "TheValue"
    assert "TheValue" == get @gbl

    let gbl123 = "^GBL(123, 4711)"
    setvar: @gbl123 = "gbl(123)"
    assert "gbl(123)" == get @gbl123



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
    test "Indirection": testIndirection()
    test "setget": setget()
import std/[unittest]
import yottadb

proc setget() =
  var
    id = 1
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
    ^tmp(id + 10) = id + 10
    ^tmp("X") = "X"

  assert "1" == get(^tmp(id))
  assert "1" == get(^tmp($id))
  assert 1 == get(^tmp(id).int)
  assert 1.0 == get(^tmp(id).float)
  
  assert "11" == get(^tmp(id+10))
  assert 11 == get(^tmp(id+10).int)
  assert 11.0 == get(^tmp(id+10).float)

  assert "4711" == get(^tmp(id, 4711))
  assert 4711 == get(^tmp(id, 4711).int)
  assert 4711.0 == get(^tmp(id, 4711).float)
  assert "4711" == get(^tmp(id, "4711"))
  assert 4711 == get(^tmp(id, "4711").int)
  assert 4711.0 == get(^tmp(id, "4711").float)
  
  assert "4712" == get(^tmp(id, 4712))
  assert 4712 == get(^tmp(id, 4712).int)
  assert 4712.0 == get(^tmp(id, 4712).float)
  assert "4712" == get(^tmp(id, "4712"))
  assert 4712 == get(^tmp(id, "4712").int)
  assert 4712.0 == get(^tmp(id, "4712").float)
  
  let id2 = "A"
  let id1 = "4713"
  assert "4713,A" == get(^tmp(id, "4713", "A"))
  assert "4713,A" == get(^tmp(id, 4713, "A"))
  assert "4713,A" == get(^tmp(id, id1, "A"))
  assert "4713,A" == get(^tmp(id, id1, id2))
  assert "4713,A" == get(^tmp(@[$id, id1, id2]))
  doAssertRaises(ValueError): discard get(^tmp(@[$id, id1, id2]).int)
  doAssertRaises(ValueError): discard get(^tmp(@[$id, id1, id2]).float)

  var sub:Subscripts = @[$id, id1, id2]
  assert "4713,A" == get(^tmp(sub))
  doAssertRaises(ValueError): discard get(^tmp(sub).int)
  doAssertRaises(ValueError): discard get(^tmp(sub).float)
 
  assert "2" == get(^tmp(2))
  assert 2 == get(^tmp(2).int)
  assert 2.0 == get(^tmp(2).float)

  assert "3" == get(^tmp("3"))
  assert 3 == get(^tmp("3").int)
  assert 3.0 == get(^tmp("3").float)

  assert "4" ==  get(^tmp(@["4"]))
  assert 4 == get(^tmp(@["4"]).int)
  assert 4.0 == get(^tmp(@["4"]).float)

  assert "5" == get(^tmp(ids))
  assert 5 == get(^tmp(ids).int)
  assert 5.0 == get(^tmp(ids).float)

proc testNumbersRange() =
  setvar:
    ^tmp("-1") = -1
    assert get(^tmp("-1").int) == -1
    ^tmp("00") = 00
    assert get(^tmp("00").int) == 0
    ^tmp("+1") = +1
    assert get(^tmp("+1").int) == 1
    ^tmp("-0") = -0
    assert get(^tmp("-0").int) == 0

    ^tmp("int64") = high(int64)
    assert get(^tmp("int64").int) == int.high
    doAssertRaises(ValueError): discard get(^tmp("int64").int8)
    ^tmp("int8.high") = int8.high
    assert get(^tmp("int8.high").int8) == int8.high
    ^tmp("int8.low") = int8.low
    assert get(^tmp("int8.low").int8) == int8.low
    ^tmp("int16.high") = int16.high
    assert get(^tmp("int16.high").int16) == int16.high
    ^tmp("int16.low") = int16.low
    assert get(^tmp("int16.low").int16) == int16.low
    doAssertRaises(ValueError): discard get(^tmp("int64").int16)
    ^tmp("int32.high") = int32.high
    assert get(^tmp("int32.high").int32) == int32.high
    ^tmp("int32.low") = int32.low
    assert get(^tmp("int32.low").int32) == int32.low
    doAssertRaises(ValueError): discard get(^tmp("int64").int32)
    assert get(^tmp("int64").int64) == int64.high

    ^tmp("uint") = uint.high
    ^tmp("uint,-1") = -1
    ^tmp("uint64") = uint64.high
    ^tmp("uint64,-1") = -1
    assert get(^tmp("uint64").uint) == uint.high
    doAssertRaises(ValueError): discard get(^tmp("uint64").uint8)
    ^tmp("uint8.high") = uint8.high
    assert get(^tmp("uint8.high").uint8) == uint8.high
    ^tmp("uint8.low") = uint8.low
    assert get(^tmp("uint8.low").uint8) == uint8.low
    ^tmp("uint16.high") = uint16.high
    assert get(^tmp("uint16.high").uint16) == uint16.high
    ^tmp("uint16.low") = uint16.low
    assert get(^tmp("uint16.low").uint16) == uint16.low
    doAssertRaises(ValueError): discard get(^tmp("uint64").uint16)
    ^tmp("uint32.high") = uint32.high
    assert get(^tmp("uint32.high").uint32) == uint32.high
    ^tmp("uint32.low") = uint32.low
    assert get(^tmp("uint32.low").uint32) == uint32.low
    doAssertRaises(ValueError): discard get(^tmp("uint64").uint32)
    assert get(^tmp("uint64").uint64) == uint64.high

    ^tmp("float") = (10.0 / 3.0).float
    ^tmp("float64") = (10.0 / 3.0).float64
    ^tmp("float32") = (10.0 / 3.0).float32
    assert get(^tmp("float").float) == (10.0 / 3.0).float
    assert get(^tmp("float64").float64) == (10.0 / 3.0).float64
    assert get(^tmp("float32").float32) == (10.0 / 3.0).float32


proc setlocals() =
  setvar:
    local(1) = 1
    assert "1" == get(local(1))
    assert 1 == get(local(1).int)
    assert 1.0 == get(local(1).float)

    local(1.1) = "1.1"
    assert "1.1" == get(local(1.1))
    
    var id = 2
    local(id) = id
    assert $id == get(local(id))
    local(id, id) = id
    assert $id == get(local(id, id))
    local(id,"X") = $id
    assert $id == get(local(id, "X"))
    doAssertRaises(YdbError): discard get(local(id, "Y"))


proc delnode() =
  var id: int
  # create some records  
  for i in 0..15:
    setvar: ^tmp2(1000 + i) = 1000 + i
  
  delnode ^tmp2(1001)
  delnode(^tmp(1002))
  delnode:
    ^tmp2(1003)
    ^tmp2(1004)
  
  id = 1005
  delnode ^tmp2(id)
  for i in 1005..<1010:
    delnode ^tmp2(i)

  delnode:
    ^tmp2("1011")
    let ids = "1012"
    ^tmp2(ids)
    ^tmp2(@["1013"])
    let sub: Subscripts = @["1014"]
    ^tmp2(sub)

  let refdata = @["1000", "1002", "1010", "1015"]
  var (rc, subs) = nextnode ^tmp2()
  var dbdata: Subscripts
  while rc == YDB_OK:
    dbdata.add(subs)
    (rc, subs) = nextnode ^tmp2(subs)
  assert dbdata == refdata


proc testData() =
  var id = 1
  setvar: ^tmp2(id) = 1
  assert data(^tmp2(id)) == 1
  setvar: ^tmp2(1) = 1
  assert data(^tmp2(1)) == 1
  var id2 = "1"
  setvar: ^tmp2(id2)="1"
  assert data(^tmp2(id2)) == 1
  setvar: ^tmp2("1")="1"
  assert data(^tmp2("1")) == 1
  var id3 = @["1"]
  setvar: ^tmp2(id3) = 1
  assert data(^tmp2(id3)) == 1
  setvar: ^tmp2(@["1"])="1"
  assert data(^tmp2(@["1"])) == 1

  setvar:
    var xid = 11 # reusing id will not work!
    ^tmp2(xid) = 11
    assert data(^tmp2(xid)) == 1
    ^tmp2(1) = 11
    assert data(^tmp2(1)) == 1
    var xid2 = "11"
    ^tmp2(xid2)="11"
    assert data(^tmp2(xid2)) == 1
    ^tmp2("11")="11"
    assert data(^tmp2("11")) == 1
    var xid3 = @["11"]
    ^tmp2(xid3) = 1
    assert data(^tmp2(xid3)) == 1
    ^tmp2(@["11"])="11"
    assert data(^tmp2(@["11"])) == 1

  let gbl = "^tmp2"
  setvar: gbl(1)=4711 # set the local variable 'gbl' to 4711
  let ss = "gbl=" & get(gbl(1))
  assert ss == "gbl=4711"
  doAssertRaises(YdbError): discard get(^tmp2(4711)) # ^tmp2(4711) not set because gbl(4711) is set TODO: global from variable

proc testLocals() =
  setvar: gbl(1)=1
  assert get(gbl(1)) == "1"
  let id = 2
  setvar: gbl(id) = 2
  assert get(gbl(id)) == "2"
  let id2 = "3"
  setvar: gbl(id2) = 3
  assert get(gbl(id2)) == "3"
  setvar: gbl(@["4"])=4
  assert get(gbl(@["4"])) == "4"
  let id3: Subscripts = @["5"]
  setvar: gbl(id3) = "5"
  assert get(gbl(id3)) == "5"
  setvar: gbl(1,1)="1.1"
  assert get(gbl(1,1)) == "1.1"

  setvar:
    gbl(1)=11
    assert get(gbl(1)) == "11"
    gbl(id) = 22
    assert get(gbl(id)) == "22"
    setvar: gbl(id2) = 33
    assert get(gbl(id2)) == "33"
    gbl(@["4"])=44
    assert get(gbl(@["4"])) == "44"
    gbl(id3) = "55"
    assert get(gbl(id3)) == "55"
    gbl(2, 2)="2.2"
    assert get(gbl(2, 2)) == "2.2"

  # get
  var val = get: gbl(2, 2)
  assert val == "2.2"
  #var valI = get(gbl(2, 2).float)
  #echo "valI:", valI
  
  # data on localc
  assert ydb_data("gbl",@["1"]) == 11
  assert data(gbl(1)) == 11
  assert data(gbl("1")) == 11
  assert data(gbl(1,1))  == 1

  let refdata = @[@["1"],@["1", "1"],@["2"],@["2", "2"],@["3"],@["4"],@["5"]]
  var subs: seq[Subscripts]
  for sub in ydb_node_next_iter("gbl"):
    subs.add(sub)
  assert subs == refdata


proc testExtendSubscriptWithString =
  setvar:
    ^images("4711") = "imagedata"
    ^images("4711", "path") = "imagepath"

  var subs = @["4711"]
  let image = get(^images(subs))
  assert image == "imagedata"
  let path = get(^images(subs, "path"))
  assert path == "imagepath"
  
  deltree(^images(4711))


proc setup() =
  assert deleteGlobal("^tmp")
  assert deleteGlobal("^tmp2")
  assert deleteGlobal("^images")


when isMainModule:
  suite "setget Tests":
    test "setup": setup()
    test "setget": setget()
    test "setlocals": setlocals()
    test "delnode": delnode()
    test "data": testData()
    test "locals": testLocals()
    test "numbersRange": testNumbersRange()
    test "extend Subscript with string": testExtendSubscriptWithString()

  #listGlobal("^tmp")
  #listGlobal("^tmp2")
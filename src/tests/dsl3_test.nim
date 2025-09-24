import std/[unittest]
import yottadb

proc setget() =
  var
    id = 1
    ids:Subscripts = @["5"]

  set:
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


proc setlocals() =
  set:
    local(1) = 1
    assert "1" == get(local(1))
    #TODO: assert 1 == get(local(1).int) # Error: undeclared identifier 'local'
    #assert 1.0 == get(local(1).float) # Error: undeclared identifier 'local'

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
    set: ^tmp2(1000 + i) = 1000 + i
  
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
  set: ^tmp2(id) = 1
  assert data(^tmp2(id)) == 1
  set: ^tmp2(1) = 1
  assert data(^tmp2(1)) == 1
  var id2 = "1"
  set: ^tmp2(id2)="1"
  assert data(^tmp2(id2)) == 1
  set: ^tmp2("1")="1"
  assert data(^tmp2("1")) == 1
  var id3 = @["1"]
  set: ^tmp2(id3) = 1
  assert data(^tmp2(id3)) == 1
  set: ^tmp2(@["1"])="1"
  assert data(^tmp2(@["1"])) == 1

  set:
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
  set: gbl(1)=4711 # set the local variable 'gbl' to 4711
  let ss = "gbl=" & get(gbl(1))
  assert ss == "gbl=4711"
  doAssertRaises(YdbError): discard get(^tmp2(4711)) # ^tmp2(4711) not set because gbl(4711) is set TODO: global from variable

proc testLocals() =
  set: gbl(1)=1
  assert get(gbl(1)) == "1"
  let id = 2
  set: gbl(id) = 2
  assert get(gbl(id)) == "2"
  let id2 = "3"
  set: gbl(id2) = 3
  assert get(gbl(id2)) == "3"
  set: gbl(@["4"])=4
  assert get(gbl(@["4"])) == "4"
  let id3: Subscripts = @["5"]
  set: gbl(id3) = "5"
  assert get(gbl(id3)) == "5"
  set: gbl(1,1)="1.1"
  assert get(gbl(1,1)) == "1.1"

  set:
    gbl(1)=11
    assert get(gbl(1)) == "11"
    gbl(id) = 22
    assert get(gbl(id)) == "22"
    set: gbl(id2) = 33
    assert get(gbl(id2)) == "33"
    gbl(@["4"])=44
    assert get(gbl(@["4"])) == "44"
    gbl(id3) = "55"
    assert get(gbl(id3)) == "55"
    gbl(1,1)="2.2"
    assert get(gbl(1,1)) == "2.2"

  # data on localc
  assert ydb_data("gbl",@["1"]) == 11
  assert data(gbl(1)) == 11
  assert data(gbl("1")) == 11
  assert data(gbl(1,1))  == 1

  let refdata = @[@["1"],@["1", "1"],@["2"],@["3"],@["4"],@["5"]]
  var subs: seq[Subscripts]
  for sub in ydb_node_next_iter("gbl"):
    subs.add(sub)
  assert subs == refdata




proc setup() =
  assert deleteGlobal("^tmp")
  assert deleteGlobal("^tmp2")


when isMainModule:
  suite "setget Tests":
    test "setup": setup()
    test "setget": setget()
    test "setlocals": setlocals()
    test "delnode": delnode()
    test "data": testData()
    test "locals": testLocals()

  #listGlobal("^tmp")
  #listGlobal("^tmp2")
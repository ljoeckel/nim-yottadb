# testdsl.nim
import std/[unittest, strutils, strformat]
import yottadb
import utils

proc setup() =
  # remove all nodes from ^hello
  var (rc, subs) = nextnode: ^hello()
  while rc == YDB_OK:
    delnode: ^hello(subs)
    (rc, subs) = nextnode ^hello(subs)

  # test if all nodes are removed
  (rc, subs) = nextnode ^hello()
  assert rc == YDB_ERR_NODEEND

  # clear hello2
  (rc, subs) = nextnode: ^hello2()
  while rc == YDB_OK:
    delnode: ^hello2(subs)
    (rc, subs) = nextnode ^hello2(subs)
  assert nextnode(^hello())[0] == YDB_ERR_NODEEND  # extract rc from tuple

  # create new nodes in hello2
  for id in 0..5000:
    set: ^hello2(id) = $id


proc setWithSubscript() =
  var sub: Subscripts
  sub = @["A"]
  set:
    ^hello(sub)="A"
    assert "A" == get(^hello(sub))
    ^hello(@["B"])=4711
    assert "4711" == get(^hello(@["B"]))
    assert 4711 == get(^hello(@["B"]).int)
    assert 4711.0 == get(^hello(@["B"]).float)

  sub = @["A","B"]
  set: ^hello(sub)="AB"
  assert "AB" == get(^hello(sub))

  sub = @["users", "46", "name"]
  set: ^hello(sub) = "Martina"
  assert "Martina" == get(^hello(sub))

proc setMixed() =
  set:
    ^hello(1)=1
    assert 1 == get ^hello(1).int
    assert 1 == get(^hello(1).int)
    assert "1" == get ^hello(1)
    ^hello(1.5)=1.5
    assert 1.5 == get ^hello("1.5").float
    assert "1.5" == get ^hello("1.5")
    ^hello(2.0)=2.0
    ^hello("2.0")=2.0
    assert 2.0 == get ^hello(2.0).float
    assert "2.0" == get ^hello(2.0)

    ^hello("a")="a"
    assert "a" == get ^hello("a")
    ^hello(1,"a")="1a"
    assert "1a" == get ^hello(1, "a")
    ^hello("a","b")="ab"
    assert "ab" == get ^hello("a", "b")
    ^hello("a",1,"b")="a1b"
    assert "a1b" == get ^hello("a", 1, "b")
    var sub:Subscripts = @["a", "1", "b"]
    assert "a1b" == get(^hello(sub))

  var (id1,id2,id3) = ("users", "46", "name")
  set: ^hello(id1, id2, id3) = "Martina"
  sub = @["users", "46", "name"]
  assert "Martina" == get(^hello(sub))
  assert "Martina" == get(^hello(id1, id2, id3))
  assert "Martina" == get(^hello("users", "46", "name"))
  doAssertRaises(YdbError): discard get(^hello("users", "47", "name"))
  doAssertRaises(YdbError): discard get(^hello(id1, id2, id2))
  sub = @["users", "47", "name"]
  doAssertRaises(YdbError): discard get(^hello(sub))

proc intUpdate() =
  let subs = @["4711", "Acc123"]
  # Get and Update .int
  set: ^hello2(subs) = 1500
  assert get(^hello2(subs)) == "1500"
  var amount = get: ^hello2(subs).int
  amount += 1500
  set: ^hello2(subs) = amount
  let dbamount = get: ^hello2(subs).int  # read from db
  assert dbamount == amount

proc intSetUpdate() =
  set:
    let subs = @["4711", "Acc123"]
    # Get and Update .int
    ^hello2(subs) = 1500
    assert get(^hello2(subs)) == "1500"
    var amount = get: ^hello2(subs).int
    amount += 1500
    ^hello2(subs) = amount
    let dbamount = get: ^hello2(subs).int  # read from db
    assert dbamount == amount


proc intSetLockUpdate() =
  withlock(4711):
    set:
      let subs = @["4711", "Acc123"]
      # Set initial amount
      ^hello2(subs) = 1500
      assert get(^hello2(subs)) == "1500"
      var amount = get: ^hello2(subs).int # get back as int
      amount += 1500
      ^hello2(subs) = amount # update db
      assert amount == get(^hello2(subs).int)
    assert isLocked(4711)
    
  assert not isLocked(4711)

proc ifVariants() =
  if get(^hello("a")) == "a": assert true else: assert false
  if "a" == get ^hello("a"): assert true else: assert false 
  if 1 == get ^hello(1).int: assert true else: assert false
  if get(^hello(1).int) == 1: assert true else: assert false
  if 1.5 == get ^hello("1.5").float: assert true else: assert false
  if get(^hello("1.5").float) == 1.5: assert true else: assert false

  #if get ^hello(1).int == 1: assert true else: assert false  <- does not work
  var sub:Subscripts = @["a", "1", "b"]
  if "a1b" == get ^hello(sub): assert true else: assert false
  if get(^hello(sub)) == "a1b": assert true else: assert false

proc readnext() =
  let refdata:seq[Subscripts] = @[
    @["1"], @["1", "a"], @["1.5"], @["2.0"],@["A"],@["A", "B"], @["B"],
    @["a"],@["a", "1", "b"],@["a", "b"],@["users", "46", "name"]
  ]
  var dbdata :seq[Subscripts]
  var (rc, subs) = nextnode: ^hello()
  while rc == YDB_OK:
    dbdata.add(subs)
    (rc, subs) = nextnode: ^hello(subs)
  assert rc == YDB_ERR_NODEEND
  assert dbdata == refdata


proc data() =
  assert 0 == data ^hello(99999)
  assert 0 == data(^hello(99999))
  assert 11 == data ^hello(1)
  assert data(^hello(1)) == 11
  var subs:Subscripts = @["users", "46", "name"]
  assert 1 == data ^test(subs)
  assert data(^test(subs)) == 1

# ----------------------
# Statement-context macros
# ----------------------

proc setTest() =
  set:
    ^test("users", "42", "name") = "Alice"
    assert "Alice" == get(^test("users", "42", "name"))
    
    let (id1, id2, id3) = ("users", "43", "name")
    ^test(id1, id2, id3) = "Bob"
    assert "Bob" == get(^test(id1, id2, id3))
    assert get(^test("users", "43", "name")) == "Bob"

    ^test("users", 45, "name") = "Lothar"
    assert "Lothar" == get(^test("users", 45, "name"))
    var sub0:Subscripts = @["users", "46", "name"]
    ^test(sub0) = "Martina"
    assert "Martina" == get(^test(sub0))


proc incrementTest() =
  # INCR
  set: ^CNT("AUTO") = 1
  var autocnt = parseInt(get ^CNT("AUTO"))
  var c5 = incr: ^CNT("AUTO") = 5
  assert c5 == (autocnt + 5)

  autocnt = get: ^CNT("AUTO").int
  c5 = incr: ^CNT("AUTO")
  assert c5 == (autocnt + 1)


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

proc nextTest() =
  # NEXTSUB / PREVSUB example
  var (rc, subs) = nextsubscript(^test("users", "42"))
  assert rc == YDB_OK
  assert @["users", "43"] == subs
  (rc, subs) = prevsubscript(^test(subs))
  assert @["users", "42"] == subs

  # NEXTNODE / PREVNODE example
  (rc, subs) = nextnode(^test("users"))
  assert @["users", "42", "name"] == subs

  (rc, subs) = prevnode(^test("users"))
  assert rc == YDB_ERR_NODEEND
  assert subs.len == 0

  # nextnode from beginning
  (rc, subs) = nextnode ^test()
  assert rc == YDB_OK and subs.len > 0
  (rc, subs) = nextnode ^test("xxxxxxxx")
  assert rc == YDB_ERR_NODEEND and subs.len == 0

  # prevnode from beginning
  (rc, subs) = prevnode ^test()
  assert rc == YDB_ERR_NODEEND and subs.len == 0


proc dataTest() =
  var
    rc:int
    subs:Subscripts

  # DATA
  discard data: ^hello2(4710)
  discard data ^hello2(4710)
  assert 1 == data ^hello2("4710")
  if data(^hello2(4710)) > 0:
    assert not get(^hello2(4710)).isEmptyOrWhitespace

  subs = @["4712"]
  assert 1 == data ^hello2(subs)
  assert 1 == data(^hello2(subs))

  assert 0 == data ^hello2(@["4711", "1"])
  assert 0 == data ^hello2(4711, 1)
  assert 0 == data ^hello2("4711", 1)
  assert 0 == data ^hello2("4711", "1")

  set: ^hello2(4711, 1)=4711.1
  assert 1 == data ^hello2(@["4711", "1"])
  assert 1 == data ^hello2(4711, 1)
  assert 1 == data ^hello2("4711", 1)
  assert 1 == data ^hello2("4711", "1")
  # now a subtree for 4711 exists -> data 4711 should be now 11
  assert 11 == data ^hello2(4711)
  assert 11 == data ^hello2("4711")
  assert 11 == data ^hello2(@["4711"])

  (rc, subs) = nextnode(^hello2(@["4710"]))
  assert 11 == data ^hello2(subs)

  echo fmt"echo fmt: data ^hello({subs})={data(^hello2(subs))}"
  if data(^hello2(subs)) == 11:  # () required
      discard
  for i in data(^hello2(subs))..15: # () required
    discard

proc testDelnode() =
  # DELNODE
  if data(^hello(1, "a")) > 0: delnode ^hello(1, "a")
  assert data(^hello(1, "a")) == ord(NO_DATA_NO_SUBTREE)
  delnode ^hello("2")
  assert data(^hello("2")) == ord(NO_DATA_NO_SUBTREE)
  let idStr = "A"
  delnode(^hello(idStr))
  assert data(^hello(idStr)) == ord(NO_DATA_WITH_SUBTREE)
  let idSub:Subscripts = @["a", "1"]
  delnode ^hello(idSub)
  assert data(^hello(idSub)) == ord(NO_DATA_WITH_SUBTREE)

  delnode:
    ^hello(6)
    ^hello("7")

 
proc deleteData() =
  assert deleteGlobal("^hello")
  assert deleteGlobal("^hello2")
  assert deleteGlobal("^TMP")
  assert deleteGlobal("^CNT")
  assert deleteGlobal("^test")

when isMainModule:
  suite "DSL Tests":
    setup()
    test "setWithSubscript": setWithSubscript()
    test "setMixed": setMixed()
    test "intUpdate": intUpdate()
    test "intSetUpdate": intSetUpdate()
    test "intSetLockUpate": intSetLockUpdate()
    test "setTest": setTest()
    test "incrementTest": incrementTest()
    test "if variantes": ifVariants()
    test "readnext": readnext()
    test "data": data()
    test "dataTest": dataTest()
    test "setTest": setTest()
    test "echoTest": echoTest()
    test "nextTest": nextTest()
    test "testDelnode": testDelnode()
    #test "deleteData": deleteData()

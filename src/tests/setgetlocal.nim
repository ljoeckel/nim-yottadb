import std/[unittest, strformat]
import yottadb

proc simple() =
  setvar: localvar="xyz"
  assert "xyz" == get(localvar)
  assert "xyz" == get localvar

  setvar:
      localvar2 = "abc"
      localvar3 = "def"
  assert "abc" & "def" == get(localvar2) & get(localvar3)
  assert "abc" & "def" == (get localvar2) & (get localvar3)

proc testLocals() =
    setvar: LOCAL = "a single local"
    assert "a single local" == get LOCAL

    setvar:
        LOCAL = "Hallo"
        LOCAL(4711) = "Hello 4711"
        LOCAL("4711", "ABC") = "Hello from 4711,ABC"
    assert "Hallo" == get LOCAL
    assert "Hello 4711" == get LOCAL(4711)
    assert "Hello from 4711,ABC" == get LOCAL("4711", "ABC")

    let (a, b) = (get LOCAL, get LOCAL(4711))
    assert a == "Hallo" and b == "Hello 4711"


proc testSetGetLocal() =
  kill: local

  setvar: local(1) = 1
  assert "1" == get local(1)
  assert 1 == get local(1).int
  assert 1.0 == get local(1).float

  setvar: local(1.1) = 1.1
  assert "1.1" == get local(1.1)
  assert 1.1 == get local(1.1).float
  doAssertRaises(ValueError): discard get local(1.1).int

  setvar: local(1, 1) = 1
  assert "1" == get local(1, 1)
  assert 1 == get local(1, 1).int
  assert 1.0 == get local(1, 1).float

  setvar: local("11") = 11
  assert "11" == get local("11")
  assert 11 == get local("11").int
  assert 11.0 == get local("11").float

  setvar: local("11", "1") = 11.1
  assert "11.1" == get local("11", "1")
  doAssertRaises(ValueError): discard get local("11", "1").int
  assert 11.1 == get local("11", "1").float

  var id = 2
  setvar: local(id) = id
  assert "2" == get local(id)
  assert 2 == get local(id).int
  assert 2.0 == get local(id).float

  setvar: local(id, id) = 12
  assert "12" == get local(id, id)
  assert 12 == get local(id, id).int
  assert 12.0 == get local(id, id).float

  setvar: local(id, id, "x") = 12
  assert "12" == get local(id, id, "x")
  assert 12 == get local(id, id, "x").int
  assert 12.0 == get local(id, id, "x").float

  let id2 = @["3"]
  setvar: local(id2) = 3
  assert "3" == get local(id2)
  assert 3 == get local(id2).int
  assert 3.0 == get local(id2).float

  let id3 = @["3", "x"]
  setvar: local(id3) = 3
  assert "3" == get local(id3)
  assert 3 == get local(id3).int
  assert 3.0 == get local(id3).float

  setvar: local(@["4", "x"]) = 4
  assert "4" == get local(@["4", "x"])
  assert 4 == get local(@["4", "x"]).int
  assert 4.0 == get local(@["4", "x"]).float

  let x = "xx22xx"
  setvar: local(@["5", $x]) = 4
  assert "4" == get local(@["5", $x])
  assert 4 == get local(@["5", $x]).int
  assert 4.0 == get local(@["5", $x]).float

  var local = fmt"local({id3})"
  setvar: @local = "3"
  assert "3" == get @local
  assert 3 == get @local.int
  assert 3.0 == get @local.float

proc setlocals() =
  setvar: local(1) = 1
  assert "1" == get(local(1))
  assert 1 == get(local(1).int)
  assert 1.0 == get(local(1).float)

  setvar: local(1.1) = "1.1"
  assert "1.1" == get(local(1.1))

  var id = 2
  setvar:  
    local(id) = id
    local(id, id) = id
    local(id,"X") = $id
  assert $id == get(local(id))
  assert $id == get(local(id, id))
  assert $id == get(local(id, "X"))
  doAssertRaises(YdbError): discard get(local(id, "Y"))

proc testLocals2() =
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
    gbl(id) = 22
    gbl(id2) = 33
    gbl(@["4"])=44
    gbl(id3) = "55"
    gbl(2, 2)="2.2"
   
  assert get(gbl(1)) == "11"
  assert get(gbl(id)) == "22"
  assert get(gbl(id2)) == "33"
  assert get(gbl(@["4"])) == "44"
  assert get(gbl(id3)) == "55"
  assert get(gbl(2, 2)) == "2.2"

  # get
  var val = get: gbl(2, 2)
  assert val == "2.2"
  
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

test "simple": simple()
test "setGetLlocal": testSetGetLocal()
test "setLocals": setLocals()
test "setLocals2": testLocals2()
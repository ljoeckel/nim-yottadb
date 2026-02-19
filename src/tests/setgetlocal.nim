import std/[unittest, strformat]
import yottadb

proc simple() =
  Set: localvar="xyz"
  assert "xyz" == Get(localvar)
  assert "xyz" == Get localvar

  Set:
      localvar2 = "abc"
      localvar3 = "def"
  assert "abc" & "def" == Get(localvar2) & Get(localvar3)
  assert "abc" & "def" == (Get localvar2) & (Get localvar3)

proc testLocals() =
    Set: LOCAL = "a single local"
    assert "a single local" == Get LOCAL

    Set:
        LOCAL = "Hallo"
        LOCAL(4711) = "Hello 4711"
        LOCAL("4711", "ABC") = "Hello from 4711,ABC"
    assert "Hallo" == Get LOCAL
    assert "Hello 4711" == Get LOCAL(4711)
    assert "Hello from 4711,ABC" == Get LOCAL("4711", "ABC")

    let (a, b) = (Get LOCAL, Get LOCAL(4711))
    assert a == "Hallo" and b == "Hello 4711"


proc testSetGetLocal() =
  Kill: local

  Set: local(1) = 1
  assert "1" == Get local(1)
  assert 1 == Get local(1).int
  assert 1.0 == Get local(1).float

  Set: local(1.1) = 1.1
  assert "1.1" == Get local(1.1)
  assert 1.1 == Get local(1.1).float
  doAssertRaises(ValueError): discard Get local(1.1).int

  Set: local(1, 1) = 1
  assert "1" == Get local(1, 1)
  assert 1 == Get local(1, 1).int
  assert 1.0 == Get local(1, 1).float

  Set: local("11") = 11
  assert "11" == Get local("11")
  assert 11 == Get local("11").int
  assert 11.0 == Get local("11").float

  Set: local("11", "1") = 11.1
  assert "11.1" == Get local("11", "1")
  doAssertRaises(ValueError): discard Get local("11", "1").int
  assert 11.1 == Get local("11", "1").float

  var id = 2
  Set: local(id) = id
  assert "2" == Get local(id)
  assert 2 == Get local(id).int
  assert 2.0 == Get local(id).float

  Set: local(id, id) = 12
  assert "12" == Get local(id, id)
  assert 12 == Get local(id, id).int
  assert 12.0 == Get local(id, id).float

  Set: local(id, id, "x") = 12
  assert "12" == Get local(id, id, "x")
  assert 12 == Get local(id, id, "x").int
  assert 12.0 == Get local(id, id, "x").float

  let id2 = @["3"]
  Set: local(id2) = 3
  assert "3" == Get local(id2)
  assert 3 == Get local(id2).int
  assert 3.0 == Get local(id2).float

  let id3 = @["3", "x"]
  Set: local(id3) = 3
  assert "3" == Get local(id3)
  assert 3 == Get local(id3).int
  assert 3.0 == Get local(id3).float

  Set: local(@["4", "x"]) = 4
  assert "4" == Get local(@["4", "x"])
  assert 4 == Get local(@["4", "x"]).int
  assert 4.0 == Get local(@["4", "x"]).float

  let x = "xx22xx"
  Set: local(@["5", $x]) = 4
  assert "4" == Get local(@["5", $x])
  assert 4 == Get local(@["5", $x]).int
  assert 4.0 == Get local(@["5", $x]).float

  var local = fmt"local({id3})"
  Set: @local = "3"
  assert "3" == Get @local
  assert 3 == Get @local.int
  assert 3.0 == Get @local.float

proc setlocals() =
  Set: local(1) = 1
  assert "1" == Get local(1)
  assert 1 == Get local(1).int
  assert 1.0 == Get local(1).float

  Set: local(1.1) = "1.1"
  assert "1.1" == Get local(1.1)

  var id = 2
  Set:  
    local(id) = id
    local(id, id) = id
    local(id,"X") = $id
  assert $id == Get local(id)
  assert $id == Get local(id, id)
  assert $id == Get local(id, "X")
  doAssertRaises(YdbError): discard Get local(id, "Y")

proc testLocals2() =
  Set: gbl(1)=1
  assert Get(gbl(1)) == "1"
  let id = 2
  Set: gbl(id) = 2
  assert Get(gbl(id)) == "2"
  let id2 = "3"
  Set: gbl(id2) = 3
  assert Get(gbl(id2)) == "3"
  Set: gbl(@["4"])=4
  assert Get(gbl(@["4"])) == "4"
  let id3: Subscripts = @["5"]
  Set: gbl(id3) = "5"
  assert Get(gbl(id3)) == "5"
  Set: gbl(1,1)="1.1"
  assert Get(gbl(1,1)) == "1.1"

  Set:
    gbl(1)=11
    gbl(id) = 22
    gbl(id2) = 33
    gbl(@["4"])=44
    gbl(id3) = "55"
    gbl(2, 2)="2.2"
   
  assert Get(gbl(1)) == "11"
  assert Get(gbl(id)) == "22"
  assert Get(gbl(id2)) == "33"
  assert Get(gbl(@["4"])) == "44"
  assert Get(gbl(id3)) == "55"
  assert Get(gbl(2, 2)) == "2.2"

  # get
  var val = Get gbl(2, 2)
  assert val == "2.2"
  
  # Data on localc
  assert ydb_data("gbl",@["1"]) == 11
  assert Data(gbl(1)) == 11
  assert Data(gbl("1")) == 11
  assert Data(gbl(1,1))  == 1


test "simple": simple()
test "setGetLlocal": testSetGetLocal()
test "setLocals": setLocals()
test "setLocals2": testLocals2()
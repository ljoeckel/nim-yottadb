import std/unittest
import yottadb

proc setup() =
    kill:
        ^tmp2
        ^images
    setvar:
        ^tmp2(1)=0
        ^tmp2(1,1)=1
        ^tmp2(1,2,"a","b")=2
        ^tmp2("a","b")=3

proc stringAndSequence() =
    let refdata1 = @[@["1"], @["1", "1"], @["1", "2", "a", "b"], @["a", "b"]]
    var dbdata: seq[seq[string]]

    var (rc, subs) = nextnode ^tmp2.seq
    assert rc == YDB_OK and type(subs) is seq[string]
    while rc == YDB_OK:
        dbdata.add(subs)
        (rc,subs) = nextnode ^tmp2(subs).seq
    assert dbdata.len == 4
    assert dbdata == refdata1

    for idx, sub in dbdata:
        let val = getvar ^tmp2(sub).int
        assert idx == val

    # With indirektion
    let refdata2 = @["^tmp2(1)", "^tmp2(1,1)", "^tmp2(1,2,a,b)", "^tmp2(a,b)"]
    var dbdata2: seq[string]
    var gbl = "^tmp2"
    (rc, gbl) = nextnode @gbl
    assert rc == YDB_OK and type(gbl) is string
    while rc == YDB_OK:
        dbdata2.add(gbl)
        (rc, gbl) = nextnode @gbl
    assert dbdata2.len == 4
    assert dbdata2 == refdata2

    for idx, v in dbdata2:
        let val = getvar @v.int
        assert idx == val
        assert idx == getvar @v.int

proc netxtnodeWithKillnode() = 
    for i in 1000..1020:
        setvar: ^tmp2(i)=i

    for i in 1010..1015:
        killnode: ^tmp2(i)

    var (rc, subs) = nextnode ^tmp2.seq
    assert rc == YDB_OK and type(subs) is seq[string]
    while rc == YDB_OK:
        (rc,subs) = nextnode ^tmp2(subs).seq

    var gbl = "^tmp2"
    (rc, gbl) = nextnode @gbl
    assert rc == YDB_OK and type(gbl) is string
    while rc == YDB_OK:
        (rc, gbl) = nextnode @gbl

proc setNextPrevTest() =
  let (id1, id2, id3) = ("users", "43", "name")
  var sub0:Subscripts = @["users", "46", "name"]
  setvar:
    ^test("users", "42", "name") = "Alice"
    ^test(id1, id2, id3) = "Bob"
    ^test("users", 45, "name") = "Lothar"
    ^test(sub0) = "Martina"
  
  assert "Alice" == getvar ^test("users", "42", "name")
  assert "Bob" == getvar ^test(id1, id2, id3)
  assert (getvar ^test("users", "43", "name")) == "Bob"
  assert "Lothar" == getvar ^test("users", 45, "name")
  assert "Martina" == getvar ^test(sub0)

  # NEXTSUB / PREVSUB example
  var (rc, subs) = nextsubscript ^test("users", "42").seq
  assert rc == YDB_OK
  assert @["users", "43"] == subs
  (rc, subs) = prevsubscript ^test(subs).seq
  assert @["users", "42"] == subs

  # NEXTNODE / PREVNODE example
  (rc, subs) = nextnode ^test("users").seq
  assert @["users", "42", "name"] == subs

  (rc, subs) = prevnode ^test("users").seq
  assert rc == YDB_ERR_NODEEND
  assert subs.len == 0

  # nextnode from beginning
  (rc, subs) = nextnode ^test().seq
  assert rc == YDB_OK and subs.len > 0
  (rc, subs) = nextnode ^test("xxxxxxxx").seq
  assert rc == YDB_ERR_NODEEND and subs.len == 0

  # prevnode from end
  (rc, subs) = prevnode ^test().seq
  assert rc == YDB_OK and subs.len > 0
  assert @["users", "46", "name"] == subs

proc readnext() =
  kill: ^hello
  setvar:
    ^hello("a") = "a"
    ^hello(1) = 1
    ^hello(1.5) = 1.5
    ^hello("a","1","b") = "a1b"

  let refdata:seq[Subscripts] = @[
    @["1"], @["1.5"], @["a"], @["a", "1", "b"]
  ]
  var dbdata :seq[Subscripts]
  var (rc, subs) = nextnode: ^hello().seq
  while rc == YDB_OK:
    dbdata.add(subs)
    (rc, subs) = nextnode: ^hello(subs).seq
  assert rc == YDB_ERR_NODEEND
  assert dbdata == refdata

if isMainModule:
    test "setup": setup()
    test "stringAndSequence": stringAndSequence()
    test "nextNodeWithKillnode": netxtnodeWithKillnode()
    test "setNextPrev": setNextPrevTest()
    test "readnext": readnext()
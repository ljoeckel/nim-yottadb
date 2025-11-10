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

    for subs in queryItr ^tmp2.keys:
      assert type(subs) is seq[string]
      dbdata.add(subs)
    assert dbdata.len == 4
    assert dbdata == refdata1

    for idx, sub in dbdata:
        let val = getvar ^tmp2(sub).int
        assert idx == val

    # With indirektion
    let refdata2 = @["^tmp2(1)", "^tmp2(1,1)", "^tmp2(1,2,a,b)", "^tmp2(a,b)"]
    var dbdata2: seq[string]
    var gbl = "^tmp2"
    for gbl in queryItr @gbl:
      dbdata2.add(gbl)
    assert dbdata2.len == 4
    assert dbdata2 == refdata2

    for idx, v in dbdata2:
        let val = getvar @v.int
        assert idx == val
        assert idx == getvar @v.int


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
  var subs = order ^test("users", "42").keys
  assert @["users", "43"] == subs
  subs = order ^test(subs).keys.reverse
  assert @["users", "42"] == subs

  # NEXTNODE / PREVNODE example
  for subs in queryItr ^test("users").keys:
    assert @["users", "42", "name"] == subs
    break

  subs = order ^test("users").keys.reverse
  assert subs.len == 0

  # query from beginning
  subs = query ^test().keys
  assert subs.len > 0
  subs = query ^test("xxxxxxxx").keys
  assert subs.len == 0

  # prevnode from end
  subs = order ^test().keys.reverse
  assert subs.len > 0
  assert @["users"] == subs

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
  for subs in queryItr ^hello().keys:
    dbdata.add(subs)
  assert dbdata == refdata

if isMainModule:
    test "setup": setup()
    test "stringAndSequence": stringAndSequence()
    test "setNextPrev": setNextPrevTest()
    test "readnext": readnext()
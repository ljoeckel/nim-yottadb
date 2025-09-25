import std/strutils
import yottadb
import std/[unittest]

proc testSetGet() =
  set: gbl(1) = 1
  assert get(gbl(1)) == "1"
  assert get(gbl(1).int) == 1
  assert get(gbl(1).float) == 1.0

  set: gbl(1, 1) = 1
  assert get(gbl(1, 1)) == "1"
  assert get(gbl(1, 1).int) == 1
  assert get(gbl(1, 1).float) == 1.0

  set: gbl("11") = 11
  assert get(gbl("11")) == "11"
  assert get(gbl("11").int) == 11
  assert get(gbl("11").float) == 11.0

  set: gbl("11", "1") = 11.1
  assert get(gbl("11", "1")) == "11.1"
  doAssertRaises(ValueError): discard get(gbl("11", "1").int)
  assert get(gbl("11", "1").float) == 11.1

  let id = 2
  set: gbl(id) = id
  assert get(gbl(id)) == "2"
  assert get(gbl(id).int) == 2
  assert get(gbl(id).float) == 2.0

  set: gbl(id + 10) = 12
  assert get(gbl(id + 10)) == "12"
  assert get(gbl(id + 10).int) == 12
  assert get(gbl(id + 10).float) == 12.0

  set: gbl(id + 10, id) = 12
  assert get(gbl(id + 10, id)) == "12"
  assert get(gbl(id + 10, id).int) == 12
  assert get(gbl(id + 10, id).float) == 12.0

  set: gbl(id + 10, id, "x") = 12
  assert get(gbl(id + 10, id, "x")) == "12"
  assert get(gbl(id + 10, id, "x").int) == 12
  assert get(gbl(id + 10, id, "x").float) == 12.0

  let id2 = @["3"]
  set: gbl(id2) = 3
  assert get(gbl(id2)) == "3"
  assert get(gbl(id2).int) == 3
  assert get(gbl(id2).float) == 3.0

  let id3 = @["3", "x"]
  set: gbl(id3) = 3
  assert get(gbl(id3)) == "3"
  assert get(gbl(id3).int) == 3
  assert get(gbl(id3).float) == 3.0

proc teststr2zwr() =
  let x = str2zwr("hello\9World")
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

when isMainModule:
  suite "Locals Tests":
    test "set/get": testSetGet()
    test "str2zwr": teststr2zwr()
    test "zwr2str": testzwr2str()

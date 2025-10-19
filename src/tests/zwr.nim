import std/strutils
import std/[unittest]
import yottadb

proc teststr2zwr() =
  discard str2zwr("hello\9World")
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


test "str2zwr": teststr2zwr()
test "zwr2str": testzwr2str()
import std/[unittest, strformat]
import yottadb


proc dataTest() =
  kill:
    ^dta
    ^tmp2

  var
    rc:int
    subs:Subscripts

  setvar:
    ^dta(4710)=4710
    ^dta(4712)=4712

  # DATA
  assert 1 == data ^dta("4710")
  assert "4710" == getvar ^dta(4710)

  assert 1 == data ^dta(@["4712"])
  assert 1 == data @"^dta(4712)"
  
  let gbl = "^dta(4712)"
  assert 1 == data @gbl  
  
  subs = @["4712"]
  assert 1 == data ^dta(subs)

  assert 0 == data ^dta(@["4711", "1"])
  assert 0 == data ^dta(4711, 1)
  assert 0 == data ^dta("4711", 1)
  assert 0 == data ^dta("4711", "1")

  setvar: ^dta(4711, 1)=4711.1
  assert 1 == data ^dta(@["4711", "1"])
  assert 1 == data ^dta(4711, 1)
  assert 1 == data ^dta("4711", 1)
  assert 1 == data ^dta("4711", "1")

  # now a subtree for 4711 exists -> data 4711 should be now 10
  assert 10 == data ^dta(4711)
  assert 10 == data ^dta("4711")
  assert 10 == data ^dta(@["4711"])

  setvar: ^dta(4711) = 4711 # now has data and subtree
  assert 11 == data ^dta(4711)

  (rc, subs) = nextnode ^dta(@["4710"]).seq
  assert 11 == data ^dta(subs)

  echo fmt"echo fmt: data ^hello({subs})={data(^dta(subs))}"
  if (data ^dta(subs)) == 10:  # () required
      discard
  for i in data(^dta(subs))..15: # () required
    discard

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

  var xid = 11 # reusing id will not work!
  var xid2 = "11"
  var xid3 = @["11"]
  setvar:
    ^tmp2(xid) = 11
    ^tmp2(1) = 11
    ^tmp2(xid2)="11"
    ^tmp2("11")="11"
    ^tmp2(xid3) = 1
    ^tmp2(@["11"])="11"
  assert data(^tmp2(xid)) == 1
  assert data(^tmp2(1)) == 1
  assert data(^tmp2(xid2)) == 1
  assert data(^tmp2("11")) == 1
  assert data(^tmp2(xid3)) == 1
  assert data(^tmp2(@["11"])) == 1

  let gbl = "^tmp2"
  setvar: gbl(1)=4711 # set the local variable 'gbl' to 4711
  let ss = "gbl=" & getvar gbl(1)
  assert ss == "gbl=4711"
  assert "" == getvar ^tmp2(4711) # ^tmp2(4711) not set because gbl(4711) is set TODO: global from variable

if isMainModule:
  test "data": dataTest()
  test "data2": testData()
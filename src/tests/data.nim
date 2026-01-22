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

  setvar:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"


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

  subs = query ^dta(@["4710"]).keys
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


proc testData3() =
  var dta = data: ^X(0)
  assert dta == YDB_DATA_UNDEF
  assert YDB_DATA_UNDEF == data ^x(0)
  assert YDB_DATA_VALUE_NODESC == data ^X(6)
  assert YDB_DATA_VALUE_DESC == data ^X(5)
  assert data(^X(7)) == YDB_DATA_NOVALUE_DESC

proc testData4() =
    kill: ^GBL
    setvar: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        ^GBL(3,3)="3,3"
        ^GBL(5,1) = "5,1"
        ^GBL(6)="6"

    assert YDB_DATA_UNDEF == data ^GBLX
    assert YDB_DATA_VALUE_DESC == data ^GBL
    assert YDB_DATA_NOVALUE_DESC == data ^GBL(5) 
    assert YDB_DATA_VALUE_NODESC == data ^GBL(6)

if isMainModule:
  test "data": dataTest()
  test "data2": testData()
  test "data3": testData3()
  test "test4": testData4()
import std/[unittest, strformat]
import yottadb


proc dataTest() =
  Kill:
    ^dta
    ^tmp2

  var
    rc:int
    subs:Subscripts

  Set:
    ^dta(4710)=4710
    ^dta(4712)=4712

  Set:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"


  # Data
  assert 1 == Data ^dta("4710")
  assert "4710" == Get ^dta(4710)

  assert 1 == Data ^dta(@["4712"])
  assert 1 == Data @"^dta(4712)"
  
  let gbl = "^dta(4712)"
  assert 1 == Data @gbl  
  
  subs = @["4712"]
  assert 1 == Data ^dta(subs)

  assert 0 == Data ^dta(@["4711", "1"])
  assert 0 == Data ^dta(4711, 1)
  assert 0 == Data ^dta("4711", 1)
  assert 0 == Data ^dta("4711", "1")

  Set: ^dta(4711, 1)=4711.1
  assert 1 == Data ^dta(@["4711", "1"])
  assert 1 == Data ^dta(4711, 1)
  assert 1 == Data ^dta("4711", 1)
  assert 1 == Data ^dta("4711", "1")

  # now a subtree for 4711 exists -> Data 4711 should be now 10
  assert 10 == Data ^dta(4711)
  assert 10 == Data ^dta("4711")
  assert 10 == Data ^dta(@["4711"])

  Set: ^dta(4711) = 4711 # now has Data and subtree
  assert 11 == Data ^dta(4711)

  subs = Query ^dta(@["4710"]).keys
  assert 11 == Data ^dta(subs)

  echo fmt"echo fmt: Data ^hello({subs})={Data(^dta(subs))}"
  if (Data ^dta(subs)) == 10:  # () required
      discard
  for i in Data(^dta(subs))..15: # () required
    discard

proc testData() =
  var id = 1
  Set: ^tmp2(id) = 1
  assert Data(^tmp2(id)) == 1
  Set: ^tmp2(1) = 1
  assert Data(^tmp2(1)) == 1
  var id2 = "1"
  Set: ^tmp2(id2)="1"
  assert Data(^tmp2(id2)) == 1
  Set: ^tmp2("1")="1"
  assert Data(^tmp2("1")) == 1
  var id3 = @["1"]
  Set: ^tmp2(id3) = 1
  assert Data(^tmp2(id3)) == 1
  Set: ^tmp2(@["1"])="1"
  assert Data(^tmp2(@["1"])) == 1

  var xid = 11 # reusing id will not work!
  var xid2 = "11"
  var xid3 = @["11"]
  Set:
    ^tmp2(xid) = 11
    ^tmp2(1) = 11
    ^tmp2(xid2)="11"
    ^tmp2("11")="11"
    ^tmp2(xid3) = 1
    ^tmp2(@["11"])="11"
  assert Data(^tmp2(xid)) == 1
  assert Data(^tmp2(1)) == 1
  assert Data(^tmp2(xid2)) == 1
  assert Data(^tmp2("11")) == 1
  assert Data(^tmp2(xid3)) == 1
  assert Data(^tmp2(@["11"])) == 1


proc testData3() =
  var dta = Data: ^X(0)
  assert dta == YDB_DATA_UNDEF
  assert YDB_DATA_UNDEF == Data ^x(0)
  assert YDB_DATA_VALUE_NODESC == Data ^X(6)
  assert YDB_DATA_VALUE_DESC == Data ^X(5)
  assert Data(^X(7)) == YDB_DATA_NOVALUE_DESC

proc testData4() =
    Kill: ^GBL
    Set: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        ^GBL(3,3)="3,3"
        ^GBL(5,1) = "5,1"
        ^GBL(6)="6"

    assert YDB_DATA_UNDEF == Data ^GBLX
    assert YDB_DATA_VALUE_DESC == Data ^GBL
    assert YDB_DATA_NOVALUE_DESC == Data ^GBL(5) 
    assert YDB_DATA_VALUE_NODESC == Data ^GBL(6)

if isMainModule:
  test "Data": dataTest()
  test "data2": testData()
  test "data3": testData3()
  test "test4": testData4()
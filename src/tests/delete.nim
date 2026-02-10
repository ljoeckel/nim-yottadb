import std/unittest
import yottadb

proc testKill1() =
  kill:
    ^hello
    ^tmp2

  setvar:
    ^hello(1,"a")="1a"
    ^hello(2)=2
    ^hello("A")="A"
    ^hello("a",1)="a1"
    ^hello(6)=6
    ^hello(7)=7
    ^hello(8,"A")="8A"

  # DELNODE
  if data(^hello(1, "a")) > 0: killnode: ^hello(1, "a")
  assert data(^hello(1, "a")) == YDB_DATA_UNDEF
  
  killnode: ^hello("2")
  assert data(^hello("2")) == YDB_DATA_UNDEF

  let idStr = "A"
  killnode: ^hello(idStr)
  assert data(^hello(idStr)) == YDB_DATA_UNDEF
  
  let idSub:Subscripts = @["a", "1"]
  killnode: ^hello(idSub)
  assert data(^hello(idSub)) == YDB_DATA_UNDEF

  killnode:
    ^hello(6)
    ^hello("7")

  let gbl = "^hello(8,A)"
  assert 1 == data @gbl
  killnode: @gbl
  assert 0 == data @gbl


proc testKill2() =
  var id: int
  # create some records  
  for i in 0..15:
    id = 1000 + i
    setvar: ^tmp2(id) = id
  
  killnode:
    ^tmp2(1001)
    ^tmp2(1002)
    ^tmp2(1003)
    ^tmp2(1004)
  
  id = 1005
  killnode: ^tmp2(id)

  for i in 1005..<1010:
    killnode: ^tmp2(i)

  let ids = "1012"
  let sub: Subscripts = @["1014"]
  killnode:
    ^tmp2("1011")
    ^tmp2(ids)
    ^tmp2(@["1013"])
    ^tmp2(sub)

  let refdata = @["1000", "1010", "1015"]
  var dbdata: Subscripts
  
  for subs in queryItr ^tmp2.keys:
    dbdata.add(subs)
  assert dbdata == refdata


proc testKill3() =
  kill: ^X

  setvar: ^X(1)="hello"
  let s = getvar  ^X(1)
  assert "hello" == s
  killnode: ^X(1) # delete node
  assert "" == getvar ^X(1)
  
  # create a tree
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  setvar: ^X(2) = "hello world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  kill: ^X(1)
  assert "" == getvar ^X(1)
  let id = 2
  kill: ^X(id)
  assert "" == getvar ^X(id)

proc testDeleteNode() =
    setvar: ^GBL="hallo"
    killnode: ^GBL
    assert "" == getvar ^GBL

    let gbl = "^GBL(1)"
    setvar: @gbl = "gbl(1)"
    killnode: @gbl
    assert "" == getvar @gbl

    setvar: ^GBL1="hallo"
    assert "hallo" == getvar ^GBL1
    killnode: ^GBL1
    assert "" == getvar ^GBL1

    setvar:
        ^GBL1="gbl1"
        ^GBL2="gbl2"
        ^GBL3="gbl3"
    killnode:
        ^GBL1
        ^GBL2
        ^GBL3
    assert "" == getvar ^GBL1
    assert "" == getvar ^GBL2
    assert "" == getvar ^GBL3

    setvar:
        ^GBL(1)=1
        ^GBL(2)=2
        ^GBL(3)=3
    killnode:
        ^GBL(1)
        ^GBL(2)
        ^GBL(3)
    assert "" == getvar ^GBL(1)
    assert "" == getvar ^GBL(2)
    assert "" == getvar ^GBL(3)


proc testDeleteTree() =
    setvar: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        
    kill: ^GBL(1)
    assert "" == getvar ^GBL(1,1)
    assert "" == getvar ^GBL(1,2)
    kill: ^GBL
    assert "" == getvar ^GBL

    let gblname = "^GBL"
    for gbl in queryItr @gblname:
        assert gbl.len > 0



if isMainModule:
  test "killNode": testKill1()
  test "kill": testKill2()
  test "killnode": testKill3()
  test "testDeleteTree": testDeleteTree()
  test "testDeleteNode": testDeleteNode()
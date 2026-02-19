import std/unittest
import yottadb

proc testKill1() =
  Kill:
    ^hello
    ^tmp2

  Set:
    ^hello(1,"a")="1a"
    ^hello(2)=2
    ^hello("A")="A"
    ^hello("a",1)="a1"
    ^hello(6)=6
    ^hello(7)=7
    ^hello(8,"A")="8A"

  # DELNODE
  if Data(^hello(1, "a")) > 0: Killnode: ^hello(1, "a")
  assert Data(^hello(1, "a")) == YDB_DATA_UNDEF
  
  Killnode: ^hello("2")
  assert Data(^hello("2")) == YDB_DATA_UNDEF

  let idStr = "A"
  Killnode: ^hello(idStr)
  assert Data(^hello(idStr)) == YDB_DATA_UNDEF
  
  let idSub:Subscripts = @["a", "1"]
  Killnode: ^hello(idSub)
  assert Data(^hello(idSub)) == YDB_DATA_UNDEF

  Killnode:
    ^hello(6)
    ^hello("7")

  let gbl = "^hello(8,A)"
  assert 1 == Data @gbl
  Killnode: @gbl
  assert 0 == Data @gbl


proc testKill2() =
  var id: int
  # create some records  
  for i in 0..15:
    id = 1000 + i
    Set: ^tmp2(id) = id
  
  Killnode:
    ^tmp2(1001)
    ^tmp2(1002)
    ^tmp2(1003)
    ^tmp2(1004)
  
  id = 1005
  Killnode: ^tmp2(id)

  for i in 1005..<1010:
    Killnode: ^tmp2(i)

  let ids = "1012"
  let sub: Subscripts = @["1014"]
  Killnode:
    ^tmp2("1011")
    ^tmp2(ids)
    ^tmp2(@["1013"])
    ^tmp2(sub)

  let refdata = @["1000", "1010", "1015"]
  var dbdata: Subscripts
  
  for subs in QueryItr ^tmp2.keys:
    dbdata.add(subs)
  assert dbdata == refdata


proc testKill3() =
  Kill: ^X

  Set: ^X(1)="hello"
  let s = Get ^X(1)
  assert "hello" == s
  Killnode: ^X(1) # delete node
  assert "" == Get ^X(1)
  
  # create a tree
  Set: ^X(1,1)="hello"
  Set: ^X(1,2)="world"
  Set: ^X(2) = "hello world"
  let dta = Data: ^X(1) 
  assert 10 == dta # Expect no Data but subtree
  Kill: ^X(1)
  assert "" == Get ^X(1)
  let id = 2
  Kill: ^X(id)
  assert "" == Get ^X(id)

proc testDeleteNode() =
    Set: ^GBL="hallo"
    Killnode: ^GBL
    assert "" == Get ^GBL

    let gbl = "^GBL(1)"
    Set: @gbl = "gbl(1)"
    Killnode: @gbl
    assert "" == Get @gbl

    Set: ^GBL1="hallo"
    assert "hallo" == Get ^GBL1
    Killnode: ^GBL1
    assert "" == Get ^GBL1

    Set:
        ^GBL1="gbl1"
        ^GBL2="gbl2"
        ^GBL3="gbl3"
    Killnode:
        ^GBL1
        ^GBL2
        ^GBL3
    assert "" == Get ^GBL1
    assert "" == Get ^GBL2
    assert "" == Get ^GBL3

    Set:
        ^GBL(1)=1
        ^GBL(2)=2
        ^GBL(3)=3
    Killnode:
        ^GBL(1)
        ^GBL(2)
        ^GBL(3)
    assert "" == Get ^GBL(1)
    assert "" == Get ^GBL(2)
    assert "" == Get ^GBL(3)


proc testDeleteTree() =
    Set: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        
    Kill: ^GBL(1)
    assert "" == Get ^GBL(1,1)
    assert "" == Get ^GBL(1,2)
    Kill: ^GBL
    assert "" == Get ^GBL

    let gblname = "^GBL"
    for gbl in QueryItr @gblname:
        assert gbl.len > 0



if isMainModule:
  test "Killnode": testKill1()
  test "Kill": testKill2()
  test "Killnode": testKill3()
  test "testDeleteTree": testDeleteTree()
  test "testDeleteNode": testDeleteNode()
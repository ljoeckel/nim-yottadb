import std/unittest
import yottadb

proc testDelnode() =
  deletevar:
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
  if data(^hello(1, "a")) > 0: delnode: ^hello(1, "a")
  assert data(^hello(1, "a")) == YDB_DATA_UNDEF
  
  delnode: ^hello("2")
  assert data(^hello("2")) == YDB_DATA_UNDEF

  let idStr = "A"
  delnode: ^hello(idStr)
  assert data(^hello(idStr)) == YDB_DATA_UNDEF
  
  let idSub:Subscripts = @["a", "1"]
  delnode: ^hello(idSub)
  assert data(^hello(idSub)) == YDB_DATA_UNDEF

  delnode:
    ^hello(6)
    ^hello("7")

  let gbl = "^hello(8,A)"
  assert 1 == data @gbl
  delnode: @gbl
  assert 0 == data @gbl

proc delnode() =
  var id: int
  # create some records  
  for i in 0..15:
    id = 1000 + i
    setvar: ^tmp2(id) = id
  
  delnode:
    ^tmp2(1001)
    ^tmp2(1002)
    ^tmp2(1003)
    ^tmp2(1004)
  
  id = 1005
  delnode: ^tmp2(id)

  for i in 1005..<1010:
    delnode: ^tmp2(i)

  let ids = "1012"
  let sub: Subscripts = @["1014"]
  delnode:
    ^tmp2("1011")
    ^tmp2(ids)
    ^tmp2(@["1013"])
    ^tmp2(sub)

  let refdata = @["1000", "1010", "1015"]
  var dbdata: Subscripts
  var (rc, subs) = nextnode ^tmp2.seq
  while rc == YDB_OK:
    dbdata.add(subs)
    (rc, subs) = nextnode ^tmp2(subs).seq
  assert dbdata == refdata


proc testDeltree() =
  deletevar: ^X

  setvar: ^X(1)="hello"
  let s = get: ^X(1)
  assert "hello" == s
  delnode: ^X(1) # delete node
  doAssertRaises(YdbError): # expect exception because node removed
    discard get: ^X(1)
  
  # create a tree
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  deltree: ^X(1)
  doAssertRaises(YdbError): # expect exception because node removed
    discard  get: ^X(1)

if isMainModule:
  test "deleteNode": testDelnode()
  test "deleteTree": testDeltree()
  test "delnode": delnode()

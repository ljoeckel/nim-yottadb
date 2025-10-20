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
  var (rc, subs) = nextnode ^tmp2.seq
  while rc == YDB_OK:
    dbdata.add(subs)
    (rc, subs) = nextnode ^tmp2(subs).seq
  assert dbdata == refdata


proc testKill3() =
  kill: ^X

  setvar: ^X(1)="hello"
  let s = getvar  ^X(1)
  assert "hello" == s
  killnode: ^X(1) # delete node
  doAssertRaises(YdbError): # expect exception because node removed
    discard getvar  ^X(1)
  
  # create a tree
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  kill: ^X(1)
  doAssertRaises(YdbError): # expect exception because node removed
    discard  getvar  ^X(1)

if isMainModule:
  test "killNode": testKill1()
  test "kill": testKill2()
  test "killnode": testKill3()

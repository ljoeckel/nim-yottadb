import std/[unittest, strutils]
import yottadb

proc incrementTest() =
  # INCR
  Set: ^CNT("AUTO") = 1
  var autocnt = parseInt(Get ^CNT("AUTO"))
  var c5 = Increment: (^CNT("AUTO"), by=5)
  assert c5 == (autocnt + 5)

  autocnt = Get ^CNT("AUTO").int
  c5 = Increment: ^CNT("AUTO")
  assert c5 == (autocnt + 1)


proc testIncrementLocalsByOne() =
  let keys = @["X","Y","Z"]
  Set: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    CNT(keys) = 3000

  # Increment by 1
  for i in 1..10:
    let cnt = Increment: CNT("1,1")
    assert cnt == 1000 + i
    assert Get(CNT("1,1").int) == 1000 + i

    let c = Increment: CNT(2,2)
    assert c == 2000 + i
    assert Get(CNT(2,2).int) == 2000 + i

    let d = Increment(CNT(keys))
    assert d == 3000 + i
    assert Get(CNT(keys).int) == 3000 + i

    assert 1 == Increment(CNT(i))

proc testIncrementLocalsByTen() =
  let keys = @["X","Y","Z"]
  Set: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    CNT(keys)=3000

  # Increment by 10
  for i in 1..10:
    let cnt = Increment: (CNT("1,1"), by=10)
    assert cnt == 1000 + i*10
    assert Get(CNT("1,1").int) == 1000 + i*10

    let c = Increment: (CNT(2,2), by=10)
    assert c == 2000 + i*10
    assert Get(CNT(2,2).int) == 2000 + i*10

    let d = Increment: (CNT(keys), by=10)
    assert d == 3000 + i*10
    assert Get(CNT(keys).int) == 3000 + i*10

    let e = Increment: (CNT(i), by=10)
    assert 11 == e

proc testIncrementBy() =
    Killnode: ^CNT("XXX")
    var x = Increment: ^CNT("XXX")
    assert x == 1
    x = Increment: (^CNT("XXX"), by=100)
    assert x == 101

    for i in 0..10:
        var z = Increment (local("abc"), by=5)
        assert z == i * 5 + 5

    Killnode: ^CNT("XXX")
    for i in 0..10:
        var z = Increment (^CNT("XXX"), by=5)
        assert z == i * 5 + 5

proc testIncrement1() =  
  # Increment
  Killnode:
    ^CNT("TXID")
    ^cnt
  assert 1 == Increment ^CNT("TXID")
  let incrval = Increment (^CNT("TXID"), by=10)
  assert 11 == incrval
  assert 1 == Increment ^cnt
  assert 11 == Increment (^cnt, by=10)

proc testIncrement2() =
    Set: ^CNT = 0
    var value = Increment: ^CNT
    assert 1 == value
    value = Increment: (^CNT, by=10)
    assert 11 == value

    Set: ^CNT("txid") = 0
    value = Increment: ^CNT("txid")
    assert 1 == value
    value = Increment: (^CNT("txid"), by=10)
    assert 11 == value

    let id = "custid"
    Set: ^CNT(id) = 0
    value = Increment: ^CNT(id)
    assert 1 == value
    value = Increment: (^CNT(id), by=10)
    assert 11 == value

    let gbl = "^CNT(123)"
    Set: @gbl = 0
    value = Increment: @gbl
    assert 1 == value
    value = Increment: (@gbl, by=10)
    assert 11 == value


if isMainModule:
  test "Increment": incrementTest()
  test "incrementLocalsByOne": testIncrementLocalsByOne()
  test "incrementLocalsBy10": testIncrementLocalsByTen()
  test "incrementBy": testIncrementBy()
  test "increment1": testIncrement1()
  test "increment3": testIncrement2()
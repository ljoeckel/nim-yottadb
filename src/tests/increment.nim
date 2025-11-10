import std/[unittest, strutils]
import yottadb

proc incrementTest() =
  # INCR
  setvar: ^CNT("AUTO") = 1
  var autocnt = parseInt(getvar ^CNT("AUTO"))
  var c5 = increment: (^CNT("AUTO"), by=5)
  assert c5 == (autocnt + 5)

  autocnt = getvar  ^CNT("AUTO").int
  c5 = increment: ^CNT("AUTO")
  assert c5 == (autocnt + 1)


proc testIncrementLocalsByOne() =
  let keys = @["X","Y","Z"]
  setvar: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    CNT(keys) = 3000

  # Increment by 1
  for i in 1..10:
    let cnt = increment: CNT("1,1")
    assert cnt == 1000 + i
    assert getvar(CNT("1,1").int) == 1000 + i

    let c = increment: CNT(2,2)
    assert c == 2000 + i
    assert getvar(CNT(2,2).int) == 2000 + i

    let d = increment(CNT(keys))
    assert d == 3000 + i
    assert getvar(CNT(keys).int) == 3000 + i

    assert 1 == increment(CNT(i))

proc testIncrementLocalsByTen() =
  let keys = @["X","Y","Z"]
  setvar: 
    CNT("1,1")=1000
    CNT(2,2)=2000
    CNT(keys)=3000

  # Increment by 10
  for i in 1..10:
    let cnt = increment: (CNT("1,1"), by=10)
    assert cnt == 1000 + i*10
    assert getvar(CNT("1,1").int) == 1000 + i*10

    let c = increment: (CNT(2,2), by=10)
    assert c == 2000 + i*10
    assert getvar(CNT(2,2).int) == 2000 + i*10

    let d = increment: (CNT(keys), by=10)
    assert d == 3000 + i*10
    assert getvar(CNT(keys).int) == 3000 + i*10

    let e = increment: (CNT(i), by=10)
    assert 11 == e

proc testIncrementBy() =
    killnode: ^CNT("XXX")
    var x = increment: ^CNT("XXX")
    assert x == 1
    x = increment: (^CNT("XXX"), by=100)
    assert x == 101

    for i in 0..10:
        var z = increment (local("abc"), by=5)
        assert z == i * 5 + 5

    killnode: ^CNT("XXX")
    for i in 0..10:
        var z = increment (^CNT("XXX"), by=5)
        assert z == i * 5 + 5

proc testIncrement() =  
  # Increment
  killnode:
    ^CNT("TXID")
    ^cnt
  assert 1 == increment ^CNT("TXID")
  let incrval = increment (^CNT("TXID"), by=10)
  assert 11 == incrval
  assert 1 == increment ^cnt
  assert 11 == increment (^cnt, by=10)


if isMainModule:
  test "increment": incrementTest()
  test "incrementLocalsByOne": testIncrementLocalsByOne()
  test "incrementLocalsBy10": testIncrementLocalsByTen()
  test "incrementBy": testIncrementBy()
  test "increment2": testIncrement()
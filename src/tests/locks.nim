import std/unittest
import std/strutils
import yottadb
import ydbutils

proc setupLL() =
  Set:
    ^LL("HAUS")=""
    ^LL("HAUS", "ELEKTRIK")=""
    ^LL("HAUS", "ELEKTRIK", "DOSEN")=""
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "1") = "Telefondose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "2") = "Steckdose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "3") = "IP-Dose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "4") = "KFZ-Dose"
    ^LL("HAUS", "ELEKTRIK", "KABEL")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "FARBEN")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "FIN")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "STAERKEN")=""
    ^LL("HAUS", "ELEKTRIK", "SICHERUNGEN")=""
    ^LL("HAUS", "FLAECHEN", "RAUM1")=""
    ^LL("HAUS", "FLAECHEN", "RAUM2")=""
    ^LL("HAUS", "FLAECHEN", "RAUM2")=""
    ^LL("HAUS", "HEIZUNG")=""
    ^LL("HAUS", "HEIZUNG", "MESSGERAETE")=""
    ^LL("HAUS", "HEIZUNG", "ROHRE")=""
    ^LL("LAND")=""
    ^LL("LAND", "FLAECHEN")=""
    ^LL("LAND", "NUTZUNG")=""
    ^LL("ORT")=""


proc findLocks(ids: varargs[string]): bool =
    result = true
    for str in getLocksFromYottaDb():
        var found: bool
        for id in ids:
            if str.contains(id):
                found = true
                break
        result = result and found

proc intSetLockUpdate() =
  withlock(4711):
    let subs = @["4711", "Acc123"]
    Set:
      ^hello(subs) = 1500  # Set initial amount
    assert "1500" == Get ^hello(subs)
    var amount = Get ^hello(subs).int # get back as int
    amount += 1500
    Set: ^hello(subs) = amount # update db
    assert amount == Get ^hello(subs).int
    assert isLocked(4711)
    
  assert not isLocked(4711)


proc testSimpleLocks() =
    Lock: { ^CNT("TEMPLATE_TEST") }
    assert findLocks("TEMPLATE_TEST")

    var id = "MYID"
    Lock: { ^CNT(id) }
    assert findLocks(id)

    id = "MYID"
    Lock: { ^CNT(id), ^CNT("ABC"), ^XYZ(123) }
    assert findLocks(id, "ABC", "123")

    id = "MYID-1"
    Lock: { ^CNT(id), timeout=1}
    assert findLocks(id)

    id = "MYID-2"
    Lock: { ^CNT(id), ^CNT("ABC-2"), ^XYZ(123) , timeout=2}
    assert findLocks(id, "ABC-2", "123")

    id = "MYID-3"
    Lock: {timeout="3", ^CNT(id), ^CNT("ABC-3"), ^XYZ(123) }
    assert findLocks(id, "ABC-3", "123")

    id = "MYID-4"
    Lock: {timeout=4, ^CNT(id), ^CNT("ABC-4"), ^XYZ(123) }
    assert findLocks(id, "ABC-4", "123")

    id = "MYID-0"
    Lock: {timeout=0, ^CNT(id), ^CNT("ABC-0"), ^XYZ(123) }
    assert findLocks(id, "ABC-0", "123")

    id = "MYID-abc"
    Lock: {timeout="abc", ^CNT(id), ^CNT("ABC"), ^XYZ(123) }
    assert findLocks(id, "ABC", "123")

    id = "MYID-single"
    Lock: { ^CNT(id), timeout=1000000 }
    assert findLocks(id)

proc testLocalVarLocks() =
    Lock: { ^LL }
    assert findLocks("^LL")

    var id = "0815"
    Lock: {^ll(4711), ^xyz("ABC"), ^abc(id), timeout=774455}
    assert findLocks(id, "ABC", "4711", "0815")
    assert getLockCountFromYottaDb() == 3
    
    Lock: { ^globalvar, localvar, ^anotherglobal }
    assert findLocks("^globalvar", "localvar", "^anotherglobal")
    assert getLockCountFromYottaDb() == 3

    Lock: { ^globalvar(4711), localvar(4711), ^anotherglobal(id) }
    assert getLockCountFromYottaDb() == 3
    assert findLocks("4711", id)

    Lock: { localvar }
    assert findLocks("localvar")

    Lock: { localvar(4711) }
    assert findLocks("4711")

    Lock: { localvar, localvar2(4711), localvar("def", 4713) }
    assert getLockCountFromYottaDb() == 3
    assert findLocks("localvar", "4711", "4713", "def")

    Lock: {} # release all locks
    assert getLockCountFromYottaDb() == 0

proc testSingleLineLock() =
    Lock: localvar 
    assert findLocks("localvar")
    assert getLockCountFromYottaDb() == 1
    Lock: localvar(4711)
    assert findLocks("localvar(4711)")
    assert getLockCountFromYottaDb() == 1

    Lock: ^gblvar
    assert findLocks("^gblvar")
    assert getLockCountFromYottaDb() == 1
    Lock: ^gblvar(4711)
    assert findLocks("^gblvar(4711)")
    assert getLockCountFromYottaDb() == 1
    Lock: ^gblvar("abc", 4711)
    assert findLocks("abc", "4711)")
    assert getLockCountFromYottaDb() == 1

    let id="0815"
    Lock: {}
    Lock: +localvar1
    assert getLockCountFromYottaDb() == 1
    Lock: +localvar2(4711)
    assert getLockCountFromYottaDb() == 2
    Lock: +localvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 3
    Lock: +localvar4(id)
    assert getLockCountFromYottaDb() == 4

    
    Lock: -localvar1
    assert getLockCountFromYottaDb() == 3
    Lock: -localvar2(4711)
    assert getLockCountFromYottaDb() == 2
    Lock: -localvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 1
    Lock: -localvar4(id)
    assert getLockCountFromYottaDb() == 0

    Lock: {}
    Lock: +^gblvar1
    assert getLockCountFromYottaDb() == 1
    Lock: +^gblvar2(4711)
    assert getLockCountFromYottaDb() == 2
    Lock: +^gblvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 3
    Lock: +^gblvar4(id)
    assert getLockCountFromYottaDb() == 4
    
    Lock: -^gblvar1
    assert getLockCountFromYottaDb() == 3
    Lock: -^gblvar2(4711)
    assert getLockCountFromYottaDb() == 2
    Lock: -^gblvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 1
    Lock: -^gblvar4(id)
    assert getLockCountFromYottaDb() == 0


proc testLock()  =
  # Set Locks
  Lock:
    {
      ^LL("HAUS", "11"),
      ^LL("HAUS", "12"),
      ^LL("HAUS", "XX"), # not yet existent, but ok
    }
  var numOfLocks = getLockCountFromYottaDb()
  assert 3 == numOfLocks

  Lock: {} # release all locks
  numOfLocks = getLockCountFromYottaDb()
  assert 0 == getLockCountFromYottaDb()
  

proc testLockIncrement() =
  Lock: +^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 1
  Lock: +^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 2
  Lock: +^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  Lock: -^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 2
  Lock: -^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 1
  Lock: -^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 0

  # Increment non existing subscript (Lock will be created)
  Lock: +^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  Lock: -^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Decrement non existing global (Lock will be created)
  Lock: +^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  Lock: -^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Increment 3 times same Lock
  Lock: +^ZZZZ("HAUS", 31)
  assert getLockCountFromYottaDb() == 1
  Lock: +^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  Lock: +^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  # Decrement 3 times
  Lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  Lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  Lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 0


proc testLock2() =
    Lock:
        ^XXX
        ^GBL(2)
        ^GBL(2,3)
        ^GBL(2,3,"abc")
        timeout = 0.002
    assert getLockCountFromYottaDb() == 4

    let gbl = "^GBL(2)"
    Lock: @gbl
    assert getLockCountFromYottaDb() == 1

    Lock: {@gbl}
    assert getLockCountFromYottaDb() == 1

    Lock: { ^XXX, ^GBL(2), ^GBL(2,3), ^GBL(2,3,"abc"), timeout = 0.002}
    assert getLockCountFromYottaDb() == 4

    Lock: {}
    assert getLockCountFromYottaDb() == 0

    Lock: {@gbl}
    assert getLockCountFromYottaDb() == 1
    Lock:
        discard 
    assert getLockCountFromYottaDb() == 0


proc testLockIncrement2() =
    Lock: ^GBL(4711)
    assert getLockCountFromYottaDb() == 1
    Lock: +^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 Lock.count = 1
    Lock: +^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 Lock.count = 2
    Lock: -^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 Lock.count = 1
    Lock: -^GBL(4712)
    assert getLockCountFromYottaDb() == 1 # 4712 removed
    Lock: {}
    assert getLockCountFromYottaDb() == 0



when isMainModule:
    setupLL()
    test "intSetLock": intSetLockUpdate()
    test "Simple locks": testSimpleLocks()
    test "Localvar locks": testLocalvarLocks()
    test "SingleLine locks": testSingleLineLock()
    test "Lock": testLock()
    test "Lock2": testLock2()
    test "LockIncrement": testLockIncrement()
    test "LockIncrement2": testLockIncrement2()
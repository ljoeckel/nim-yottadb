import std/unittest
import std/strutils
import yottadb
import ydbutils

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
    setvar:
      ^hello(subs) = 1500  # Set initial amount
    assert "1500" == getvar ^hello(subs)
    var amount = getvar  ^hello(subs).int # get back as int
    amount += 1500
    setvar: ^hello(subs) = amount # update db
    assert amount == getvar ^hello(subs).int
    assert isLocked(4711)
    
  assert not isLocked(4711)


proc testSimpleLocks() =
    lock: { ^CNT("TEMPLATE_TEST") }
    assert findLocks("TEMPLATE_TEST")

    var id = "MYID"
    lock: { ^CNT(id) }
    assert findLocks(id)

    id = "MYID"
    lock: { ^CNT(id), ^CNT("ABC"), ^XYZ(123) }
    assert findLocks(id, "ABC", "123")

    id = "MYID-1"
    lock: { ^CNT(id), timeout=1}
    assert findLocks(id)

    id = "MYID-2"
    lock: { ^CNT(id), ^CNT("ABC-2"), ^XYZ(123) , timeout=2}
    assert findLocks(id, "ABC-2", "123")

    id = "MYID-3"
    lock: {timeout="3", ^CNT(id), ^CNT("ABC-3"), ^XYZ(123) }
    assert findLocks(id, "ABC-3", "123")

    id = "MYID-4"
    lock: {timeout=4, ^CNT(id), ^CNT("ABC-4"), ^XYZ(123) }
    assert findLocks(id, "ABC-4", "123")

    id = "MYID-0"
    lock: {timeout=0, ^CNT(id), ^CNT("ABC-0"), ^XYZ(123) }
    assert findLocks(id, "ABC-0", "123")

    id = "MYID-abc"
    lock: {timeout="abc", ^CNT(id), ^CNT("ABC"), ^XYZ(123) }
    assert findLocks(id, "ABC", "123")

    id = "MYID-single"
    lock: { ^CNT(id), timeout=1000000 }
    assert findLocks(id)

proc testLocalVarLocks() =
    lock: { ^LL }
    assert findLocks("^LL")

    var id = "0815"
    lock: {^ll(4711), ^xyz("ABC"), ^abc(id), timeout=774455}
    assert findLocks(id, "ABC", "4711", "0815")
    assert getLockCountFromYottaDb() == 3
    
    lock: { ^globalvar, localvar, ^anotherglobal }
    assert findLocks("^globalvar", "localvar", "^anotherglobal")
    assert getLockCountFromYottaDb() == 3

    lock: { ^globalvar(4711), localvar(4711), ^anotherglobal(id) }
    assert getLockCountFromYottaDb() == 3
    assert findLocks("4711", id)

    lock: { localvar }
    assert findLocks("localvar")

    lock: { localvar(4711) }
    assert findLocks("4711")

    lock: { localvar, localvar2(4711), localvar("def", 4713) }
    assert getLockCountFromYottaDb() == 3
    assert findLocks("localvar", "4711", "4713", "def")

    lock: {} # release all locks
    assert getLockCountFromYottaDb() == 0

proc testSingleLineLock() =
    lock: localvar 
    assert findLocks("localvar")
    assert getLockCountFromYottaDb() == 1
    lock: localvar(4711)
    assert findLocks("localvar(4711)")
    assert getLockCountFromYottaDb() == 1

    lock: ^gblvar
    assert findLocks("^gblvar")
    assert getLockCountFromYottaDb() == 1
    lock: ^gblvar(4711)
    assert findLocks("^gblvar(4711)")
    assert getLockCountFromYottaDb() == 1
    lock: ^gblvar("abc", 4711)
    assert findLocks("abc", "4711)")
    assert getLockCountFromYottaDb() == 1

    let id="0815"
    lock: {}
    lock: +localvar1
    assert getLockCountFromYottaDb() == 1
    lock: +localvar2(4711)
    assert getLockCountFromYottaDb() == 2
    lock: +localvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 3
    lock: +localvar4(id)
    assert getLockCountFromYottaDb() == 4

    
    lock: -localvar1
    assert getLockCountFromYottaDb() == 3
    lock: -localvar2(4711)
    assert getLockCountFromYottaDb() == 2
    lock: -localvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 1
    lock: -localvar4(id)
    assert getLockCountFromYottaDb() == 0

    lock: {}
    lock: +^gblvar1
    assert getLockCountFromYottaDb() == 1
    lock: +^gblvar2(4711)
    assert getLockCountFromYottaDb() == 2
    lock: +^gblvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 3
    lock: +^gblvar4(id)
    assert getLockCountFromYottaDb() == 4
    
    lock: -^gblvar1
    assert getLockCountFromYottaDb() == 3
    lock: -^gblvar2(4711)
    assert getLockCountFromYottaDb() == 2
    lock: -^gblvar3("abc", 4711)
    assert getLockCountFromYottaDb() == 1
    lock: -^gblvar4(id)
    assert getLockCountFromYottaDb() == 0


when isMainModule:
    test "intSetLock": intSetLockUpdate()
    test "Simple locks": testSimpleLocks()
    test "Localvar locks": testLocalvarLocks()
    test "SingleLine locks": testSingleLineLock()
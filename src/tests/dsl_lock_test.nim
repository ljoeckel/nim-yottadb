import std/unittest
import std/strutils
import yottadb
import utils
import malebolgia

proc findLocks(ids: varargs[string]): bool =
    result = true
    for s in getLocksFromYottaDb():
        var found: bool
        for id in ids:
            if s.find(id) != -1: 
                found = true
                break
        result = result and found


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

    id = "MYID--1"
    lock: {timeout=-1, ^CNT(id), ^CNT("ABC-1"), ^XYZ(123) }
    assert findLocks(id, "ABC-1", "123")

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


proc demoUpdate1(cnt: int, tn: int) =
    withlock(4711):
        discard increment: ^CNT(4711)
        discard increment: ^CNT(4711, tn)
        withlock(4711.1):
            discard increment: ^CNT("TEMPLATE_TEST")
            discard increment: ^CNT(4711.1)
            discard increment: ^CNT(4711.1, tn)

proc demoUpdate2(cnt: int, tn: int) =
    withlock(4711.1):
        discard increment: ^CNT(4711.1)
        discard increment: ^CNT(4711.1, tn)
        withlock(4711):
            discard increment: ^CNT("TEMPLATE_TEST")
            discard increment: ^CNT(4711)
            discard increment: ^CNT(4711, tn)


proc createThreads(cnt: int, numOfThreads: int) =
  var m = createMaster()
  m.awaitAll:
    for tn in 0..<numOfThreads:
        let tv = tn + 1
        if tv mod 2 == 0:
            m.spawn demoUpdate2(cnt, tn)
        else:
            m.spawn demoUpdate1(cnt, tn)


proc testTryToCreateDeadlock() =
    let numOfThreads = 8
    const maxCount = 1000

    deltree:
        ^CNT(4711)
        ^CNT(4711.1)
    delnode:
        ^CNT("TEMPLATE_TEST")
    
    let ms = timed_ms:
        var cnt = maxCount
        while cnt > 0:
            dec(cnt)
            createThreads(cnt, numOfThreads)

    # Test totals
    let iterations = maxCount * numOfThreads
    var v = get: ^CNT(4711).int
    assert v == iterations
    v = get: ^CNT("4711.1").int
    assert v == iterations
    v = get: ^CNT("TEMPLATE_TEST").int
    assert v == iterations
    echo "Number of Threads: ", numOfThreads, ", Total iterations:", iterations, ", Time per iteration: ", ms.float64 / v.float64, " ms."

    # Test numbers for each thread
    for tn in 0..<numOfThreads:
        v = get: ^CNT(4711, tn).int
        assert v == maxCount
        v = get: ^CNT(4711.1, tn).int
        assert v == maxCount


when isMainModule:
  suite "DSL Lock Tests":
    test "Locks":
      test "Simple locks": testSimpleLocks()
      test "Localvar locks": testLocalvarLocks()
      test "Deadlock test": testTryToCreateDeadlock()

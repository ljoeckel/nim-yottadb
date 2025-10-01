import std/unittest
import yottadb
import utils
import malebolgia


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
      test "Deadlock test": testTryToCreateDeadlock()

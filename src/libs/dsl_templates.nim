import dsl
import utils
import malebolgia


proc demoUpdate1(cnt: int, tn: int) =
    withlock(4711):
        discard incr: ^CNT(4711)
        discard incr: ^CNT(4711, tn)
        withlock(4711.1):
            discard incr: ^CNT("TEMPLATE_TEST")
            discard incr: ^CNT(4711.1)
            discard incr: ^CNT(4711.1, tn)

proc demoUpdate2(cnt: int, tn: int) =
    withlock(4711.1):
        discard incr: ^CNT(4711.1)
        discard incr: ^CNT(4711.1, tn)
        withlock(4711):
            discard incr: ^CNT("TEMPLATE_TEST")
            discard incr: ^CNT(4711)
            discard incr: ^CNT(4711, tn)


proc main(cnt: int, numOfThreads: int) =
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
    const maxCount = 10000

    deltree:
        ^CNT(4711)
        ^CNT(4711.1)
    delnode:
        ^CNT("TEMPLATE_TEST")
    
    var ms = timed:
        var cnt = maxCount
        while cnt > 0:
            dec(cnt)
            if cnt mod 1000 == 0:
                echo "------> ", cnt
            main(cnt, numOfThreads)

    # Test totals
    let iterations = maxCount * numOfThreads
    var v = get: ^CNT(4711).int
    assert v == iterations
    v = get: ^CNT("4711.1").int
    assert v == iterations
    v = get: ^CNT("TEMPLATE_TEST").int
    assert v == iterations
    echo "Total iterations:", iterations, " Time per iteration: ", ms.float64 / v.float64, " ms."

    # Test numbers for each thread
    for tn in 0..<numOfThreads:
        v = get: ^CNT(4711, tn).int
        assert v == maxCount
        v = get: ^CNT(4711.1, tn).int
        assert v == maxCount

    
when isMainModule:
    while true:
        testTryToCreateDeadlock()
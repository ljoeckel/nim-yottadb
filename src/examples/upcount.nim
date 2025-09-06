import std/[times]
import ../yottadb
import ../libs/utils

const MAX = 1000000

proc upcount(): int = # Duration 1319 ms.
    var counter:int
    for cnt in 0..MAX:
        counter = ydbIncrement("^CNT", @["upcount"])
    echo "counter: ", counter

proc upcount_dsl: int = # Duration 1324 ms.
    var counter:int
    for cnt in 0..MAX:
        counter = incr: ^CNT("upcount")
    echo "counter DSL: ", counter

when isMainModule:
    var (ms, rc) = timed:
        upcount()
    (ms, rc) = timed:
        upcount_dsl()

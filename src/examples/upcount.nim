import std/[times]
import ../yottadb
import utils

const MAX = 1000

proc upcount(): int =
    var counter:int
    for cnt in 0..MAX:
        counter = ydbIncrement("^CNT", @["upcount"])
    echo "counter: ", counter

# Is approx 10 times faster
proc upcount_dsl: int =
    var counter:int
    for cnt in 0..MAX:
        counter = incr: ^CNT("upcount")
    echo "counter DSL: ", counter

when isMainModule:
    var (ms, rc) = timed:
        upcount()
    (ms, rc) = timed:
        upcount_dsl()

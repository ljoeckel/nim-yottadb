import std/[times]
import ../yottadb
import ../libs/utils

const MAX = 1000000

proc upcount() = # Duration 1319 ms.
    var counter:int
    for cnt in 0..MAX:
        counter = ydb_increment("^CNT", @["upcount"])
    echo "counter: ", counter

proc upcount_dsl() = # Duration 1324 ms.
    var counter:int
    for cnt in 0..MAX:
        counter = incr: ^CNT("upcount")
    echo "counter DSL: ", counter

when isMainModule:
    timed("upcount"): upcount()
    timed("upcount dsl"): upcount_dsl()

import std/[strformat, strutils, times, os]
import ../yottadb

const MAX = 1000

proc upcount() =
    for cnt in 0..MAX:
        let cnt = ydbIncrement("^CNT", @["upcount"])
        if cnt mod 100 == 0:
            echo "Current counter:", cnt

when isMainModule:
    upcount()

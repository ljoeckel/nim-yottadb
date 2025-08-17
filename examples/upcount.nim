import std/[strformat, strutils, times, os]
import ../yottadb

proc upcount() =
    while true:
        let cnt = ydbIncrement("^COUNTERS", @["upcount"])
        if cnt mod 1000 == 0:
            echo "Current counter:", cnt

when isMainModule:
    upcount()
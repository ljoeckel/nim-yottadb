import std/[times]
import ../yottadb
import ../libs/utils
import ../libs/dsl

const MAX = 10000000

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^hello",@[$id], "hello")

when isMainModule:
    timed("set simple"): setSimple()
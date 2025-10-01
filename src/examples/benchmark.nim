import std/[times, unittest]
import yottadb
import utils

const MAX = 10_000_000

proc upcount() =
    ydb_delete_node("^CNT", @["upcount"])
    for cnt in 0..<MAX:
        discard ydb_increment("^CNT", @["upcount"])

proc upcount_dsl() =
    delnode: ^CNT("upcount")
    for cnt in 0..<MAX:
        discard increment: ^CNT("upcount")

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^BENCHMARK1",@[$id], $id)

proc setSimple_dsl() =
    for id in 0..<MAX:
        set: ^BENCHMARK2(id)=id

proc nextnode() =
    var cnt = 0
    var (rc, subs) = ydb_node_next("^BENCHMARK1")
    while rc == YDB_OK:
        (rc, subs) = ydb_node_next("^BENCHMARK1", subs)
        inc cnt
    assert cnt == MAX

proc nextnode_dsl() =
    var cnt = 0
    var (rc, subs) = nextnode: ^BENCHMARK2()
    while rc == YDB_OK:
        (rc, subs) = nextnode: ^BENCHMARK2(subs)
        inc cnt
    assert cnt == MAX

proc delnode() =
    for id in 0..<MAX:
        ydb_delete_node("^BENCHMARK1", @[$id])

proc delnode_dsl() =
    for id in 0..<MAX:
        delnode: ^BENCHMARK2(id)


when isMainModule:
  suite "Benchmark Tests":
    test("upcount"): timed: upcount()
    test ("upcount dsl"): timed: upcount_dsl()
    test("set simple"): timed: setSimple()
    test("set simple dsl"): timed: setSimple_dsl()
    test("nextnode"): timed: nextnode()
    test("nextnode dsl"): timed: nextnode_dsl()
    test("delnode"): timed: delnode()
    test("delnode dsl"): timed: delnode_dsl()

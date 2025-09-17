import std/[times]
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
        discard incr: ^CNT("upcount")

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^BENCHMARK1",@[$id], $id)

proc setSimple_dsl() =
    for id in 0..<MAX:
        set: ^BENCHMARK2(id)=id

proc nextnode() =
    var 
        rc = YDB_OK
        cnt = 0
        subs: Subscripts

    (rc, subs) = ydb_node_next("^BENCHMARK1", subs)
    while rc == YDB_OK:
        (rc, subs) = ydb_node_next("^BENCHMARK1", subs)
        inc(cnt)
    assert cnt == MAX

proc nextnode_dsl() =
    var 
        rc = YDB_OK
        cnt = 0
        subs: Subscripts

    (rc, subs) = nextn: ^BENCHMARK2()
    while rc == YDB_OK:
        (rc, subs) = nextn: ^BENCHMARK2(subs)
        inc(cnt)
    assert cnt == MAX

proc delnode() =
    for id in 0..<MAX:
        ydb_delete_node("^BENCHMARK1", @[$id])

proc delnode_dsl() =
    for id in 0..<MAX:
        delnode: ^BENCHMARK2(id)


when isMainModule:
    timed("upcount"): upcount()
    timed("upcount dsl"): upcount_dsl()
    timed("set simple"): setSimple()
    timed("set simple dsl"): setSimple_dsl()
    timed("nextnode"): nextnode()
    timed("nextnode dsl"): nextnode_dsl()
    timed("delnode"): delnode()
    timed("delnode dsl"): delnode_dsl()

import std/[times]
import ../yottadb
import ../libs/utils
import ../libs/dsl

const MAX = 10000000

proc upcount() =
    ydb_delete_node("^CNT", @["upcount"])
    var counter:int
    for cnt in 0..<MAX:
        counter = ydb_increment("^CNT", @["upcount"])
    echo "counter: ", counter

proc upcount_dsl() =
    delnode: ^CNT("upcount")
    var counter:int
    for cnt in 0..<MAX:
        counter = incr: ^CNT("upcount")
    echo "counter DSL: ", counter

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
    echo "Subscripts: ", cnt

proc nextnode_dsl() =
    var 
        rc = YDB_OK
        cnt = 0
        subs: Subscripts

    (rc, subs) = nextn: ^BENCHMARK2()
    while rc == YDB_OK:
        (rc, subs) = nextn: ^BENCHMARK2(subs)
        inc(cnt)
    echo "Subscripts: ", cnt

proc delnode() =
    for id in 0..<MAX:
        ydb_delete_node("^BENCHMARK1", @[$id])

proc delnode_dsl() =
    for id in 0..<MAX:
        delnode: ^BENCHMARK2(id)

when isMainModule:
    echo "upcount api"
    timed: upcount() # 10256ms
    echo "upcount dsl" 
    timed: upcount_dsl() # 10360ms
    echo "setSimple"
    timed: setSimple() # 9766ms
    echo "setSimple_dsl"
    timed: setSimple_dsl() # 9464ms
    echo "nextnode api"
    timed: nextnode() # 21215ms
    echo "nextnode dsl"
    timed: nextnode_dsl() # 21438ms
    echo "delnode api"
    timed: delnode() # 8878ms
    echo "delnode dsl"
    timed: delnode_dsl() # 8922ms

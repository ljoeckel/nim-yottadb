import std/[times, unittest, strutils]
import yottadb
import ydbutils

const MAX = 10_000_000

kill:
    ^BENCHMARK
    ^BENCHMARK2
    ^BENCHMARK3

proc isEmpty(name: string): bool =
    let s = query name
    result = (s == "")

proc upcount() =
    # api
    kill: ("^CNT", @["upcount"])
    for cnt in 0..<MAX:
        discard ydb_increment("^CNT", @["upcount"])
    assert MAX == parseInt(ydb_get("^CNT", @["upcount"]))

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^BENCHMARK1",@[$id], $id)

proc getSimple() =
    for id in 0..<MAX:
        let val = ydb_get("^BENCHMARK1",@[$id])
        assert $id == val

proc query() =
    var cnt = 0
    var (rc, subs) = ydb_node_next("^BENCHMARK1")
    while rc == YDB_OK:
        (rc, subs) = ydb_node_next("^BENCHMARK1", subs)
        inc cnt
    assert cnt == MAX

proc killnode() =
    for id in 0..<MAX:
        ydb_delete_node("^BENCHMARK1", @[$id])
    assert isEmpty("^BENCHMARK1")


proc upcount_dsl() =
    # dsl
    kill: ^CNT("upcount")
    for cnt in 0..<MAX:
        discard increment: ^CNT("upcount")
    assert MAX == getvar ^CNT("upcount").int

proc setSimple_dsl() =
    for id in 0..<MAX:
        setvar: ^BENCHMARK2(id)=id

proc getSimple_dsl() =
    for id in 0..<MAX:
        let val = getvar ^BENCHMARK2(id)
        assert $id == val

proc query_dsl() =
    var cnt = 0
    for subs in queryItr ^BENCHMARK2:
        inc cnt
    assert cnt == MAX

proc killnode_dsl() =
    for id in 0..<MAX:
        killnode: ^BENCHMARK2(id)
    assert isEmpty("^BENCHMARK2")

proc upcount_indirect() =
    var gblcnt = "^CNT(upcount)"
    kill: @gblcnt
    for cnt in 0..<MAX:
        discard increment: @gblcnt
    assert MAX == getvar @gblcnt.int

proc setSimple_indirect() =
    let gbl = "^BENCHMARK3"
    for id in 0..<MAX:
        setvar: @gbl(id) = id

proc getSimple_indirect() =
    let gbl = "^BENCHMARK3"
    for id in 0..<MAX:
        let val = getvar @gbl(id)
        assert $id == val
        
proc query_indirect() =
    var cnt = 0
    let gblName = "^BENCHMARK3"
    for gbl in queryItr @gblName:
        inc cnt
    assert cnt == MAX

proc killnode_indirect() =
    let gbl = "^BENCHMARK3"
    for id in 0..<MAX:
        kill: @gbl(id)
    assert isEmpty("^BENCHMARK3")


when isMainModule:
    echo "MAX=", MAX

    timed:
        suite "API":
            test "upcount": timed: upcount()
            test "set simple": timed: setSimple()
            test "get simple": timed: getSimple()
            test "query": timed: query()
            test "killnode": timed: killnode()
        echo ""

    timed:
        suite "DSL":
            test "upcount dsl": timed: upcount_dsl()
            test "set simple dsl": timed: setSimple_dsl()
            test "get simple dsl": timed: getSimple_dsl()            
            test "query dsl": timed: query_dsl()
            test "killnode dsl": timed: killnode_dsl()
        echo ""

    timed:
        suite "Indirection":
            test "upcount @": timed: upcount_indirect()
            test "set simple @": timed: setSimple_indirect()
            test "get simple @": timed: getSimple_indirect()
            test "query @": timed: query_indirect()
            test "killnode @": timed: killnode_indirect()

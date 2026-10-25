import std/[times, unittest, strutils]
import yottadb
import ydbutils

const MAX = 1_000_000


proc isEmpty(name: string): bool =
    let s = Query name
    result = (s == "")

proc clean() =
    Kill:
        ^BENCHMARK
        ^CNT("upcount")


proc upcount() =
    # api
    var k = initYdbKey("^CNT", "upcount")
    for cnt in 0..<MAX:
        discard ydb_increment(k)
    assert MAX == parseInt(ydb_get(k))

proc setSimple() =
    var k = initYdbKey("^BENCHMARK")
    for id in 0..<MAX:
        k.setSub(0, id)
        ydb_set(k, $id)

proc getSimple() =
    var k = initYdbKey("^BENCHMARK")
    for id in 0..<MAX:
        k.setSub(0, id)
        let val = ydb_get(k)
        assert $id == val

proc query() =
    var cnt = 0
    var cur = initYdbKey("^BENCHMARK")
    while ydb_node_next(cur) == YDB_OK:
        inc cnt
    assert cnt == MAX

proc order() =
    var cnt = 0
    var k = initYdbKey("^BENCHMARK")
    var nxt = ""
    while ydb_subscript_next(k, nxt) == YDB_OK:
        inc cnt
    assert cnt == MAX

proc killnode() =
    var k = initYdbKey("^BENCHMARK")
    for id in 0..<MAX:
        k.setSub(0, id)
        ydb_delete(k, YDB_DEL_NODE)
    assert isEmpty("^BENCHMARK")



proc upcount_dsl() =
    # dsl
    for cnt in 0..<MAX:
        discard Increment ^CNT("upcount")
    assert MAX == Get ^CNT("upcount").int

proc setSimple_dsl() =
    for id in 0..<MAX:
        Set: ^BENCHMARK(id)=id

proc getSimple_dsl() =
    for id in 0..<MAX:
        let val = Get ^BENCHMARK(id)
        assert $id == val

proc query_dsl() =
    var cnt = 0
    for subs in QueryItr ^BENCHMARK:
        inc cnt
    assert cnt == MAX

proc order_dsl() =
    var cnt = 0
    for subs in OrderItr ^BENCHMARK:
        inc cnt
    assert cnt == MAX

proc killnode_dsl() =
    for id in 0..<MAX:
        Killnode: ^BENCHMARK(id)
    assert isEmpty("^BENCHMARK")

proc upcount_indirect() =
    var gblcnt = "^CNT(upcount)"
    Kill: @gblcnt
    for cnt in 0..<MAX:
        discard Increment @gblcnt
    assert MAX == Get @gblcnt.int

proc setSimple_indirect() =
    let gbl = "^BENCHMARK"
    for id in 0..<MAX:
        Set: @gbl(id) = id

proc getSimple_indirect() =
    let gbl = "^BENCHMARK"
    for id in 0..<MAX:
        let val = Get @gbl(id)
        assert $id == val
        
proc query_indirect() =
    var cnt = 0
    let gblName = "^BENCHMARK"
    for gbl in QueryItr @gblName:
        inc cnt
    assert cnt == MAX

proc order_indirect() =
    var cnt = 0
    let gblName = "^BENCHMARK"
    for gbl in OrderItr @gblName:
        inc cnt
    assert cnt == MAX

proc killnode_indirect() =
    let gbl = "^BENCHMARK"
    for id in 0..<MAX:
        Kill: @gbl(id)
    assert isEmpty("^BENCHMARK")


when isMainModule:
    echo "MAX=", MAX

    timed:
        suite "API":
            clean()
            test "upcount": timed: upcount()
            test "set simple": timed: setSimple()
            test "get simple": timed: getSimple()
            test "ydb_next": timed: query()
            test "ydb_subscript": timed: order()
            test "Killnode": timed: killnode()
        echo ""

    timed:
        suite "DSL":
            clean()
            test "upcount dsl": timed: upcount_dsl()
            test "set simple dsl": timed: setSimple_dsl()
            test "get simple dsl": timed: getSimple_dsl()            
            test "Query dsl": timed: query_dsl()
            test "Order dsl": timed: order_dsl()
            test "Killnode dsl": timed: killnode_dsl()
        echo ""

    timed:
        suite "Indirection":
            clean()
            test "upcount @": timed: upcount_indirect()
            test "set simple @": timed: setSimple_indirect()
            test "get simple @": timed: getSimple_indirect()
            test "Query @": timed: query_indirect()
            test "Order @": timed: order_indirect()
            test "Killnode @": timed: killnode_indirect()

    clean()
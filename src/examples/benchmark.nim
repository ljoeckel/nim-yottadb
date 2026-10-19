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
    for cnt in 0..<MAX:
        discard ydb_increment("^CNT", @["upcount"])
    assert MAX == parseInt(ydb_get("^CNT", @["upcount"]))

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^BENCHMARK",@[$id], $id)

proc getSimple() =
    for id in 0..<MAX:
        let val = ydb_get("^BENCHMARK",@[$id])
        assert $id == val

proc query() =
    var cnt = 0
    var (rc, subs) = ydb_node_next("^BENCHMARK")
    while rc == YDB_OK:
        (rc, subs) = ydb_node_next("^BENCHMARK", subs)
        inc cnt
    assert cnt == MAX

proc order() =
    var cnt = 0
    var key = ydb_subscript_next("^BENCHMARK")
    while key.len > 0:
        key = ydb_subscript_next("^BENCHMARK", @[key])
        inc cnt
    assert cnt == MAX

proc killnode() =
    for id in 0..<MAX:
        ydb_delete("^BENCHMARK", @[$id], YDB_DEL_NODE)
    assert isEmpty("^BENCHMARK")



proc upcountYK() =
    # api
    var key = initYdbKey("^CNT", "upcount")
    for cnt in 0..<MAX:
        discard ydb_increment(key)
    assert MAX == parseInt(ydb_get(key))

proc setSimpleYK() =
    var key = initYdbKey("^BENCHMARK", "")
    for id in 0..<MAX:
        key.setSub(0, $id)
        ydb_set(key, $id)

proc getSimpleYK() =
    var key = initYdbKey("^BENCHMARK", "")
    for id in 0..<MAX:
        key.setSub(0, $id)
        let val = ydb_get(key)
        assert $id == val

proc queryYK() =
    var cnt = 0
    var cur = initYdbKey("^BENCHMARK") 
    while ydb_node_next(cur) ==  YDB_OK:
        inc cnt
    assert cnt == MAX

proc orderYK() =
    var cnt = 0
    var k = initYdbKey("^BENCHMARK")
    var nxt = ""
    while ydb_subscript_next(k, nxt) == YDB_OK:
        inc cnt
    assert cnt == MAX

proc killnodeYK() =
    var key = initYdbKey("^BENCHMARK", "")
    for id in 0..<MAX:
        key.setSub(0, $id)
        ydb_delete(key, YDB_DEL_NODE)
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
        suite "API YdbKey":
            clean()
            test "upcount": timed: upcountYK()
            test "set simple": timed: setSimpleYK()
            test "get simple": timed: getSimpleYK()
            test "ydb_next": timed: queryYK()
            test "ydb_subscript": timed: orderYK()
            test "Killnode": timed: killnodeYK()
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
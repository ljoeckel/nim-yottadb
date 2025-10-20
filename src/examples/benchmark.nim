import std/[times, unittest, strformat]
import yottadb
import ydbutils

const MAX = 10_000_000

kill:
    ^BENCHMARK
    ^BENCHMARK2

proc isEmpty(name: string): bool =
    var (rc, s) = nextnode: name
    result = (rc == YDB_ERR_NODEEND)

proc upcount() =
    # api
    kill: ("^CNT", @["upcount"])
    for cnt in 0..<MAX:
        discard ydb_increment("^CNT", @["upcount"])

proc upcount_dsl() =
    # dsl
    kill: ^CNT("upcount")
    for cnt in 0..<MAX:
        discard increment: ^CNT("upcount")

proc upcount_indirect() =
    var gblcnt = "^CNT(upcount)"
    kill: @gblcnt
    for cnt in 0..<MAX:
        discard increment: @gblcnt

proc setSimple() =
    for id in 0..<MAX:
        ydb_set("^BENCHMARK1",@[$id], $id)

proc setSimple_dsl() =
    for id in 0..<MAX:
        setvar: ^BENCHMARK2(id)=id

proc setSimple_indirect() =
    for id in 0..<MAX:
        let gbl = fmt"^BENCHMARK2({id})"
        setvar: @gbl

proc nextnode() =
    var cnt = 0
    var (rc, subs) = ydb_node_next("^BENCHMARK1")
    while rc == YDB_OK:
        (rc, subs) = ydb_node_next("^BENCHMARK1", subs)
        inc cnt
    assert cnt == MAX

proc nextnode_dsl() =
    var cnt = 0
    var (rc, subs) = nextnode: ^BENCHMARK2.seq
    while rc == YDB_OK:
        (rc, subs) = nextnode: ^BENCHMARK2(subs).seq
        inc cnt
    assert cnt == MAX

proc nextnode_indirect() =
    var cnt = 0
    var (rc, gbl) = nextnode: ^BENCHMARK2
    while rc == YDB_OK:
        (rc, gbl) = nextnode: @gbl
        inc cnt
    assert cnt == MAX

proc killnode() =
    for id in 0..<MAX:
        ydb_delete_node("^BENCHMARK1", @[$id])
    var (rc, s) = nextnode: ^BENCHMARK1
    assert isEmpty("^BENCHMARK1")

proc killnode_dsl() =
    for id in 0..<MAX:
        killnode: ^BENCHMARK2(id)
    assert isEmpty("^BENCHMARK2")

proc killnode_indirect() =
    for id in 0..<MAX:
        let gbl = fmt"^BENCHMARK2({id})"
        kill: @gbl
    assert isEmpty("^BENCHMARK2")

when isMainModule:
  suite "Benchmark Tests":
    test "upcount": timed: upcount()
    test "upcount dsl": timed: upcount_dsl()
    test "upcount @": timed: upcount_indirect()
    test "set simple": timed: setSimple()
    test "set simple dsl": timed: setSimple_indirect()
    test "set simple @": timed: setSimple_dsl()
    test "nextnode": timed: nextnode()
    test "nextnode dsl": timed: nextnode_dsl()
    test "nextnode @": timed: nextnode_indirect()
    test "killnode": timed: killnode()
    test "killnode dsl": timed: killnode_dsl()
    test "set simple dsl": timed: setSimple_indirect()
    test "killnode @": timed: killnode_indirect()

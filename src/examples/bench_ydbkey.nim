import std/[times, strutils]
import yottadb

# Micro benchmark: Subscripts based API vs. reusable YdbKey API.
#   nim c -r -d:release -d:danger src/examples/bench_ydbkey.nim

const N = 1_000_000

template bench(label: string, body: untyped) =
  block:
    let t0 = cpuTime()
    body
    echo label.alignLeft(22), formatFloat(cpuTime() - t0, ffDecimal, 3), " s"

proc copyVar(v: YdbVar): YdbVar = result = v
proc copyKey(k: YdbKey): YdbKey = result = k

when isMainModule:
  var clean = initYdbKey("^bkey")
  ydb_delete(clean, YDB_DEL_TREE)
  var clean2 = initYdbKey("^bkeycnt")
  ydb_delete(clean2, YDB_DEL_TREE)

  bench "set   (Subscripts)":
    var id = 0
    while id < N:
      ydb_set("^bkey", @[$id], "value")
      inc id

  clean = initYdbKey("^bkey")
  ydb_delete(clean, YDB_DEL_TREE)

  bench "set   (YdbKey)":
    var k = initYdbKey("^bkey")
    var id = 0
    while id < N:
      k.setSub(0, id)
      ydb_set(k, "value")
      inc id

  bench "get   (Subscripts)":
    var id = 0
    while id < N:
      if ydb_get("^bkey", @[$id]) != "value": quit("bad value")
      inc id

  bench "get   (YdbKey)":
    var k = initYdbKey("^bkey")
    var id = 0
    while id < N:
      k.setSub(0, id)
      if ydb_get(k) != "value": quit("bad value")
      inc id

  var c1 = initYdbKey("^bkeycnt", "n")
  bench "incr  (Subscripts)":
    var i = 0
    while i < N:
      discard ydb_increment("^bkeycnt", @["n"])
      inc i

  ydb_delete(clean2, YDB_DEL_TREE)

  bench "incr  (YdbKey)":
    var i = 0
    while i < N:
      discard ydb_increment(c1)
      inc i

  bench "node_next (Subscripts)":
    var cnt = 0
    var (rc, subs) = ydb_node_next("^bkey")
    while rc == YDB_OK:
      (rc, subs) = ydb_node_next("^bkey", subs)
      inc cnt
    if cnt != N: quit("bad count " & $cnt)

  bench "node_next (YdbKey)":
    var k = initYdbKey("^bkey")
    var cnt = 0
    while ydb_node_next(k) == YDB_OK:
      inc cnt
    if cnt != N: quit("bad count " & $cnt)

  # DSL for comparison: YdbVar is constructed per statement
  bench "set   (DSL)":
    for id in 0..<N:
      Set: ^bkey(id) = "value"

  bench "get   (DSL)":
    for id in 0..<N:
      if (Get ^bkey(id)) != "value": quit("bad value")

  bench "node_next (DSL)":
    var cnt = 0
    for subs in QueryItr ^bkey:
      inc cnt
    if cnt != N: quit("bad count " & $cnt)

  # What a YdbKey field in YdbVar would cost on every statement:
  # copying the descriptor (resolveVar does exactly this).
  var protoVar = YdbVar(name: "^bkey", subscripts: @["1"])
  bench "copy  (YdbVar)":
    var sink = 0
    for i in 0..<N:
      sink += copyVar(protoVar).name.len
    if sink != N * 5: quit("bad copy")

  var protoKey = initYdbKey("^bkey", "1")
  bench "copy  (YdbKey)":
    var sink = 0
    for i in 0..<N:
      sink += copyKey(protoKey).nsubs
    if sink != N: quit("bad copy")

  # what the macro currently emits for every subscript expression
  bench "build @[$int]":
    var sink = 0
    for i in 0..<N:
      let subs = @[$i]
      sink += subs[0].len
    if sink == 0: quit("bad subs")

  # whole YdbVar built per DSL statement
  bench "build YdbVar":
    var sink = 0
    for i in 0..<N:
      let v = ydbVar("", "^bkey", "", "", @[$i])
      sink += v.name.len
    if sink == 0: quit("bad var")

  # what YdbKey/stack based construction costs instead
  bench "build SubBuf":
    var sink = 0
    var k = initYdbKey("^bkey")
    for i in 0..<N:
      k.setSub(0, i)
      sink += k.subs[0].len
    if sink == 0: quit("bad subs")


  ydb_delete(clean, YDB_DEL_TREE)

  ydb_delete(clean, YDB_DEL_TREE)

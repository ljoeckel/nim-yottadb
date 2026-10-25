import std/[unittest, strutils]
import yottadb

# Tests for the reusable, allocation-free YdbKey API.

const GBL = "^ydbkeytest"

proc wipe() =
  var k = initYdbKey(GBL)
  ydb_delete(k, YDB_DEL_TREE)

suite "YdbKey":

  test "set/get with string and int subscripts":
    wipe()

    var k = initYdbKey(GBL)
    k.addSub("a")
    k.addSub(1)
    ydb_set(k, "hello")
    check ydb_get(k) == "hello"
    check ydb_data(k) == 1
    check $k == "^ydbkeytest(a,1)"
    check k.subCount == 2
    check k.subscript(0) == "a"
    check k.subscript(1) == "1"
    check k.subscripts() == @["a", "1"]

    var same = initYdbKey(GBL, "a", "1")
    check ydb_get(same) == "hello"

    # same key, different subscript -> different node
    k.setSub(1, 2)
    check ydb_get(k) == ""
    check ydb_data(k) == 0

    ydb_set(k, "two")
    check ydb_get(k) == "two"
    check ydb_get(same) == "hello"
    check $k == "^ydbkeytest(a,2)"

  test "empty value":
    wipe()

    var k = initYdbKey(GBL, "empty")
    ydb_set(k, "")
    check ydb_data(k) == 1
    check ydb_get(k) == ""
    var asString = initYdbKey(GBL, "empty")
    check ydb_get(asString) == ""

  test "delete":
    wipe()

    var k = initYdbKey(GBL, "del")
    ydb_set(k, "v")
    check ydb_data(k) == 1
    ydb_delete(k, YDB_DEL_NODE)
    check ydb_data(k) == 0

    var t = initYdbKey(GBL)
    var c = initYdbKey(GBL, "tree")
    ydb_set(c, "v")
    c.addSub("child")
    ydb_set(c, "v2")
    check ydb_data(t) == 10
    ydb_delete(t, YDB_DEL_TREE)
    check ydb_data(t) == 0

  test "increment":
    wipe()

    var k = initYdbKey(GBL, "cnt")
    check ydb_increment(k) == 1
    check ydb_increment(k, 41) == 42
    check ydb_increment(k, -2) == 40
    check ydb_get(k) == "40"

  test "node traversal in place (next/previous)":
    wipe()

    var k = initYdbKey(GBL)
    k.addSub(1)
    ydb_set(k, "one")
    k.addSub(1)
    ydb_set(k, "one-one")
    k.setSubsLen(1)
    k.setSub(0, 2)
    ydb_set(k, "two")

    var cur = initYdbKey(GBL)
    var seen: seq[string]
    while ydb_node_next(cur) == YDB_OK:
      seen.add cur.subscripts().join("|")
    check seen == @["1", "1|1", "2"]

    var prev = initYdbKey(GBL)
    check ydb_node_previous(prev) == YDB_OK
    check prev.subscripts() == @["2"]

  test "node traversal with long subscripts (INVSTRLEN retry)":
    wipe()

    let longSub = 's'.repeat(500)
    var k = initYdbKey(GBL, longSub)
    ydb_set(k, "long")

    var cur = initYdbKey(GBL)
    check ydb_node_next(cur) == YDB_OK
    check cur.subscripts() == @[longSub]
    check ydb_get(cur) == "long"

  test "subscript traversal":
    wipe()

    var k = initYdbKey(GBL, "1")
    ydb_set(k, "a")
    k.setSub(0, "2")
    ydb_set(k, "b")

    var nxt = ""
    var sk = initYdbKey(GBL)
    var got: seq[string]
    while ydb_subscript_next(sk, nxt) == YDB_OK:
      got.add nxt
    check got == @["1", "2"]
    check sk.subCount == 1
    check sk.subscript(0) == "2"     # cursor is at the last subscript

    var pv = ""
    var pk = initYdbKey(GBL)
    var back: seq[string]
    while ydb_subscript_previous(pk, pv) == YDB_OK:
      back.add pv
    check back == @["2", "1"]

  test "index out of range raises YdbError":
    var k = initYdbKey(GBL)
    expect YdbError:
      k.setSub(-1, "x")
    expect YdbError:
      k.setSub(YDB_MAX_SUBS, "x")
    expect YdbError:
      k.delSub(0)

  test "lock increment/decrement":
    wipe()

    var k = initYdbKey(GBL, "lock")
    ydb_lock_incr(1_000_000_000, k)
    ydb_lock_decr(k)

  test "large value (1 MiB block path)":
    wipe()

    var k = initYdbKey(GBL, "blob")

    let exact = 'x'.repeat(YDB_MAX_BUF_SIZE)
    ydb_set(k, exact)
    check ydb_get(k) == exact
    check ydb_data(k) == 1         # fits into a single value

    # exact block boundary + 1 used to lose the last byte
    let plusOne = 'y'.repeat(YDB_MAX_BUF_SIZE + 1)
    ydb_set(k, plusOne)
    check ydb_data(k) == 10        # no value, but children (blocks)
    check ydb_get(k) == plusOne

    let multi = "0123456789".repeat(300_000)   # 3 MiB
    ydb_set(k, multi)
    check ydb_get(k) == multi

    # cross-check that a freshly built key sees the reassembled value
    var cross = initYdbKey(GBL, "blob")
    check ydb_get(cross) == multi

    ydb_delete(k, YDB_DEL_TREE)
    check ydb_get(k) == ""

  test "copy keeps the key usable":
    wipe()

    var a = initYdbKey(GBL, "copy")
    ydb_set(a, "v1")

    var b = a                 # =copy must rebuild the cached buffer pointers
    ydb_set(b, "v2")
    check ydb_get(a) == "v2"  # same node

    b.setSub(0, "copy2")
    ydb_set(b, "other")
    check ydb_get(a) == "v2"
    check ydb_get(b) == "other"
    check $a == "^ydbkeytest(copy)"
    check $b == "^ydbkeytest(copy2)"

  test "keys built incrementally match keys built from strings":
    wipe()

    var keys = initYdbKey(GBL)
    for i in 0..<50:
      keys.addSub(i)
      ydb_set(keys, "value-" & $i)
      var fromString = initYdbKey(GBL, $i)
      check ydb_get(fromString) == "value-" & $i
      check ydb_get(keys) == "value-" & $i
      keys.clearSubs()

    for i in 0..<50:
      var k = initYdbKey(GBL, $i)
      check ydb_get(k) == "value-" & $i

import std/[unittest]
import yottadb

const global = "^gbl"

proc setup() =
    kill: ^gbl
    for i in 1..5:
        setvar: ^gbl(i) = i
        setvar: local(i) = i
    setvar:
        ^gbl(1,1)="1.1"
        ^gbl(2,2)="2.2"
        local(1,1)="1.1"
        local(2,2)="2.2"


proc testQuery() =
  let refdata = @["^gbl(1)", "^gbl(1,1)", "^gbl(2)", "^gbl(2,2)", "^gbl(3)", "^gbl(4)", "^gbl(5)"]
  let refdata2 = @["^gbl(2,2)", "^gbl(3)", "^gbl(4)", "^gbl(5)"]

  let reflocal = @["local(1)", "local(1,1)", "local(2)", "local(2,2)", "local(3)", "local(4)", "local(5)"]
  let reflocal2 = @["local(2,2)", "local(3)", "local(4)", "local(5)"]

  block:
    var subs: seq[string]
    for sub in queryItr ^gbl:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr local:
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in queryItr ^gbl(2):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in queryItr local(2):
      subs.add(sub)
    assert subs == reflocal2

  block:
    var subs: seq[string]
    for sub in queryItr(^gbl):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(local):
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in queryItr(^gbl(2)):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in queryItr(local(2)):
      subs.add(sub)
    assert subs == reflocal2

  block:
    var subs: seq[string]
    for sub in queryItr @global:
      subs.add(sub)
    assert subs == refdata

  # block: TODO: Implement indirection on locals?
  #   var subs: seq[string]
  #   for sub in queryItr @local:
  #     subs.add(sub)
  #   assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in queryItr @global(2):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in queryItr(@global):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(@global(2)):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in queryItr "^gbl":
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr local:
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in queryItr "^gbl(2)":
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in queryItr("^gbl"):
      subs.add(sub)
    assert subs == refdata


proc testQueryReverse() =
  let refdata = @["^gbl(5)","^gbl(4)","^gbl(3)","^gbl(2,2)","^gbl(2)","^gbl(1,1)","^gbl(1)"]

  block:
    var subs: seq[string]
    for sub in queryItr ^gbl.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(^gbl.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr @global.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(@global.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr "^gbl".reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr("^gbl".reverse):
      subs.add(sub)
    assert subs == refdata



proc testQueryValue() =
  let refdata = @["1", "1.1", "2", "2.2", "3", "4","5"]
  block:
    var subs: seq[string]
    for sub in queryItr ^gbl.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(^gbl.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr @global.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(@global.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr "^gbl".val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr("^gbl".val):
      subs.add(sub)
    assert subs == refdata

proc testQueryValueReverse() =
  let refdata = @["5","4","3","2.2","2","1.1","1"]
  block:
    var subs: seq[string]
    for sub in queryItr ^gbl.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(^gbl.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr @global.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr(@global.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr "^gbl".val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in queryItr("^gbl".val.reverse):
      subs.add(sub)
    assert subs == refdata


proc testQueryKv() =
  let refdataKeys = @["^gbl(1)", "^gbl(1,1)", "^gbl(2)", "^gbl(2,2)", "^gbl(3)", "^gbl(4)", "^gbl(5)"]
  let refdataValues = @["1", "1.1", "2", "2.2", "3", "4","5"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr ^gbl.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr(^gbl.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr @global.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr(@global.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr "^gbl".kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr("^gbl".kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

proc testQueryKvReverse() =
  let refdataKeys = @["^gbl(5)","^gbl(4)","^gbl(3)","^gbl(2,2)","^gbl(2)","^gbl(1,1)","^gbl(1)"]
  let refdataValues = @["5","4","3","2.2","2","1.1","1"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr ^gbl.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr(^gbl.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr @global.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr(@global.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr "^gbl".kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in queryItr("^gbl".kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values


proc testQueryKeys() =
  let refdata = @[@["1"],@["1", "1"],@["2"],@["2", "2"],@["3"],@["4"],@["5"]  ]

  block:
    var subs: seq[seq[string]]
    for sub in queryItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr(^gbl.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr @global.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr(@global.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr "^gbl".keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr("^gbl".keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

proc testQueryKeysReverse() =
  let refdata = @[@["5"],@["4"],@["3"],@["2", "2"],@["2"],@["1", "1"],@["1"]]

  block:
    var subs: seq[seq[string]]
    for sub in queryItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr(^gbl.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr @global.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr(@global.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr "^gbl".keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr("^gbl".keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in queryItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs


proc testQueryCount() =
  let refdata = 7

  block:
    for count in queryItr ^gbl.count:
      assert refdata == count

  block:
    for count in queryItr(^gbl.count):
      assert refdata == count

  block:
    for count in queryItr @global.count:
      assert refdata == count

  block:
    for count in queryItr(@global.count):
      assert refdata == count

  block:
    for count in queryItr "^gbl".count:
      assert refdata == count

  block:
    for count in queryItr("^gbl".count):
      assert refdata == count

  block:
    for count in queryItr ^gbl.count:
      assert refdata == count


proc testQueryCountReverse() =
  let refdata = 7

  block:
    for count in queryItr ^gbl.count.reverse:
      assert refdata == count

  block:
    for count in queryItr(^gbl.count.reverse):
      assert refdata == count

  block:
    for count in queryItr @global.count.reverse:
      assert refdata == count

  block:
    for count in queryItr(@global.count.reverse):
      assert refdata == count

  block:
    for count in queryItr "^gbl".count.reverse:
      assert refdata == count

  block:
    for count in queryItr("^gbl".count.reverse):
      assert refdata == count

  block:
    for count in queryItr ^gbl.count.reverse:
      assert refdata == count


# -----------------
# order
# -----------------

proc testOrder() =
  let refdata = @["1", "2", "3", "4", "5"]

  block:
    var subs: seq[string]
    for sub in orderItr ^gbl:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(^gbl):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr @global:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(@global):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr "^gbl":
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr("^gbl"):
      subs.add(sub)
    assert subs == refdata

proc testOrderReverse() =
  let refdata = @["5", "4", "3", "2", "1"]

  block:
    var subs: seq[string]
    for sub in orderItr ^gbl.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(^gbl.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr @global.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(@global.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr "^gbl".reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr("^gbl".reverse):
      subs.add(sub)
    assert subs == refdata


proc testOrderValue() =
  let refdata = @["1", "2", "3", "4", "5"]
  block:
    var subs: seq[string]
    for sub in orderItr ^gbl.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(^gbl.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr @global.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(@global.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr "^gbl".val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr("^gbl".val):
      subs.add(sub)
    assert subs == refdata

proc testOrderValueReverse() =
  let refdata = @["5", "4", "3", "2", "1"]
  block:
    var subs: seq[string]
    for sub in orderItr ^gbl.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(^gbl.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr @global.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr(@global.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr "^gbl".val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in orderItr("^gbl".val.reverse):
      subs.add(sub)
    assert subs == refdata


proc testOrderKv() =
  let refdataKeys = @["1", "2", "3", "4", "5"]
  let refdataValues = @["1", "2", "3", "4", "5"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr ^gbl.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr(^gbl.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr @global.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr(@global.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr "^gbl".kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr("^gbl".kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

proc testOrderKvReverse() =
  let refdataKeys = @["5", "4", "3", "2", "1"]
  let refdataValues = @["5", "4", "3", "2", "1"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr ^gbl.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr(^gbl.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr @global.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr(@global.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr "^gbl".kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in orderItr("^gbl".kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values


proc testOrderKeys() =
  let refdata = @[@["1"], @["2"], @["3"], @["4"], @["5"]]

  block:
    var subs: seq[seq[string]]
    for sub in orderItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr(^gbl.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr @global.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr(@global.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr "^gbl".keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr("^gbl".keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

proc testOrderKeysReverse() =
  let refdata = @[@["5"], @["4"], @["3"], @["2"], @["1"]]

  block:
    var subs: seq[seq[string]]
    for sub in orderItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr(^gbl.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr @global.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr(@global.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr "^gbl".keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr("^gbl".keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in orderItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs


proc testOrderCount() =
  let refdata = 5

  block:
    for count in orderItr ^gbl.count:
      assert refdata == count

  block:
    for count in orderItr(^gbl.count):
      assert refdata == count

  block:
    for count in orderItr @global.count:
      assert refdata == count

  block:
    for count in orderItr(@global.count):
      assert refdata == count

  block:
    for count in orderItr "^gbl".count:
      assert refdata == count

  block:
    for count in orderItr("^gbl".count):
      assert refdata == count

  block:
    for count in orderItr ^gbl.count:
      assert refdata == count

proc testOrderCountReverse() =
  let refdata = 5

  block:
    for count in orderItr ^gbl.count.reverse:
      assert refdata == count

  block:
    for count in orderItr(^gbl.count.reverse):
      assert refdata == count

  block:
    for count in orderItr @global.count.reverse:
      assert refdata == count

  block:
    for count in orderItr(@global.count.reverse):
      assert refdata == count

  block:
    for count in orderItr "^gbl".count.reverse:
      assert refdata == count

  block:
    for count in orderItr("^gbl".count.reverse):
      assert refdata == count

  block:
    for count in orderItr ^gbl.count.reverse:
      assert refdata == count


if isMainModule:
  setup()
  test "query": testQuery()
  test "query reverse": testQueryReverse()
  test "query value": testQueryValue()
  test "query value reverse": testQueryValueReverse()  
  test "query kv": testQueryKv()
  test "query kv reverse": testQueryKvReverse()  
  test "query keys": testQueryKeys()
  test "query keys reverse": testQueryKeysReverse()
  test "query count": testQueryCount()
  test "query count reverse": testQueryCountReverse()  

  test "order": testOrder()
  test "order reverse": testOrderReverse()
  test "order value": testOrderValue()
  test "order value reverse": testOrderValueReverse()  
  test "order kv": testOrderKv()
  test "order kv reverse": testOrderKvReverse()  
  test "order keys": testOrderKeys()
  test "order keys reverse": testOrderKeysReverse()
  test "order count": testOrderCount()
  test "order count reverse": testOrderCountReverse()
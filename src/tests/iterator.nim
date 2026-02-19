import std/[unittest]
import yottadb

const global = "^gbl"

proc setup() =
    Kill: ^gbl
    for i in 1..5:
        Set: ^gbl(i) = i
        Set: local(i) = i
    Set:
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
    for sub in QueryItr ^gbl:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr local:
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in QueryItr ^gbl(2):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in QueryItr local(2):
      subs.add(sub)
    assert subs == reflocal2

  block:
    var subs: seq[string]
    for sub in QueryItr(^gbl):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(local):
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in QueryItr(^gbl(2)):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in QueryItr(local(2)):
      subs.add(sub)
    assert subs == reflocal2

  block:
    var subs: seq[string]
    for sub in QueryItr @global:
      subs.add(sub)
    assert subs == refdata

  # block: TODO: Implement indirection on locals?
  #   var subs: seq[string]
  #   for sub in QueryItr @local:
  #     subs.add(sub)
  #   assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in QueryItr @global(2):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in QueryItr(@global):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(@global(2)):
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in QueryItr "^gbl":
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr local:
      subs.add(sub)
    assert subs == reflocal

  block:
    var subs: seq[string]
    for sub in QueryItr "^gbl(2)":
      subs.add(sub)
    assert subs == refdata2

  block:
    var subs: seq[string]
    for sub in QueryItr("^gbl"):
      subs.add(sub)
    assert subs == refdata


proc testQueryReverse() =
  let refdata = @["^gbl(5)","^gbl(4)","^gbl(3)","^gbl(2,2)","^gbl(2)","^gbl(1,1)","^gbl(1)"]

  block:
    var subs: seq[string]
    for sub in QueryItr ^gbl.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(^gbl.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr @global.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(@global.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr "^gbl".reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr("^gbl".reverse):
      subs.add(sub)
    assert subs == refdata



proc testQueryValue() =
  let refdata = @["1", "1.1", "2", "2.2", "3", "4","5"]
  block:
    var subs: seq[string]
    for sub in QueryItr ^gbl.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(^gbl.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr @global.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(@global.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr "^gbl".val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr("^gbl".val):
      subs.add(sub)
    assert subs == refdata

proc testQueryValueReverse() =
  let refdata = @["5","4","3","2.2","2","1.1","1"]
  block:
    var subs: seq[string]
    for sub in QueryItr ^gbl.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(^gbl.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr @global.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr(@global.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr "^gbl".val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in QueryItr("^gbl".val.reverse):
      subs.add(sub)
    assert subs == refdata


proc testQueryKv() =
  let refdataKeys = @["^gbl(1)", "^gbl(1,1)", "^gbl(2)", "^gbl(2,2)", "^gbl(3)", "^gbl(4)", "^gbl(5)"]
  let refdataValues = @["1", "1.1", "2", "2.2", "3", "4","5"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr ^gbl.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr(^gbl.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr @global.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr(@global.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr "^gbl".kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr("^gbl".kv):
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
    for (key, value) in QueryItr ^gbl.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr(^gbl.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr @global.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr(@global.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr "^gbl".kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in QueryItr("^gbl".kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values


proc testQueryKeys() =
  let refdata = @[@["1"],@["1", "1"],@["2"],@["2", "2"],@["3"],@["4"],@["5"]  ]

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr(^gbl.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr @global.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr(@global.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr "^gbl".keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr("^gbl".keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

proc testQueryKeysReverse() =
  let refdata = @[@["5"],@["4"],@["3"],@["2", "2"],@["2"],@["1", "1"],@["1"]]

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr(^gbl.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr @global.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr(@global.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr "^gbl".keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr("^gbl".keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in QueryItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs


proc testQueryCount() =
  let refdata = 7

  block:
    for count in QueryItr ^gbl.count:
      assert refdata == count

  block:
    for count in QueryItr(^gbl.count):
      assert refdata == count

  block:
    for count in QueryItr @global.count:
      assert refdata == count

  block:
    for count in QueryItr(@global.count):
      assert refdata == count

  block:
    for count in QueryItr "^gbl".count:
      assert refdata == count

  block:
    for count in QueryItr("^gbl".count):
      assert refdata == count

  block:
    for count in QueryItr ^gbl.count:
      assert refdata == count


proc testQueryCountReverse() =
  let refdata = 7

  block:
    for count in QueryItr ^gbl.count.reverse:
      assert refdata == count

  block:
    for count in QueryItr(^gbl.count.reverse):
      assert refdata == count

  block:
    for count in QueryItr @global.count.reverse:
      assert refdata == count

  block:
    for count in QueryItr(@global.count.reverse):
      assert refdata == count

  block:
    for count in QueryItr "^gbl".count.reverse:
      assert refdata == count

  block:
    for count in QueryItr("^gbl".count.reverse):
      assert refdata == count

  block:
    for count in QueryItr ^gbl.count.reverse:
      assert refdata == count


# -----------------
# Order
# -----------------

proc testOrder() =
  let refdata = @["1", "2", "3", "4", "5"]

  block:
    var subs: seq[string]
    for sub in OrderItr ^gbl:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(^gbl):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr @global:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(@global):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr "^gbl":
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr("^gbl"):
      subs.add(sub)
    assert subs == refdata

proc testOrderReverse() =
  let refdata = @["5", "4", "3", "2", "1"]

  block:
    var subs: seq[string]
    for sub in OrderItr ^gbl.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(^gbl.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr @global.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(@global.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr "^gbl".reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr("^gbl".reverse):
      subs.add(sub)
    assert subs == refdata


proc testOrderValue() =
  let refdata = @["1", "2", "3", "4", "5"]
  block:
    var subs: seq[string]
    for sub in OrderItr ^gbl.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(^gbl.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr @global.val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(@global.val):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr "^gbl".val:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr("^gbl".val):
      subs.add(sub)
    assert subs == refdata

proc testOrderValueReverse() =
  let refdata = @["5", "4", "3", "2", "1"]
  block:
    var subs: seq[string]
    for sub in OrderItr ^gbl.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(^gbl.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr @global.val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr(@global.val.reverse):
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr "^gbl".val.reverse:
      subs.add(sub)
    assert subs == refdata

  block:
    var subs: seq[string]
    for sub in OrderItr("^gbl".val.reverse):
      subs.add(sub)
    assert subs == refdata


proc testOrderKv() =
  let refdataKeys = @["1", "2", "3", "4", "5"]
  let refdataValues = @["1", "2", "3", "4", "5"]

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr ^gbl.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr(^gbl.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr @global.kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr(@global.kv):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr "^gbl".kv:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr("^gbl".kv):
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
    for (key, value) in OrderItr ^gbl.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr(^gbl.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr @global.kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr(@global.kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr "^gbl".kv.reverse:
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values

  block:
    var keys: seq[string]
    var values: seq[string]
    for (key, value) in OrderItr("^gbl".kv.reverse):
      keys.add(key)
      values.add(value)
    assert refdataKeys == keys
    assert refdataValues == values


proc testOrderKeys() =
  let refdata = @[@["1"], @["2"], @["3"], @["4"], @["5"]]

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr(^gbl.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr @global.keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr(@global.keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr "^gbl".keys:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr("^gbl".keys):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr ^gbl.keys:
      subs.add(sub)
    assert refdata == subs

proc testOrderKeysReverse() =
  let refdata = @[@["5"], @["4"], @["3"], @["2"], @["1"]]

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr(^gbl.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr @global.keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr(@global.keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr "^gbl".keys.reverse:
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr("^gbl".keys.reverse):
      subs.add(sub)
    assert refdata == subs

  block:
    var subs: seq[seq[string]]
    for sub in OrderItr ^gbl.keys.reverse:
      subs.add(sub)
    assert refdata == subs


proc testOrderCount() =
  let refdata = 5

  block:
    for count in OrderItr ^gbl.count:
      assert refdata == count

  block:
    for count in OrderItr(^gbl.count):
      assert refdata == count

  block:
    for count in OrderItr @global.count:
      assert refdata == count

  block:
    for count in OrderItr(@global.count):
      assert refdata == count

  block:
    for count in OrderItr "^gbl".count:
      assert refdata == count

  block:
    for count in OrderItr("^gbl".count):
      assert refdata == count

  block:
    for count in OrderItr ^gbl.count:
      assert refdata == count

proc testOrderCountReverse() =
  let refdata = 5

  block:
    for count in OrderItr ^gbl.count.reverse:
      assert refdata == count

  block:
    for count in OrderItr(^gbl.count.reverse):
      assert refdata == count

  block:
    for count in OrderItr @global.count.reverse:
      assert refdata == count

  block:
    for count in OrderItr(@global.count.reverse):
      assert refdata == count

  block:
    for count in OrderItr "^gbl".count.reverse:
      assert refdata == count

  block:
    for count in OrderItr("^gbl".count.reverse):
      assert refdata == count

  block:
    for count in OrderItr ^gbl.count.reverse:
      assert refdata == count


if isMainModule:
  setup()
  test "Query": testQuery()
  test "Query reverse": testQueryReverse()
  test "Query value": testQueryValue()
  test "Query value reverse": testQueryValueReverse()  
  test "Query kv": testQueryKv()
  test "Query kv reverse": testQueryKvReverse()  
  test "Query keys": testQueryKeys()
  test "Query keys reverse": testQueryKeysReverse()
  test "Query count": testQueryCount()
  test "Query count reverse": testQueryCountReverse()  

  test "Order": testOrder()
  test "Order reverse": testOrderReverse()
  test "Order value": testOrderValue()
  test "Order value reverse": testOrderValueReverse()  
  test "Order kv": testOrderKv()
  test "Order kv reverse": testOrderKvReverse()  
  test "Order keys": testOrderKeys()
  test "Order keys reverse": testOrderKeysReverse()
  test "Order count": testOrderCount()
  test "Order count reverse": testOrderCountReverse()
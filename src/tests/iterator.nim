import std/[unittest]
import yottadb

let gbl = "^gbl"

proc setup() =
    kill: @gbl
    for i in 1..5:
        setvar: @gbl(i) = i
    setvar:
        @gbl(1,1)="1.1"
        @gbl(2,2)="2.2"


proc testKeys() =
  let refdata = @[@["1"],@["1", "1"],@["2"],@["2", "2"],@["3"],@["4"],@["5"]]
  var subs: seq[seq[string]]
  for sub in nextKeys("^gbl"):
    subs.add(sub)
  assert subs == refdata

proc testValues() =
  let refdata = @["1", "1.1", "2", "2.2", "3", "4","5"]
  var subs: seq[string]
  for sub in nextValues("^gbl"):
    subs.add(sub)
  assert subs == refdata

proc testPairs() =
  let refdata: seq[tuple[subs: Subscripts, value: string]] = @[
    (@["1"], "1"),
    (@["1", "1"], "1.1"),
    (@["2"], "2"),
    (@["2", "2"], "2.2"),
    (@["3"], "3"),
    (@["4"], "4"),
    (@["5"], "5")
    ]
  var dbdata: seq[tuple[subs: Subscripts, value: string]]

  for (subs, value) in nextPairs("^gbl"):
    dbdata.add( (subs, value) )
  assert dbdata == refdata


proc testSubscriptKeys() =
  let refdata = @[@["1"],@["2"],@["3"],@["4"],@["5"]]
  var subs: seq[seq[string]]
  for sub in nextSubscript("^gbl"):
    subs.add(sub)
  assert subs == refdata

proc testSubscriptValues() =
  let refdata = @[@["1"],@["2"],@["3"],@["4"],@["5"]]
  var subs: seq[seq[string]]
  for sub in nextSubscript("^gbl"):
    subs.add(sub)
  assert subs == refdata


proc testSubscriptPairs() =
  let refdata: seq[tuple[subs: Subscripts, value: string]] = @[
    (@["1"], "1"),
    (@["2"], "2"),
    (@["3"], "3"),
    (@["4"], "4"),
    (@["5"], "5")
    ]
  var dbdata: seq[tuple[subs: Subscripts, value: string]]
  for (subs, value) in nextSubscriptPairs("^gbl"):
    dbdata.add( (subs, value) )
  assert dbdata == refdata

if isMainModule:
  setup()
  test "keys": testKeys()
  test "values": testValues()
  test "pairs": testPairs()
  test "subscripts keys": testSubscriptKeys()
  test "subscripts values": testSubscriptValues()
  test "subscripts pairs": testSubscriptPairs()
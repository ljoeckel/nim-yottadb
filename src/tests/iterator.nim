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

setup()

test "keys": testKeys()
test "values": testValues()
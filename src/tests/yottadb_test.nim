import std/[strformat, strutils, unittest, times, os]
import ../yottadb

const
  MAX = 1000

proc setupLL() =
  let global = "^LL"
  ydb_set(global, @["HAUS"])
  ydb_set(global, @["HAUS", "ELEKTRIK"])
  ydb_set(global, @["HAUS", "ELEKTRIK", "DOSEN"])
  ydb_set(global, @["HAUS", "ELEKTRIK", "DOSEN", "1"], "Telefondose")
  ydb_set(global, @["HAUS", "ELEKTRIK", "DOSEN", "2"], "Steckdose")
  ydb_set(global, @["HAUS", "ELEKTRIK", "DOSEN", "3"], "IP-Dose")
  ydb_set(global, @["HAUS", "ELEKTRIK", "DOSEN", "4"], "KFZ-Dose")
  ydb_set(global, @["HAUS", "ELEKTRIK", "KABEL"])
  ydb_set(global, @["HAUS", "ELEKTRIK", "KABEL", "FARBEN"])
  ydb_set(global, @["HAUS", "ELEKTRIK", "KABEL", "STAERKEN"])
  ydb_set(global, @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
  ydb_set(global, @["HAUS", "FLAECHEN", "RAUM1"])
  ydb_set(global, @["HAUS", "FLAECHEN", "RAUM2"])
  ydb_set(global, @["HAUS", "FLAECHEN", "RAUM2"])
  ydb_set(global, @["HAUS", "HEIZUNG"])
  ydb_set(global, @["HAUS", "HEIZUNG", "MESSGERAETE"])
  ydb_set(global, @["HAUS", "HEIZUNG", "ROHRE"])
  ydb_set(global, @["LAND"])
  ydb_set(global, @["LAND", "FLAECHEN"])
  ydb_set(global, @["LAND", "NUTZUNG"])
  ydb_set(global, @["ORT"])


# ------------- Test cases are here ---------------------
# Write ^X(0..1000000) in 800ms. 
proc simpleSet(global: string, cnt: int) =
  var subs:seq[string]
  for i in 0..cnt:
    subs.add($i)
    ydb_set(global, subs, $i)
    discard subs.pop()

# Read ^X(0..100000000) in 600ms. 
proc simpleGet(global: string, cnt: int) =
  var subs:seq[string]
  for i in 0..cnt:
    subs.add($i)
    assert $i == ydb_get(global, subs)
    discard subs.pop()

# Delete ^X(0..100000000) in 550ms. 
proc simpleDelete(global: string, cnt: int) =
  var subs:seq[string]
  for i in 0..cnt:
    subs.add($i)
    ydb_delete_node(global, subs)
    discard subs.pop()

proc setWithError() =
  # set with empty global
  doAssertRaises(YdbError): ydb_set("", @["x"], "x") # -151027762, %YDB-E-INVVARNAME
  
  # Write global without subscript -> ^x="x"
  ydb_set("^x", @[], "x")
  assert "x" == ydb_get("^x", @[])

  # Write global without value
  ydb_set("^x", @["x"])
  assert "" == ydb_get("^x", @["x"])



proc testYdbVar() =
  for i in 0..MAX:
    discard newYdbVar("^LJ", @["LAND", "ORT", $i], $i)

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    assert v.value == $i
    # update db with new value
    v[] = "New " & v.value

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    assert v.value == "New " & $i

proc testYdbSetGet() =
  for i in 0..MAX:
    let value = fmt"Hello Lothar Jöckel {i} aus der Schweiz"
    ydb_set("^LJ", @["LAND", "ORT", $i], value)
    assert value == ydb_get("^LJ", @["LAND", "ORT", $i])
    ydb_set("^LJ", @["LAND", "ORT", $i, $i], value)
    assert value == ydb_get("^LJ", @["LAND", "ORT", $i, $i])

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Gartenweg 4")


proc testData() =
  assert 0 == ydb_data("^LJ", @["XXX"])  # There is neither a value nor a subtree, i.e., it is undefined.
  assert 10 == ydb_data("^LJ", @["LAND"])  # There is no value, but there is a subtree.
  assert 11 == ydb_data("^LJ", @["LAND", "ORT", "1"])  # There are both a value and a subtree.
  assert 1 == ydb_data("^LJ", @["LAND", "STRASSE"])  # There is a value, but no subtree


proc testNextNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  for subs in ydb_node_next_iter(global, start):
    inc(cnt)
  doAssert cnt == MAX * 2 + 3


proc testPreviousNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  for subs in ydb_node_previous_iter(global, start):
    inc(cnt)
  doAssert cnt == MAX * 2 + 2

proc testNextNodeIterator(global: string, start: Subscripts = @[]) =
  deleteGlobal("^X")

  setvar:
    ^X(@["5", "1"])=1
    ^X(@["5", "2"])=2
    ^X(@["7", "3"])=3
    ^X(@["123", "1"])=4
    ^X(@["123", "2"])=5
    ^X(@["123", "3"])=6
    ^X(@["123", "123"])=7
    ^X(@["4711", "i"])=8
    ^X(@["123", "f"])=9
    ^X(@["123", "123", "4711", "i"])=10
    ^X(@["123", "i", "4711"])=11
    ^X(@["123", "s"])=12

  let refdata = @[
    @["5", "1"], @["5", "2"], @["7", "3"], @["123", "1"], @["123", "2"], @["123", "3"], 
    @["123", "123"], @["123", "123", "4711", "i"], @["123", "f"], @["123", "i", "4711"], @["123", "s"], @["4711", "i"]
  ]
  var dbdata: seq[Subscripts]
  for subs in ydb_node_next_iter(global, start):
    dbdata.add(subs)
  assert dbdata == refdata

proc testPreviousNodeIterator(global: string, start: Subscripts = @[]) =
  let refdata = @[
    @["4711", "i"], @["123", "s"], @["123", "i", "4711"], @["123", "f"], @["123", "123", "4711", "i"], @["123", "123"], @["123", "3"],
    @["123", "2"], @["123", "1"], @["7", "3"], @["5", "2"], @["5", "1"]
  ]
  var dbdata: seq[Subscripts]
  for subs in ydb_node_previous_iter(global, start):
    dbdata.add(subs)
  assert dbdata == refdata

proc nextSubscript(global: string, start: Subscripts, expected: Subscripts) =
  var (rc, subscript) = ydb_subscript_next(global, start)
  doAssert rc == YDB_OK and subscript == expected

proc ydb_subscript_next_iterate(global: string, start: Subscripts, expected: Subscripts) =
  var last_subscript: Subscripts
  var (rc, subscript) = ydb_subscript_next(global, start)
  while rc == YDB_OK:
    last_subscript = subscript
    (rc, subscript) = ydb_subscript_next(global, subscript)
  doAssert last_subscript == expected

proc previousSubscript(global: string, start: Subscripts, expected: Subscripts) =
  var lastSubscript: Subscripts
  var (rc, subscript) = ydb_subscript_previous(global, start)
  while rc == YDB_OK:
    lastSubscript = subscript
    (rc, subscript) = ydb_subscript_previous(global, subscript)
  doAssert lastSubscript == expected

proc nextSubsIter(global: string, start: Subscripts, expected: Subscripts) =
  var lastSubs: Subscripts
  for subs in ydb_subscript_next_iter(global, start):
    lastSubs = subs
  doAssert lastSubs == expected
  let refdata = @[@["HAUS", "ELEKTRIK"], @["HAUS", "FLAECHEN"],@["HAUS", "HEIZUNG"]]
  var dbdata: seq[Subscripts]
  for subs in ydb_subscript_next_iter(global, start):
    dbdata.add(subs)
  assert dbdata == refdata

proc previousSubsIter(global: string, start: Subscripts, expected: Subscripts) =
  var lastSubs: Subscripts
  for subs in ydb_subscript_previous_iter(global, start):
    lastSubs = subs
  doAssert lastSubs == expected

  let refdata = @[@["HAUS", "HEIZUNG"], @["HAUS", "FLAECHEN"],@["HAUS", "ELEKTRIK"]]
  var dbdata: seq[Subscripts]
  for subs in ydb_subscript_previous_iter(global, start):
    dbdata.add(subs)
  assert dbdata == refdata

proc deleteTree() =
  ydb_delete_node("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    ydb_delete_tree("^LJ", @["LAND", "ORT", $i, $i])

# Delete all globals from ^LJ, ^LJ will be removed from %GD
proc testDeleteTree() =
  ydb_delete_tree("^LJ", @["LAND"])
  let globals = getGlobals()
  assert globals.find("^LJ") == -1

proc deleteNode() =
    ydb_delete_node("^CNT", @["CHANNEL", "INPUT"])
    var result = ydb_increment("^CNT", @["CHANNEL", "INPUT"], 1)
    assert ydb_get("^CNT", @["CHANNEL", "INPUT"]) == $result



proc testSpecialVariables() =
  let vars = ["$DEVICE", "$ECODE","$ESTACK", "$ETRAP", "$HOROLOG",
              "$IO", "$JOB", "$KEY", "$PRINCIPAL", "$QUIT", "$REFERENCE", "$STACK", "$STORAGE",
              "$SYSTEM", "$TLEVEL", "$TRESTART", "$X", "$Y", "$ZA", "$ZALLOCSTOR", "$ZAUDIT",
              "$ZB", "$ZCHSET", "$ZCLOSE", "$ZCMDLINE", "$ZCOMPILE", "$ZCSTATUS", "$ZDATEFORM",
              "$ZDIRECTORY", "$ZEDITOR", "$ZEOF", "$ZERROR", "$ZGBLDIR", "$ZHOROLOG", 
              "$ZININTERRUPT", "$ZINTERRUPT", "$ZIO", "$ZJOB", "$ZKEY", "$ZLEVEL", "$ZMALLOCLIM",
              "$ZMAXTPTIME", "$ZMODE", "$ZONLNRLBK", "$ZPATNUMERIC", "$ZPIN", "$ZPOSITION",
              "$ZPOUT", "$ZPROMPT", "$ZQUIT", "$ZREALSTOR", "$ZRELDATE", "$ZROUTINES", "$ZSOURCE", 
              "$ZSTATUS", "$ZSTEP", "$ZSTRPLLIM", "$ZSYSTEM", "$ZTEXIT", "$ZTIMEOUT", "$ZTRAP",
              "$ZUSEDSTOR", "$ZUT", "$ZVERSION", "$ZYERROR", "$ZYINTRSIG", "$ZYRELEASE", 
              "$ZYSQLNULL"]
  for variable in vars:
    discard ydb_get(variable)


proc testSetAndGetVariable() =
  ydb_set("X", @[], "hello")
  ydb_set("X", @["1"], "hello X(1)")
  ydb_set("X", @["1","1"], "hello X(1,1)")
  ydb_set("X", @["1","2"], "hello X(1,2)")
  ydb_set("X", @["1","3"], "hello X(1,3)")
  ydb_set("X", @["2"], "hello X(2)")
  ydb_set("X", @["2","3"], "hello X(2,3)")

  doAssert ydb_get("X") == "hello"
  doAssert ydb_get("X", @["1"]) == "hello X(1)"
  doAssert ydb_get("X", @["1","1"]) == "hello X(1,1)"


proc testLock() =
  let globals :seq[seq[string]]= @[
        @["^LL","HAUS", "1"], @["^LL","HAUS", "2"], @["^LL","HAUS", "3"],
        @["^LL","HAUS", "4"], @["^LL","HAUS", "5"], @["^LL","HAUS", "6"], 
        @["^LL","HAUS", "7"], @["^LL","HAUS", "8"], @["^LL","HAUS", "9"], @["^LL","HAUS", "10"],
        @["^LL","HAUS", "11"], @["^LL","HAUS", "12"], @["^LL","HAUS", "13"],
        @["^LL","HAUS", "14"], @["^LL","HAUS", "15"], @["^LL","HAUS", "16"],
        @["^LL","HAUS", "17"], @["^LL","HAUS", "18"], @["^LL","HAUS", "19"], @["^LL","HAUS", "20"],
        @["^LL","HAUS", "21"], @["^LL","HAUS", "22"], @["^LL","HAUS", "23"],
        @["^LL","HAUS", "24"], @["^LL","HAUS", "25"], @["^LL","HAUS", "26"],
        @["^LL","HAUS", "27"], @["^LL","HAUS", "28"], @["^LL","HAUS", "29"], @["^LL","HAUS", "30"],
        @["^LL","HAUS", "31"], @["^LL","HAUS", "32"], @["^LL","HAUS", "33"], @["^LL","HAUS", "34"], 
        @["^LL","HAUS", "35"]
        ]

  var toLock:seq[seq[string]]
  for global in  globals:
    toLock.add(global)
    ydb_lock(100000, toLock)
    assert getLockCountFromYottaDb() == toLock.len

  ydb_lock(100000, @[])
  assert getLockCountFromYottaDb() == 0

  # Too many locks
  toLock.add(@["^LL","HAUS", "36"])
  doAssertRaises(YdbError): ydb_lock(100000, toLock)


proc testLockIncrement() =
  ydb_lock_incr(100000, "^LL", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_incr(100000, "^LL", @["HAUS", "32"])
  assert getLockCountFromYottaDb() == 2
  ydb_lock_incr(100000, "^LL", @["HAUS", "33"])
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  ydb_lock_decr("^LL", @["HAUS", "33"])
  assert getLockCountFromYottaDb() == 2
  ydb_lock_decr("^LL", @["HAUS", "32"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr("^LL", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing lock (Should be ignored)
  ydb_lock_decr("^LL", @["HAUS", "99"])
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing global (Lock will be created)
  ydb_lock_incr(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1

  # Increment / Decrement same lock multiple times
  ydb_lock_incr(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_incr(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 0


proc testIncrement() =
  let MAX = 1000 
  var cnt:int 
  ydb_set("^COUNTERS", @["upcount"], "0")
  for i in 0..<MAX:
    cnt = ydb_increment("^COUNTERS", @["upcount"])
  assert cnt == MAX
  assert ydb_get("^COUNTERS", @["upcount"]) == $MAX

proc testMaxSubscripts() =
  for i in 0..<33:
    var keys:seq[string] = @[]
    for j in 0..<i:
      keys.add($j)

    if i < 32:
      ydb_set("^SUBS", keys, $i)
      assert $i == ydbget("^SUBS", keys)
    else:
      doAssertRaises(YdbError): ydb_set("^SUBS", keys, $i)


proc testDeleteExcl() =
  ydb_set("DELTEST1", @["A"], "1")
  ydb_set("DELTEST2", @["A"], "1")
  ydb_set("DELTEST3", @["A"], "1")
  ydb_set("DELTEST4", @["A"], "1")
  ydb_set("DELTEST5", @["A"], "1")

  doAssert ydb_get("DELTEST1", @["A"]) == "1"
  doAssert ydb_get("DELTEST2", @["A"]) == "1"
  doAssert ydb_get("DELTEST3", @["A"]) == "1"
  doAssert ydb_get("DELTEST4", @["A"]) == "1"
  doAssert ydb_get("DELTEST5", @["A"]) == "1"

  ydb_delete_excl(@["DELTEST1","DELTEST3","DELTEST5"])

  # Global's are not allowed
  doAssertRaises(YdbError): ydb_delete_excl(@["^DELTEST"])

  doAssert ydb_get("DELTEST1", @["A"]) == "1"
  doAssert ydb_get("DELTEST3", @["A"]) == "1"
  doAssert ydb_get("DELTEST5", @["A"]) == "1"
  doAssertRaises(YdbError): discard ydb_get("DELTEST2", @["A"])
  doAssertRaises(YdbError): discard ydb_get("DELTEST4", @["A"])

  # delete all variables
  ydb_delete_excl()
  doAssertRaises(YdbError): discard ydb_get("DELTEST1", @["A"])


proc test_ydb_ci() =
  let ydb_ci = getEnv("ydb_ci")
  if ydb_ci.isEmptyOrWhitespace:
    echo "Could not find environment variable 'ydb_ci' to set the callin table. *** Test ignored ***"
    return
  if not fileExists(ydb_ci):
    echo "Could not find callin file ", ydb_ci, " *** Test ignored ***"
    return

  let tm = getTime()
  setvar: VAR1=tm                      # set a YottaDB variable
  ydb_ci("method1")
  let result = get: RESULT  # Read the YottaDB variable from the Callin
  assert $tm == result

# -------------------------------------------------------------------

setupLL()

proc test() =
  suite "YottaDB Tests":
    test "Basic functionality":
      test "simpleSet": simpleSet("^X", MAX)
      test "simpleGet": simpleGet("^X", MAX)
      test "simpleDelete": simpleDelete("^X", MAX)
      test "testYdbVar": testYdbVar()
      test "testWithError": setWithError()
    test "Write and Read Data":
      test "testYdbSetGet": testYdbSetGet()
    test "Check Data Structure":
      test "testData": testData()
    test "next/previous Node":
      test "testNextNode ^LJ": testNextNode("^LJ")
      test "testNextNodeIterator ^X": testNextNodeIterator("^X")
      test "testPreviousNodeIterator ^X": testPreviousNodeIterator("^X", @["99999"])
      test "testPreviousNode": testPreviousNode("^LJ", @["LAND", "STRASSE"])
    test "nextSubscript":
      test "nextSubscript1": nextSubscript("^LL", @["HAUS", "ELE..."], @["HAUS", "ELEKTRIK"])
      test "nextSubscript2": nextSubscript("^LL", @["HAUS", "ELEKTRIK"], @["HAUS", "FLAECHEN"])
      test "nextSubscript3": nextSubscript("^LL", @["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "DOSEN"])
      test "nextSubscript4": nextSubscript("^LL", @["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "1"])
    test "ydb_subscript_next_iterate":
      test "nextSubscript1": ydb_subscript_next_iterate("^LL", @["HAUS"], @["ORT"])
      test "nextSubscript2": ydb_subscript_next_iterate("^LL", @["HAUS", "ELE..."], @["HAUS", "HEIZUNG"])
      test "nextSubscript3": ydb_subscript_next_iterate("^LL", @["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
      test "nextSubscript4": ydb_subscript_next_iterate("^LL", @["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "4"])
    test "previousSubscript":
      test "previousSubscript1":previousSubscript("^LL", @["HAUS", "ELEKTRIK", "SICHERUN..."], @["HAUS", "ELEKTRIK", "DOSEN"] )
      test "previousSubscript2":previousSubscript("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "99999"], @["HAUS", "ELEKTRIK", "DOSEN", "1"] )
      test "previousSubscript3":previousSubscript("^LL", @["HAUS"], @[] )
    test "ydb_subscript_previous_iter4":
      test "ydb_subscript_next_iter":nextSubsIter("^LL", @["HAUS", "ELEKT..."], @["HAUS", "HEIZUNG"])
      test "ydb_subscript_previous_iter":previousSubsIter("^LL", @["HAUS", "ZZZZ"], @["HAUS", "ELEKTRIK"])
    test "Delete Operations":
      test "deleteTree": deleteTree()
      test "deleteNode": deleteNode()
      test "deleteGlobalVar": testDeleteTree()
      test "testLocalVarExcl": testDeleteExcl()
    test "Misc":
      test "testSpecialVariables": testSpecialVariables()
      test "increment": testIncrement()
      test "maxSubscripts": testMaxSubscripts()
      test "Call-In Interface": test_ydb_ci()
    test "Set and Get Variable":
      test "testSetAndGetVariable": testSetAndGetVariable()
    test "Lock Handling":
      test "testLock": testLock()
      test "testLockIncrement": testLockIncrement()


when isMainModule:
  test() # threads:off=31s, threads:on=33s
  #test "Call-In Interface": test_ydb_ci()

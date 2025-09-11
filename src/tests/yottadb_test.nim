import std/[strformat, strutils, unittest]
import ../yottadb

const
  MAX = 1000

proc setupLL() =
  let global = "^LL"
  ydbSet(global, @["HAUS"])
  ydbSet(global, @["HAUS", "ELEKTRIK"])
  ydbSet(global, @["HAUS", "ELEKTRIK", "DOSEN"])
  ydbSet(global, @["HAUS", "ELEKTRIK", "DOSEN", "1"], "Telefondose")
  ydbSet(global, @["HAUS", "ELEKTRIK", "DOSEN", "2"], "Steckdose")
  ydbSet(global, @["HAUS", "ELEKTRIK", "DOSEN", "3"], "IP-Dose")
  ydbSet(global, @["HAUS", "ELEKTRIK", "DOSEN", "4"], "KFZ-Dose")
  ydbSet(global, @["HAUS", "ELEKTRIK", "KABEL"])
  ydbSet(global, @["HAUS", "ELEKTRIK", "KABEL", "FARBEN"])
  ydbSet(global, @["HAUS", "ELEKTRIK", "KABEL", "STAERKEN"])
  ydbSet(global, @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
  ydbSet(global, @["HAUS", "FLAECHEN", "RAUM1"])
  ydbSet(global, @["HAUS", "FLAECHEN", "RAUM2"])
  ydbSet(global, @["HAUS", "FLAECHEN", "RAUM2"])
  ydbSet(global, @["HAUS", "HEIZUNG"])
  ydbSet(global, @["HAUS", "HEIZUNG", "MESSGERAETE"])
  ydbSet(global, @["HAUS", "HEIZUNG", "ROHRE"])
  ydbSet(global, @["LAND"])
  ydbSet(global, @["LAND", "FLAECHEN"])
  ydbSet(global, @["LAND", "NUTZUNG"])
  ydbSet(global, @["ORT"])


# ------------- Test cases are here ---------------------
# Write ^X(0..1000000) in 800ms. 
proc simpleSet(global: string, cnt: int) =
  var subs:seq[string] = @[]
  for i in 0..cnt:
    subs.add($i)
    ydbSet(global, subs, $i)
    discard subs.pop()

# Read ^X(0..100000000) in 600ms. 
proc simpleGet(global: string, cnt: int) =
  var subs:seq[string] = @[]
  for i in 0..cnt:
    subs.add($i)
    assert $i == ydbGet(global, subs)
    discard subs.pop()

# Delete ^X(0..100000000) in 550ms. 
proc simpleDelete(global: string, cnt: int) =
  var subs:seq[string] = @[]
  for i in 0..cnt:
    subs.add($i)
    ydbDeleteNode(global, subs)
    discard subs.pop()

proc testYdbVar() =
  for i in 0..MAX:
    discard newYdbVar("^LJ", @["LAND", "ORT", $i], $i)

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    if v.value != $i: 
      raise newException(YdbDbError, "Invalid data in db for {i}")
    # update db with new value
    v[] = "New " & v.value

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    if v.value != "New " & $i: 
      raise newException(YdbDbError, "Invalid data in db for {i}")

# Test the maximum record length of 1MB
proc testMaxValueSize() =
  for i in 1..1024:
    let value = "0".repeat(i*1024)
    ydbSet("^VARSIZE", @[$i], value)
    assert value == ydbGet("^VARSIZE", @[$i])

  # Illegal size > 1MB
  let i = 1024
  let value = "0".repeat(i*1024+1)
  doAssertRaises(YdbDbError): ydbSet("^VARSIZE", @[$i], value)

  var subs = @[""]
  for subs in nextNodeIter("^VARSIZE", subs):
    ydbDeleteNode("^VARSIZE", subs)


proc testYdbSetGet() =
  for i in 0..MAX:
    let value = fmt"Hello Lothar Jöckel {i} aus der Schweiz"
    ydbSet("^LJ", @["LAND", "ORT", $i], value)
    assert value == ydbGet("^LJ", @["LAND", "ORT", $i])
    ydbSet("^LJ", @["LAND", "ORT", $i, $i], value)
    assert value == ydbGet("^LJ", @["LAND", "ORT", $i, $i])

  ydbSet("^LJ", @["LAND", "STRASSE"], fmt"Gartenweg 4")


proc testData() =
  assert 0 == ydbData("^LJ", @["XXX"])  # There is neither a value nor a subtree, i.e., it is undefined.
  assert 10 == ydbData("^LJ", @["LAND"])  # There is no value, but there is a subtree.
  assert 11 == ydbData("^LJ", @["LAND", "ORT", "1"])  # There are both a value and a subtree.
  assert 1 == ydbData("^LJ", @["LAND", "STRASSE"])  # There is a value, but no subtree


proc testNextNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var subs = start
  for subs in nextNodeIter(global, subs):
    inc(cnt)
  doAssert cnt == MAX * 2 + 3


proc testPreviousNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var subs = start
  for subs in previousNodeIter(global, subs):
    inc(cnt)
  doAssert cnt == MAX * 2 + 2


proc nextSubscript(global: string, start: Subscripts, expected: Subscripts) =
  var subscript = start
  var rc = YDB_OK
  (rc, subscript) = ydb_subscript_next(global, subscript)
  doAssert rc == YDB_OK and subscript == expected

proc nextSubscriptIterate(global: string, start: Subscripts, expected: Subscripts) =
  var rc = YDB_OK
  var subscript = start
  var last_subscript: Subscripts
  while rc == YDB_OK:
    last_subscript = subscript
    (rc, subscript) = ydb_subscript_next(global, subscript)
  doAssert last_subscript == expected

proc previousSubscript(global: string, start: Subscripts, expected: Subscripts) =
  var subscript = start
  var lastSubscript: Subscripts
  var rc = YDB_OK
  while rc == YDB_OK:
    (rc, subscript) = ydb_subscript_previous(global, subscript)
    if rc != YDB_OK: break
    lastSubscript = subscript
  doAssert lastSubscript == expected

proc nextSubsIter(global: string, start: Subscripts, expected: Subscripts) =
  var subs = start
  var lastSubs: Subscripts
  for subs in nextSubscriptIter(global, subs):
    lastSubs = subs
  doAssert lastSubs == expected

proc previousSubsIter(global: string, start: Subscripts, expected: Subscripts) =
  var subs = start
  var lastSubs: Subscripts
  for subs in previousSubscriptIter(global, subs):
    lastSubs = subs
  doAssert lastSubs == expected


proc deleteTree() =
  ydbDeleteNode("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    ydbDeleteTree("^LJ", @["LAND", "ORT", $i, $i])

# Delete all globals from ^LJ, ^LJ will be removed from %GD
proc testDeleteTree() =
  ydbDeleteTree("^LJ", @["LAND"])
  let globals = getGlobals()
  assert globals.find("^LJ") == -1

proc deleteNode() =
    ydbDeleteNode("^CNT", @["CHANNEL", "INPUT"])
    var result = ydbIncrement("^CNT", @["CHANNEL", "INPUT"], 1)
    assert ydbGet("^CNT", @["CHANNEL", "INPUT"]) == $result



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
    discard ydbGet(variable)


proc testSetAndGetVariable() =
  ydbSet("X", @[], "hello")
  ydbSet("X", @["1"], "hello X(1)")
  ydbSet("X", @["1","1"], "hello X(1,1)")
  ydbSet("X", @["1","2"], "hello X(1,2)")
  ydbSet("X", @["1","3"], "hello X(1,3)")
  ydbSet("X", @["2"], "hello X(2)")
  ydbSet("X", @["2","3"], "hello X(2,3)")

  doAssert ydbGet("X") == "hello"
  doAssert ydbGet("X", @["1"]) == "hello X(1)"
  doAssert ydbGet("X", @["1","1"]) == "hello X(1,1)"


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
    ydbLock(100000, toLock)
    assert getLockCountFromYottaDb() == toLock.len

  ydbLock(100000, @[])
  assert getLockCountFromYottaDb() == 0

  # Too many locks
  toLock.add(@["^LL","HAUS", "36"])
  doAssertRaises(YdbDbError): ydbLock(100000, toLock)


proc testLockIncrement() =
  var rc:int
  rc = ydbLockIncrement(100000, "^LL", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockIncrement(100000, "^LL", @["HAUS", "32"])
  assert getLockCountFromYottaDb() == 2
  rc = ydbLockIncrement(100000, "^LL", @["HAUS", "33"])
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  rc = ydbLockDecrement("^LL", @["HAUS", "33"])
  assert getLockCountFromYottaDb() == 2
  rc = ydbLockDecrement("^LL", @["HAUS", "32"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockDecrement("^LL", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing lock (Should be ignored)
  rc = ydbLockDecrement("^LL", @["HAUS", "99"])
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing global (Lock will be created)
  rc = ydbLockIncrement(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1

  # Increment / Decrement same lock multiple times
  rc = ydbLockIncrement(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockIncrement(100000, "^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockDecrement("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockDecrement("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 1
  rc = ydbLockDecrement("^ZZZZ", @["HAUS", "31"])
  assert getLockCountFromYottaDb() == 0


proc testIncrement() =
  let MAX = 1000 
  var cnt:int 
  ydbSet("^COUNTERS", @["upcount"], "0")
  for i in 0..<MAX:
    cnt = ydbIncrement("^COUNTERS", @["upcount"])
  assert cnt == MAX
  assert ydbGet("^COUNTERS", @["upcount"]) == $MAX

proc testMaxSubscripts() =
  for i in 0..<33:
    var keys:seq[string] = @[]
    for j in 0..<i:
      keys.add($j)

    if i < 32:
      ydbSet("^SUBS", keys, $i)
      assert $i == ydbget("^SUBS", keys)
    else:
      doAssertRaises(YdbDbError): ydbSet("^SUBS", keys, $i)


proc testDeleteExcl() =
  ydbSet("DELTEST1", @["A"], "1")
  ydbSet("DELTEST2", @["A"], "1")
  ydbSet("DELTEST3", @["A"], "1")
  ydbSet("DELTEST4", @["A"], "1")
  ydbSet("DELTEST5", @["A"], "1")

  doAssert ydbGet("DELTEST1", @["A"]) == "1"
  doAssert ydbGet("DELTEST2", @["A"]) == "1"
  doAssert ydbGet("DELTEST3", @["A"]) == "1"
  doAssert ydbGet("DELTEST4", @["A"]) == "1"
  doAssert ydbGet("DELTEST5", @["A"]) == "1"

  ydbDeleteExcl(@["DELTEST1","DELTEST3","DELTEST5"])

  # Global's are not allowed
  doAssertRaises(YdbDbError): ydbDeleteExcl(@["^DELTEST"])

  doAssert ydbGet("DELTEST1", @["A"]) == "1"
  doAssert ydbGet("DELTEST3", @["A"]) == "1"
  doAssert ydbGet("DELTEST5", @["A"]) == "1"
  doAssertRaises(YdbDbError): discard ydbGet("DELTEST2", @["A"])
  doAssertRaises(YdbDbError): discard ydbGet("DELTEST4", @["A"])

  # delete all variables
  ydbDeleteExcl()
  doAssertRaises(YdbDbError): discard ydbGet("DELTEST1", @["A"])


# -------------------------------------------------------------------

setupLL()

proc test() =
  suite "YottaDB Tests":
    test "Basic functionality":
      test "simpleSet": simpleSet("^X", MAX)
      test "simpleGet": simpleGet("^X", MAX)
      test "simpleDelete": simpleDelete("^X", MAX)
      test "testYdbVar": testYdbVar()
    test "Write and Read Data":
      test "testYdbSetGet": testYdbSetGet()
      test "testMaxValueSize": testMaxValueSize()
    test "Check Data Structure":
      test "testData": testData()
    test "next/previous Node":
      test "testNextNode ^LJ": testNextNode("^LJ")
      test "testPreviousNode": testPreviousNode("^LJ", @["LAND", "STRASSE"])
    test "nextSubscript":
      test "nextSubscript1": nextSubscript("^LL", @["HAUS", "ELE..."], @["HAUS", "ELEKTRIK"])
      test "nextSubscript2": nextSubscript("^LL", @["HAUS", "ELEKTRIK"], @["HAUS", "FLAECHEN"])
      test "nextSubscript3": nextSubscript("^LL", @["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "DOSEN"])
      test "nextSubscript4": nextSubscript("^LL", @["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "1"])
    test "nextSubscriptIterate":
      test "nextSubscript1": nextSubscriptIterate("^LL", @["HAUS"], @["ORT"])
      test "nextSubscript2": nextSubscriptIterate("^LL", @["HAUS", "ELE..."], @["HAUS", "HEIZUNG"])
      test "nextSubscript3": nextSubscriptIterate("^LL", @["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
      test "nextSubscript4": nextSubscriptIterate("^LL", @["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "4"])
    test "previousSubscript":
      test "previousSubscript1":previousSubscript("^LL", @["HAUS", "ELEKTRIK", "SICHERUN..."], @["HAUS", "ELEKTRIK", "DOSEN"] )
      test "previousSubscript2":previousSubscript("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "99999"], @["HAUS", "ELEKTRIK", "DOSEN", "1"] )
      test "previousSubscript3":previousSubscript("^LL", @["HAUS"], @[] )
    test "previousSubscriptIter4":
      test "nextSubscriptIter":nextSubsIter("^LL", @["HAUS", "ELEKT..."], @["HAUS", "HEIZUNG"])
      test "previousSubscriptIter":previousSubsIter("^LL", @["HAUS", "HEIZUNG"], @["HAUS", "ELEKTRIK"])
    test "Delete Operations":
      test "deleteTree": deleteTree()
      test "deleteNode": deleteNode()
      test "deleteGlobalVar": testDeleteTree()
      test "testLocalVarExcl": testDeleteExcl()
    test "Misc":
      test "testSpecialVariables": testSpecialVariables()
      test "increment": testIncrement()
      test "maxSubscripts": testMaxSubscripts()
    test "Set and Get Variable":
      test "testSetAndGetVariable": testSetAndGetVariable()
    test "Lock Handling":
      test "testLock": testLock()
      test "testLockIncrement": testLockIncrement()


when isMainModule:
  test() # threads:off=31s, threads:on=33s
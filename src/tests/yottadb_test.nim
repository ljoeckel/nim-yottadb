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
    assert YDB_OK == ydbDeleteNode(global, subs)
    discard subs.pop()

proc testYdbVar() =
  for i in 0..MAX:
    discard newYdbVar("^LJ", @["LAND", "ORT", $i], $i)

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    if v.value != $i: 
      raise newException(YottaDbError, "Invalid data in db for {i}")
    # update db with new value
    v[] = "New " & v.value

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    if v.value != "New " & $i: 
      raise newException(YottaDbError, "Invalid data in db for {i}")

# Test the maximum record length of 1MB
proc testMaxValueSize() =
  for i in 1..1024:
    let value = "0".repeat(i*1024)
    ydbSet("^VARSIZE", @[$i], value)
    assert value == ydbGet("^VARSIZE", @[$i])

  # Illegal size > 1MB
  let i = 1024
  let value = "0".repeat(i*1024+1)
  doAssertRaises(YottaDbError): ydbSet("^VARSIZE", @[$i], value)

  var subs = @[""]
  for subs in nextNodeIter("^VARSIZE", subs):
    assert YDB_OK == ydbDeleteNode("^VARSIZE", subs)


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

  doAssertRaises(YottaDbError): discard ydbData("^LJ", @[""])


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
  var rc = 0
  var lastSubscript: Subscripts
  while(rc == YDB_OK):
    rc = ydb_subscript_next(global, subscript)
    if rc == YDB_OK:
      lastSubscript = subscript
  doAssert lastSubscript == expected

proc previousSubscript(global: string, start: Subscripts, expected: Subscripts) =
  var subscript = start
  var lastSubscript: Subscripts
  var rc = 0
  while(rc == YDB_OK):
    rc = ydb_subscript_previous(global, subscript)
    if rc == YDB_OK:
      lastSubscript = subscript
  doAssert lastSubscript == expected

proc nextSubscriptIter(global: string, start: Subscripts, expected: Subscripts) =
  var subs = start
  var lastSubs: Subscripts
  for subs in nextSubscriptNode(global, subs):
    lastSubs = subs
  doAssert lastSubs == expected

proc previousSubscriptIter(global: string, start: Subscripts, expected: Subscripts) =
  var subs = start
  var lastSubs: Subscripts
  for subs in previousSubscriptNode(global, subs):
    lastSubs = subs
  doAssert lastSubs == expected


proc deleteTree() =
  var rc = ydbDeleteNode("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    rc = ydbDeleteTree("^LJ", @["LAND", "ORT", $i, $i])

# Delete all globals from ^LJ, ^LJ will be removed from %GD
proc testDeleteTree() =
  assert YDB_OK == ydbDeleteTree("^LJ", @["LAND"])
  let globals = getGlobals()
  assert globals.find("^LJ") == -1

proc deleteNode() =
    var rc = ydbDeleteNode("^CNT", @["CHANNEL", "INPUT"])
    var result = ydbIncrement("^CNT", @["CHANNEL", "INPUT"], 1)
    let value = ydbGet("^CNT", @["CHANNEL", "INPUT"]) == "1"



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
  
  # Test for unknown special variable
  doAssertRaises(YottaDbError): discard ydbGet("$XXXX")


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
        
  var toLock:seq[seq[string]] = @[@[]]
  for global in  globals:
    toLock.add(global)
    let rc = ydbLock(100000, globals)
    assert getLockCountFromYottaDb() == globals.len

  let rc = ydbLock(100000, @[])
  assert getLockCountFromYottaDb() == 0

proc testIncrement() =
  ydbSet("^COUNTERS", @["upcount"], "0")
  for i in 0..<1000000:
    let cnt = ydbIncrement("^COUNTERS", @["upcount"])
  assert ydbGet("^COUNTERS", @["upcount"]) == "1000000"

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
    test "next/previous Subscript":
      test "nextSubscript": nextSubscript("^LL", @["HAUS", "ELE..."], @["HAUS", "HEIZUNG"])
      test "nextSubscript":nextSubscript("^LL", @["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
      test "previousSubscript":previousSubscript("^LL", @["HAUS", "ELEKTRIK", "SICHERUN..."], @["HAUS", "ELEKTRIK", "DOSEN"] )
      test "nextSubscriptIter":nextSubscriptIter("^LL", @["HAUS", "ELEKT..."], @["HAUS", "HEIZUNG"])
      test "previousSubscriptIter":previousSubscriptIter("^LL", @["HAUS", "HEIZUNG"], @["HAUS", "ELEKTRIK"])
    test "Delete Operations":
      test "deleteTree": deleteTree()
      test "deleteNode": deleteNode()
      test "deleteGlobalVar": testDeleteTree()
    test "Special Variables":
      test "testSpecialVariables": testSpecialVariables()
      test "increment": testIncrement()
    test "Set and Get Variable":
      test "testSetAndGetVariable": testSetAndGetVariable()
    test "Lock Handling":
      test "testLock": testLock()

proc testA() =
  # ^X(0..1000000)=i total 2300ms
  test "simpleSet": simpleSet("^X", MAX)
  test "simpleGet": simpleGet("^X", MAX)
  test "simpleDel": simpleDelete("^X", MAX)

proc testB() =
  testYdbVar()
  testDeleteTree()

when isMainModule:
  test()
  #testB()
  #testA()

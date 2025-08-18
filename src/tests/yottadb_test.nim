import std/[strformat, strutils, times, os, osproc, unittest]
import ../yottadb

const
  MAX = 100

func keysToString(global: string, subscript: Subscripts): string =
  result = global & "("
  for i, idx in subscript:
    try:
      let nmbr = parseInt(idx)
      result.add($nmbr)
    except ValueError:
      result.add("\"" & idx & "\"")

    if i < subscript.len - 1:
      result.add(",")

  result.add(")")

proc getLockCountFromYottaDb(): int =
  # Show real locks on db with 'lke show'
  var lockcnt = 0
  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if line.contains("Owned by"):
      inc(lockcnt)
  return lockcnt

# ------------- Test cases are here ---------------------
proc testYdbVar() =
  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i], $i)

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


proc writeData() =
  for i in 0..MAX:
    ydbSet("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} aus der Schweiz")
    ydbSet("^LJ", @["LAND", "ORT", $i, $i], fmt"Hello Lothar Jöckel {i} from Switzerland")

  ydbSet("^LJ", @["LAND", "STRASSE"], fmt"Gartenweg 4")


proc readBack() =
  for i in 0..MAX:
    let result = ydbGet("^LJ", @["LAND", "ORT", $i])
    assert result == fmt"Hello Lothar Jöckel {i} aus der Schweiz"


proc testData() =
  assert 0 == ydbData("^LJ", @["XXX"])  # There is neither a value nor a subtree, i.e., it is undefined.
  assert 10 == ydbData("^LJ", @["LAND"])  # There is no value, but there is a subtree.
  assert 11 == ydbData("^LJ", @["LAND", "ORT", "1"])  # There are both a value and a subtree.
  assert 1 == ydbData("^LJ", @["LAND", "STRASSE"])  # There is a value, but no subtree

  doAssertRaises(YottaDbError): discard ydbData("^LJ", @[""])


proc traverseNext(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var subs = start
  for subs in nextItem(global, subs):
    inc(cnt)
  doAssert cnt == MAX * 2 + 3


proc traversePrevious(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var subs = start
  for subs in previousItem(global, subs):
    inc(cnt)
  doAssert cnt == MAX * 2 + 2


proc nextSubscript() =
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
  ydbSet(global, @["HAUS", "HEIZUNG"])
  ydbSet(global, @["HAUS", "HEIZUNG", "MESSGERAETE"])
  ydbSet(global, @["HAUS", "HEIZUNG", "ROHRE"])
  ydbSet(global, @["LAND"])
  ydbSet(global, @["LAND", "FLAECHEN"])
  ydbSet(global, @["LAND", "NUTZUNG"])
  ydbSet(global, @["ORT"])

  var subscript = @["HAUS", "ELEKTRIK", ""]
  var rc = 0
  while(rc == YDB_OK):
    rc = ydb_subscript_next(global, subscript)
    echo("rc=" & $rc & "keys=" & subscript)

  echo "Getting previous subscript"
  subscript = @["HAUS", "HEIZUNG"]
  rc = 0
  while(rc == YDB_OK):
    rc = ydb_subscript_previous(global, subscript)
    echo("rc=" & $rc & "keys=" & subscript)


proc deleteTree() =
  var rc = ydbDeleteNode("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    rc = ydbDeleteTree("^LJ", @["LAND", "ORT", $i, $i])


proc deleteNode() =
    var rc = ydbDeleteNode("^CNT", @["CHANNEL", "INPUT"])
    var result = ydbIncrement("^CNT", @["CHANNEL", "INPUT"], 1)
    assert ydbGet("^CNT", @["CHANNEL", "INPUT"]) == "1"


proc deleteGlobalVar() =
  discard ydbDeleteNode("^LJ", @[])


proc getSpecialVariables() =
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

  doAssertRaises(YottaDbError): discard ydbGet("$XXXX")


proc setAndGetVariable() =
  let vars = ["X"]
  for variable in vars:
    ydbSet(variable, @[], "hello")
    ydbSet("X", @["1"], "hello X(1)")
    ydbSet("X", @["1","1"], "hello X(1,1)")
    ydbSet("X", @["1","2"], "hello X(1,2)")
    ydbSet("X", @["1","3"], "hello X(1,3)")
    ydbSet("X", @["2"], "hello X(2)")
    ydbSet("X", @["2","3"], "hello X(2,3)")

  echo "X=", ydbGet("X")
  echo "X(1)=", ydbGet("X", @["1"])
  echo "X(2)=", ydbGet("X", @["2"])
  echo "X(1,1)=", ydbGet("X", @["1","1"])
  traverseNext("X")  


proc testLock() =
  let globals = @[
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
  var rc = ydbLock(1000000000, globals)
  assert getLockCountFromYottaDb() == globals.len

  rc = ydbLock(1000000000, @[])
  assert getLockCountFromYottaDb() == 0

# -------------------------------------------------------------------

suite "YottaDB Tests":

  test "Basic functionality":
    testYdbVar()

  test "Write and Read Data":
    writeData()
    readBack()

  test "Check Data Structure":
    testData()

  test "Traverse Keys":
    traverseNext("^LJ")
    traversePrevious("^LJ", @["LAND", "STRASSE"])

#   test "Delete Operations":
#     deleteTree()
#     deleteNode()
#     deleteGlobalVar()

#   test "Subscript Iteration":
#     nextSubscript()

#   test "Special Variables":
#     getSpecialVariables()

#   test "Set and Get Variable":
#     setAndGetVariable()
#     traverseNext("X")

  test "Lock Handling":
    testLock()

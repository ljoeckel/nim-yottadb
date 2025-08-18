import std/[strformat, strutils, times, os, osproc, unittest]
import ../yottadb

const
  MAX = 100
  LOG = false

template print(str: varargs[string]) =
  if LOG:
    for s in str: stdout.write(s)
    stdout.writeLine("")

template execute(title: string, body: untyped): untyped =
  let cpu_tm = cpuTime()
  let epoch_tm = epochTime()

  try:
    body
  except CatchableError:
    echo getCurrentExceptionMsg()

  let diffCpu = (cpuTime() - cpu_tm) * 1000
  let diffEpoch = (epochTime() - epoch_tm) * 1000

  echo title, ": finished in ", formatFloat(diffCpu, ffDecimal, 0, '\0') ," ms CPU, ", formatFloat(diffEpoch, ffDecimal, 0, '\0'), " ms Epoch"
  echo ""

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

# ------------- Test cases are here ---------------------

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
  assert ydbData("^LJ", @["XXX"]) == 0 # There is neither a value nor a subtree, i.e., it is undefined.
  assert ydbData("^LJ", @["LAND"]) == 10 # There is no value, but there is a subtree.
  assert ydbData("^LJ", @["LAND", "ORT", "1"]) == 11 # There are both a value and a subtree.
  assert ydbData("^LJ", @["LAND", "STRASSE"]) == 1 # There is a value, but no subtree

  doAssertRaises(YottaDbError): discard ydbData("^LJ", @[""])

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
    print("rc=" & $rc & "keys=" & subscript)

  echo "Getting previous subscript"
  subscript = @["HAUS", "HEIZUNG"]
  rc = 0
  while(rc == YDB_OK):
    rc = ydb_subscript_previous(global, subscript)
    print("rc=" & $rc & "keys=" & subscript)

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
    print variable, "=", ydbGet(variable)

  let s = ydbGet("$XXXX")

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

  print "X=", ydbGet("X")
  print "X(1)=", ydbGet("X", @["1"])
  print "X(2)=", ydbGet("X", @["2"])
  print "X(1,1)=", ydbGet("X", @["1","1"])


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

# Show real locks on db with 'lke show'
  var lockcnt = 0
  let lke = findExe("lke")
  let result = execProcess(lke & " show")
  for line in result.split('\n'):
    if line.contains("Owned by"):
      inc(lockcnt)
  assert lockcnt == globals.len
  
  sleep 3000
  echo "released all locks"
  rc = ydbLock(1000000000, @[])
  echo "rc after release ", rc

# -------------------------------------------------------------------

proc main() =
  execute "ALL TESTS":
    execute "writeData":  writeData()
    execute "readBack": readBack()
    execute "testData": testData()
    execute "deleteTree": deleteTree()
    execute "deleteNode": deleteNode()
    execute "deleteGlobalVar": deleteGlobalVar()
    execute "nextSubscript": nextSubscript()
    execute "getSpecialVariables": getSpecialVariables()
    execute "setAndGetVariable": setAndGetVariable()
    execute "testLock": testLock()

when isMainModule:
  main()

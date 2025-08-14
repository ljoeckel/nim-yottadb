import std/strformat
import std/strutils 
import std/times
import yottadb

const 
  MAX = 1000
  LOG = false

template print(str: varargs[string]) =
  if LOG:
    for s in str: stdout.write(s)
    stdout.writeLine("")

template execute(title: string, body: untyped): untyped =
  let time = cpuTime()
  try:
    body
  except:
    echo getCurrentExceptionMsg()
  let diff = (cpuTime() - time) * 1000
  echo title, ": finished in ", formatFloat(diff, ffDecimal, 0, '\0') ," ms."
  echo ""

func keysToString(global: string, subscript: seq[string]): string =
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

proc writeData() =
  for i in 0..MAX:
    ydb_set("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} aus der Schweiz")
    ydb_set("^LJ", @["LAND", "ORT", $i, $i], fmt"Hello Lothar Jöckel {i} from Switzerland")

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Gartenweg 4")

proc readBack() =
  for i in 0..MAX:
    let result = ydb_get("^LJ", @["LAND", "ORT", $i])
    assert result == fmt"Hello Lothar Jöckel {i} aus der Schweiz"

proc testData() =
  assert ydb_data("^LJ", @["XXX"]) == 0 # There is neither a value nor a subtree, i.e., it is undefined.
  assert ydb_data("^LJ", @["LAND"]) == 10 # There is no value, but there is a subtree.
  assert ydb_data("^LJ", @["LAND", "ORT", "1"]) == 11 # There are both a value and a subtree.
  assert ydb_data("^LJ", @["LAND", "STRASSE"]) == 1 # There is a value, but no subtree

  doAssertRaises(YottaDbError): discard ydb_data("^LJ", @[""])

proc traverseNext(global: string, start_subscript: seq[string] = @[]) =
  var rc: int
  var subscript = start_subscript
  while true:
    (rc, subscript) = ydb_node_next(global, subscript)
    if rc != YDB_OK: break
    print keysToString(global, subscript)

proc traversePrevious(global: string, start_subscript: seq[string] = @[]) =
  var rc: int
  var subscript = start_subscript
  while true:
    (rc, subscript) = ydb_node_previous(global, subscript)
    if rc != YDB_OK: break
    print keysToString(global, subscript)

proc nextSubscript() =
  let global = "^LL"

  ydb_set("^LL", @["HAUS"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "DOSEN"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "1"], "Telefondose")
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "2"], "Steckdose")
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "3"], "IP-Dose")
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "DOSEN", "4"], "KFZ-Dose")
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "KABEL"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "KABEL", "FARBEN"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "KABEL", "STAERKEN"])
  ydb_set("^LL", @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
  ydb_set("^LL", @["HAUS", "HEIZUNG"])
  ydb_set("^LL", @["HAUS", "HEIZUNG", "MESSGERAETE"])
  ydb_set("^LL", @["HAUS", "HEIZUNG", "ROHRE"])
  ydb_set("^LL", @["LAND"])
  ydb_set("^LL", @["LAND", "FLAECHEN"])
  ydb_set("^LL", @["LAND", "NUTZUNG"])
  ydb_set("^LL", @["ORT"])

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
  var rc = ydb_delete_node("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    rc = ydb_delete_tree("^LJ", @["LAND", "ORT", $i, $i])

proc deleteNode() =
    var rc = ydb_delete_node("^CNT", @["CHANNEL", "INPUT"])
    var result = ydb_increment("^CNT", @["CHANNEL", "INPUT"], 1)
    assert ydb_get("^CNT", @["CHANNEL", "INPUT"]) == "1"

proc deleteGlobalVar() =
  discard ydb_delete_node("^LJ", @[])

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
    print variable, "=", ydb_get(variable)

  let s = ydb_get("$XXXX")

proc setAndGetVariable() =
  let vars = ["X"]
  for variable in vars:
    ydb_set(variable, @[], "hello")
    ydb_set("X", @["1"], "hello X(1)")
    ydb_set("X", @["1","1"], "hello X(1,1)")
    ydb_set("X", @["1","2"], "hello X(1,2)")
    ydb_set("X", @["1","3"], "hello X(1,3)")
    ydb_set("X", @["2"], "hello X(2)")
    ydb_set("X", @["2","3"], "hello X(2,3)")

  print "X=", (ydb_get("X"))
  print "X(1)=", (ydb_get("X", @["1"]))
  print "X(2)=", (ydb_get("X", @["2"]))
  print "X(1,1)=", (ydb_get("X", @["1","1"]))
  traverseNext("X")  

# -------------------------------------------------------------------

execute "ALL TESTS":

  execute "writeData":  writeData()
  execute "readBack": readBack()
  execute "testData": testData()
  execute "traverseNext(^LJ)": traverseNext("^LJ")
  execute "deleteTree": deleteTree()
  execute "deleteNode": deleteNode()
  execute "deleteGlobalVar": deleteGlobalVar()
  execute "nextSubscript": nextSubscript()
  execute "getSpecialVariables": getSpecialVariables()
  execute "setAndGetVariable": setAndGetVariable()
  execute "traverseNext(^LJ)": traverseNext("^LJ") # get all keys
  execute "traveseNext(^LJ(LAND,ORT)": traverseNext("^LJ", @["LAND", "ORT", "5"]) # start at ^LJ("LAND","ORT","5") -> 10
  execute "traversePrevious(^LJ(LAND, ORT, 5)": traversePrevious("^LJ", @["LAND", "ORT", "5"]) # start at ^LJ("LAND","ORT","5") -> 0

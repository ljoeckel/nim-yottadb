import std/strformat
import libs/nim_yottadb
import std/strutils 


const MAX=10

func indexKeysToString(global: string, indexKeys: seq[string]): string =
  result = global & "("

  for i, idx in indexKeys:
    try:
      let nmbr = parseInt(idx)
      result.add($nmbr)
    except ValueError:
      result.add("\"" & idx & "\"")

    if i < indexKeys.len - 1:
      result.add(",")
  
  result.add(")")


proc writeData() =
  echo "Write data"
  for i in 0..MAX:
    try:
      # Save in yottadb
      ydb_set("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} aus der Schweiz")
      ydb_set("^LJ", @["LAND", "ORT", $i, $i], fmt"Hello Lothar Jöckel {i} from Switzerland")
    except YottaDbError:
      echo getCurrentExceptionMsg()

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Gartenweg 4")

proc readBack() =
  echo "Read back"
  for i in 0..MAX:
    try:
      let result = ydb_get("^LJ", @["LAND", "ORT", $i])
      assert result == fmt"Hello Lothar Jöckel {i} aus der Schweiz"
    except YottaDbError:
      echo getCurrentExceptionMsg()


proc testData() =
  echo "Test Data"
  try:
    assert ydb_data("^LJ", @["XXX"]) == 0 # There is neither a value nor a subtree, i.e., it is undefined.
    assert ydb_data("^LJ", @["LAND"]) == 10 # There is no value, but there is a subtree.
    assert ydb_data("^LJ", @["LAND", "ORT", "1"]) == 11 # There are both a value and a subtree.
    assert ydb_data("^LJ", @["LAND", "STRASSE"]) == 1 # There is a value, but no subtree

    doAssertRaises(YottaDbError): discard ydb_data("^LJ", @[""])
  except YottaDbError:
    echo getCurrentExceptionMsg()


proc traverseNext(global: string) =
  echo "Traverse NEXT over Global"
  try:
    var indexKeys = ydb_node_next(global, @[""])
    while(indexKeys.len > 0):
      let key = indexKeysToString(global, indexKeys)
      let value = ydb_get(global, indexKeys)
      echo fmt"{key}={value}"
      indexKeys = ydb_node_next(global, indexKeys)
  except YottaDbError:
    echo getCurrentExceptionMsg()


proc traversePrevious() =
  echo "Traverse PREVIOUS over Global"
  let glb="^LJ"
  var indexKeys = @["LAND", "STRASSE"]
  echo "Starting with ", indexKeysToString(glb, indexKeys)
  try:
    indexKeys = ydb_node_previous(glb, indexKeys)
    while(indexKeys.len > 0):
      let key = indexKeysToString(glb, indexKeys)
      let value = ydb_get(glb, indexKeys)
      echo fmt"{key}={value}"
      indexKeys = ydb_node_previous(glb, indexKeys)
  except YottaDbError:
    echo getCurrentExceptionMsg()


proc nextSubscript() =
  echo "Getting next subscript"
  let glb = "^LL"

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

  try:
    var indexkeys = @["HAUS", "ELEKTRIK", ""]
    var rc = 0
    while(rc == YDB_OK):
      rc = ydb_subscript_next(glb, indexKeys)
      echo "rc=", rc, "keys=", indexKeys
  except YottaDbError:
      echo getCurrentExceptionMsg()


proc deleteTree() =
  echo "Delete Tree"
  try:
    var rc = ydb_delete_node("^LJ", @["LAND", "STRASSE"])
    for i in 0..MAX:
      rc = ydb_delete_tree("^LJ", @["LAND", "ORT", $i, $i])
  except YottaDbError:
    echo getCurrentExceptionMsg()

proc deleteNode() =
  echo "Delete Node"
  try:
      var rc = ydb_delete_node("^CNT", @["CHANNEL", "INPUT"])
      var result = ydb_increment("^CNT", @["CHANNEL", "INPUT"], 1)
      assert ydb_get("^CNT", @["CHANNEL", "INPUT"]) == "1"
  except YottaDbError:
    echo getCurrentExceptionMsg()

proc deleteGlobalVar() =
  echo "Delete Global var ^LJ"
  echo ydbmsg(ydb_delete_node("^LJ", @[]))


proc getSpecialVariables() =
  echo "getSpecialVariables"
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
    try:
      echo variable, "=", ydb_get(variable)
    except:
      echo "Error when getting variable ", variable, ": ", getCurrentExceptionMsg()

  try:
    let s = ydb_get("$XXXX")
  except YottaDbError:
    echo getCurrentExceptionMsg()


proc setAndGetVariable() =
  echo "setAndGetVariable"
  let vars = ["X"]
  for variable in vars:
    try:
      echo variable
      ydb_set(variable, @[], "hello")
      ydb_set("X", @["1"], "hello X(1)")
      #echo variable, "=", ydb_set(variable, @[], value="Hello")
    except:
      echo "Error when setting variable ", variable, ": ", getCurrentExceptionMsg()

  try:
    echo "X=", (ydb_get("X"))
    echo "X(1)=", (ydb_get("X", @["1"]))
    
  except YottaDbError:
    echo getCurrentExceptionMsg()


# writeData()
# readBack()
# testData()
traverseNext("^LJ")
# traversePrevious()
# deleteTree()
# deleteNode()
# deleteGlobalVar()
# nextSubscript()
# getSpecialVariables()
setAndGetVariable()
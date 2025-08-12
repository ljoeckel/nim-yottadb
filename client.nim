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


proc traverseNext() =
  echo "Traverse NEXT over Global"
  let glb="^LJ"
  try:
    var indexKeys = ydb_node_next(glb, @[""])
    while(indexKeys.len > 0):
      let key = indexKeysToString(glb, indexKeys)
      let value = ydb_get(glb, indexKeys)
      echo fmt"{key}={value}"
      indexKeys = ydb_node_next(glb, indexKeys)
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


writeData()
readBack()
testData()
traverseNext()
traversePrevious()
deleteTree()
deleteNode()
deleteGlobalVar()
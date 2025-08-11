import std/strformat
import libs/nim_yottadb

const MAX=10
for i in 0..MAX:
  try:
    # Save in yottadb
    ydb_set("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} from switzerland")
    ydb_set("^LJ", @["LAND", "ORT", $i, $i], fmt"Hello Lothar Jöckel {i} from switzerland")
    # Read back
    let result = ydb_get("^LJ", @["LAND", "ORT", $i])
    assert result == fmt"Hello Lothar Jöckel {i} from switzerland"
  except YottaDbError:
    echo getCurrentExceptionMsg()

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Hello Lothar Jöckel {i} from switzerland")


# Test ydb_data
try:
  assert ydb_data("^LJ", @["XXX"]) == 0 # There is neither a value nor a subtree, i.e., it is undefined.
  assert ydb_data("^LJ", @["LAND"]) == 10 # There is no value, but there is a subtree.
  assert ydb_data("^LJ", @["LAND", "ORT", "1"]) == 11 # There are both a value and a subtree.
  assert ydb_data("^LJ", @["LAND", "STRASSE"]) == 1 # There is a value, but no subtree

  doAssertRaises(YottaDbError): discard ydb_data("^LJ", @[""])
except YottaDbError:
  echo getCurrentExceptionMsg()


try:
  var rc = ydb_delete_node("^LJ", @["LAND", "STRASSE"])
  for i in 0..MAX:
    rc = ydb_delete_tree("^LJ", @["LAND", "ORT", $i, $i])
except YottaDbError:
  echo getCurrentExceptionMsg()


try:
    var rc = ydb_delete_node("^CNT", @["CHANNEL", "INPUT"])
    var result = ydb_increment("^CNT", @["CHANNEL", "INPUT"], 1)
    assert ydb_get("^CNT", @["CHANNEL", "INPUT"]) == "1"
except YottaDbError:
  echo getCurrentExceptionMsg()

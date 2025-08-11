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
  except YottaDbError:
    echo getCurrentExceptionMsg()

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Hello Lothar Jöckel {i} from switzerland")


# Test ydb_data
#    0 - There is neither a value nor a subtree, i.e., it is undefined.
#    1 - There is a value, but no subtree
#    10 - There is no value, but there is a subtree.
#    11 - There are both a value and a subtree.
try:
  assert ydb_data("^LJ", @["XXX"]) == 0
  assert ydb_data("^LJ", @["LAND"]) == 10
  assert ydb_data("^LJ", @["LAND", "ORT", "1"]) == 11
  assert ydb_data("^LJ", @["LAND", "STRASSE"]) == 1

  doAssertRaises(YottaDbError): discard ydb_data("^LJ", @[""])
except YottaDbError:
  echo getCurrentExceptionMsg()
    
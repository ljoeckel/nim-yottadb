import std/strformat
import libs/nim_yottadb

const MAX=10
for i in 0..MAX:
  try:
    # Save in yottadb
    ydb_set("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} from switzerland")
    ydb_set("^LJ", @["LAND", "ORT", $i, $1], fmt"Hello Lothar Jöckel {i} from switzerland")
    # Read back
    let result = ydb_get("^LJ", @["LAND", "ORT", $i])
  except YottaDbError:
    echo getCurrentExceptionMsg()

  ydb_set("^LJ", @["LAND", "STRASSE"], fmt"Hello Lothar Jöckel {i} from switzerland")


# Test ydb_data
try:
  var status = ydb_data("^LJ", @["XXX"])
  echo "^LJ(XXX) status:", status # 0 - no value, no subtree

  status = ydb_data("^LJ", @["LAND"]) 
  echo "^LJ(LAND) status:", status # 10 no value but there is a subtree

  status = ydb_data("^LJ", @["LAND", "ORT", "1"]) 
  echo "^LJ(LAND, ORT, 1) status:", status # 1 there is a value value but no subtree

  status = ydb_data("^LJ", @["LAND", "STRASSE"]) 
  echo "^LJ(LAND, STRASSE) status:", status # 1 there is a value value but no subtree

  status = ydb_data("^LJ", @[""])
  echo "^LJ(XXX) status:", status # exception
except YottaDbError:
  echo getCurrentExceptionMsg()
    
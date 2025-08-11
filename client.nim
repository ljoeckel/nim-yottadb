import std/strformat
import libs/nim_yottadb

const MAX=10
for i in 0..MAX:
  try:
    # Save in yottadb
    ydb_set("^LJ", @["LAND", "ORT", $i], fmt"Hello Lothar Jöckel {i} from switzerland")
    # Read back
    let result = ydb_get("^LJ", @["LAND", "ORT", $i])
  except YottaDbError:
    echo getCurrentExceptionMsg()
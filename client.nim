import std/strformat
import libs/nim_yottadb

const MAX=1000000
for i in 0..MAX:
  # Save in yottadb
  try:
    ydb_set("^LJ", fmt"Hello Lothar Jöckel {i} from switzerland", $i)
  except YottaDbError:
    echo "YOTTADB: ", getCurrentExceptionMsg()

echo "Start reading..."
for i in 0..MAX:
  try:
    let result = ydb_get("^LJ", $i)
  except YottaDbError:
    echo "YOTTADB: ", getCurrentExceptionMsg()
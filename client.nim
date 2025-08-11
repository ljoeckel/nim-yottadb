import std/strformat

import libs/nim_yottadb

for i in 0..5:
  echo i
  # Save in yottadb
  try:
    ydb_set("^LJ", fmt"Hello {i} from switzerland", $i)
    ydb_set("^LJ", "Hello", fmt"{i}", $i)
    ydb_set("^LJ", "Hello")
  except YottaDbError:
    echo "YOTTADB: ", getCurrentExceptionMsg()

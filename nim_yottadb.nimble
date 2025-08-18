# Package Information
version = "0.1.0"
author = "Lothar Joeckel"
description = "NIM language implementation for the YottaDB database"
license = "MIT"
srcDir = "src"
bin = @["examples/client", "examples/upcount", "tests/yottadb_test"]
requires "nim >= 2.2.4"

# Dependencies
requires "futhark"

task test, "Run nim-yottadb unittests":
  exec "nim c -r --hints:off --verbosity:0 src/tests/yottadb_test.nim"
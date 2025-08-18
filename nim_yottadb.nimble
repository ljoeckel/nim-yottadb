# Package Information
version = "0.1.0"
author = "Lothar Joeckel"
description = "NIM language implementation for the YottaDB database"
license = "MIT"

# Dependencies
requires "futhark"

task test, "Run nim-yottadb unittests":
  exec "nim c -r --hints:off --verbosity:0 yottadb_test.nim"
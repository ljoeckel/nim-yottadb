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

task setupBook, "Compiles the nimibook CLI-binary used for generating the docs":
  exec "nim c -d:release nbook.nim"

before book:
  rmDir "docs"
  exec "nimble setupBook"

task book, "Generate book":
  exec "./nbook --mm:orc --deepcopy:on update"
  exec "./nbook --mm:orc --deepcopy:on build"

after book:
  cpFile("CNAME", "docs/CNAME")

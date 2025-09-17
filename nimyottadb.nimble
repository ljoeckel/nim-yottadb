# Package Information
version = "0.1.0"
author = "Lothar Joeckel"
description = "NIM language implementation for the YottaDB database"
license = "MIT"
srcDir = "src"
binDir = "bin"
requires "nim >= 2.2.4"

# Dependencies
requires "malebolgia"
requires "https://github.com/jaar23/tui_widget.git"

task test, "Run nimyottadb unittests":
  exec "nim c -r -d:release --threads:off --hints:off --verbosity:0 src/tests/yottadb_test.nim"
  exec "nim c -r -d:release --threads:off --hints:off --verbosity:0 src/tests/dsl_test.nim"
  exec "nim c -r -d:release --threads:on --hints:off --verbosity:0 src/tests/yottadb_test.nim"
  exec "nim c -r -d:release --threads:on --hints:off --verbosity:0 src/tests/yottadb_test_threaded.nim"
  exec "nim c -r -d:release --threads:on --hints:off --verbosity:0 src/tests/dsl_test.nim"
  exec "nim c -r -d:release --threads:on --hints:off --verbosity:0 src/tests/dsl_lock_test.nim"

task examples, "Compile the example apps":
  exec "nim c -r -d:release --threads:off src/examples/benchmark"
  exec "nim c -r -d:release --threads:off src/examples/benchmark2"
  exec "nim c -r -d:release --threads:off src/examples/clientser"
  exec "nim c -r -d:release --threads:off src/examples/hello_customer"
  exec "nim c -r -d:release --threads:off src/examples/say_hello"
  exec "nim c -r -d:release --threads:off src/examples/tx"
  exec "nim c -r -d:release --threads:on src/examples/tx_thread"
  exec "nim c -r -d:release --threads:on src/examples/ydbSet_thread"
  exec "nim c -r -d:release --threads:on src/examples/traverse"

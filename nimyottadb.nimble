# Package Information
version = "0.4.5"
author = "Lothar Joeckel"
description = "Nim language implementation for the YottaDB database"
license = "MIT"
srcDir = "src"
binDir = "bin"
requires "nim >= 2.2.4"

# Dependencies
requires "malebolgia >=1.3.2"
requires "zippy >=0.10.20"
requires "https://github.com/ljoeckel/nimlz4.git"


import std/strformat
const names = @[
    "binary",  "callin",  "data",  "delete",  "delexcl",  "dsl_test",  "dsliterators",  "increment",  "iterator",
    "kill",  "locks",  "nextnode",  "serialization_test",  "setget",  "setgetlocal",  "special_vars",  "transaction",
    "ydbdsl_test",  "yottadb_test",  "zwr",  "sequences",  "indirection" 
    ]

const examples = @[
    "src/examples/sayHello",
    "src/examples/benchmark",
    "src/examples/clientser",
    "src/examples/hello_customer",
    "src/examples/tx",
    "src/examples/image_loader",
    "src/3n1/solver",
    #"m/bidwars",
    ]

const examples_threaded = @[
    "src/examples/dsl_lock_test",
    "src/examples/tx_thread",
    "src/examples/tx_thread_dsl",
    "src/examples/tx_upcount_thread",
    "src/examples/ydbSet_thread",
    ]

task test, "Run nimyottadb unittests":
  for name in names:
    echo fmt"Test {name}"
    exec fmt"nim c -r --stackTrace:on --lineTrace:on --threads:off --hints:off --verbosity:0 src/tests/{name}.nim"
    echo fmt"Test {name} --threads:on"
    exec fmt"nim c -r --stackTrace:on --lineTrace:on --threads:on  --hints:off --verbosity:0 src/tests/{name}.nim"
    exec fmt"rm -f src/tests/{name}"


task examples, "Run example apps":
    for name in examples:
        echo fmt"Run {name} example"
        exec fmt"nim c -r -d:release --hints:off --verbosity:0 {name}"
        exec fmt"rm -f {name}"

    for name in examples_threaded:
        echo fmt"Run {name} multi-threaded example"
        exec fmt"nim c -r -d:release --hints:off --verbosity:0 --threads:on {name}"
        exec fmt"rm -f {name}"
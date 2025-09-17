import yottadb
import utils

proc sayHello() =
    for id in 0..<10000000:
        ydb_set("^hello",@[$id], $id)

when isMainModule:
    timed("sayHello"): sayHello()

import yottadb
import utils

proc create() =
    for id in 0..<10000000:
        set: ^hello(id)=id

proc count() =
    var cnt = 0
    var (rc, subs) = nextnode: ^hello()
    while rc == YDB_OK:
        inc(cnt)
        (rc, subs) = nextnode: ^hello(subs)
    echo "Have ", cnt, " entries"

proc delete() =
    for id in 0..<10000000:
        delnode: ^hello(id)


when isMainModule:
    timed("sayHello"): create()
    timed("sayHelloCount"): count()
    timed("sayHelloDelete"): delete()

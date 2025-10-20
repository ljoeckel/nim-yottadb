import yottadb
import ydbutils

proc create() =
    kill: ^hello
    for id in 0..<10000000:
        setvar: ^hello(id)=id

proc count() =
    var cnt = 0
    var (rc, gbl) = nextnode: ^hello
    while rc == YDB_OK:
        inc(cnt)
        (rc, gbl) = nextnode: @gbl
    echo "Have ", cnt, " entries"

proc getdata() =
    for id in 0..<10000000:
        let val = get: ^hello(id)

proc delete() =
    for id in 0..<10000000:
        killnode: ^hello(id)

proc collectGlobals(): seq[string] =
    timed:
        var (rc, gbl) = nextnode: ^hello
        while rc == YDB_OK:
            result.add(gbl)
            (rc, gbl) = nextnode: @gbl
        echo "Collected ", result.len, " globals"

proc getDataFromCollection() =
    for id in collectGlobals():
        let val = get @id

when isMainModule:
    timed("sayHello"): create()
    timed("sayHelloCount"): count()
    timed("sayHelloGet"): getdata()
    timed("DataFromColleciton"): getDataFromCollection()
    timed("sayHelloDelete"): delete()

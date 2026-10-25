import yottadb
import std/[unittest]

type
    Dummy = object
        name: string
        age: int

proc testTransactionBingoser() =
    var rc = Transaction:
        let obj4711 = Dummy(name: "lothar", age: 100)
        saveObject[Dummy](4711, obj4711)
    assert Dummy(name: "lothar", age: 100) == loadObject[Dummy](4711)

    # A cdecl callback cannot capture locals; `Transaction(obj)` hands a copy
    # of the object to the callback via `param`.
    let obj4712 = Dummy(name: "martina", age: 99)
    rc = Transaction(obj4712):
        let obj = cast[ptr Dummy](param)[]
        saveObject[Dummy](4712, obj)
    assert loadObject[Dummy](4712) == obj4712
    Kill ^Dummy


test "transactionBingoser": testTransactionBingoser()

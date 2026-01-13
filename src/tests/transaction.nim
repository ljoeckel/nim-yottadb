import std/[unittest]
import yottadb

    
when compileOption("threads"):
    proc testTransactionMT =
        let rc = TransactionMT("4711"):
            let dta = $cast[cstring](param)
            ydb_set("^AAA", @["2", dta], "transaction2MT tptoken="  & $tptoken, tptoken)

        assert rc == YDB_OK
        assert 1 == data ^AAA(2,4711)
        
    
    test "transactionMT": testTransactionMT()

else:
    proc testTransaction() =
        let rc = Transaction:
            setvar: ^AAA(1) = "transaction1"
        assert rc == YDB_OK
        assert 1 == data ^AAA(1)

    test "transaction": testTransaction()
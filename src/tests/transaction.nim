import std/[unittest]
import yottadb

    
when compileOption("threads"):
    proc testTransactionMT =
        var rc = Transaction:
            ydb_set("^AAA", @["100"], "noparam tptoken="  & $tptoken, tptoken)
        assert 1 == data ^AAA(100)

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            ydb_set("^AAA", @["101", dta], "cstring tptoken="  & $tptoken, tptoken)
        assert 1 == data ^AAA(101, "ABC")

        rc = Transaction(4712):
            let dta = $cast[cint](param)
            ydb_set("^AAA", @["102", dta], "cint tptoken="  & $tptoken, tptoken)
        assert 1 == data ^AAA(102, 4712)

        # Try invalid globalname -> should rollback after 4 tries
        rc = Transaction:
            ydb_set("^^AAA", @["999"], "tp_rollback", tptoken)
        assert rc == YDB_TP_ROLLBACK

    test "transactionMT": testTransactionMT()

else:
    proc testTransaction =
        var rc = Transaction:
            ydb_set("^AAA", @["1"], "noparam")
        assert rc == YDB_OK
        assert 1 == data ^AAA(1)

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            ydb_set("^AAA", @["2", dta], "cstring")
        assert rc == YDB_OK            
        assert 1 == data ^AAA(2, "ABC")

        rc = Transaction(4712):
            let dta = $cast[cint](param)
            ydb_set("^AAA", @["3", dta], "cint")
        assert rc == YDB_OK            
        assert 1 == data ^AAA(3, 4712)

        # Try invalid globalname -> should rollback after 4 tries
        rc = Transaction:
            ydb_set("^^AAA", @["999"], "tp_rollback")
        assert rc == YDB_TP_ROLLBACK

    test "transaction": testTransaction()
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

        info "Nested transaction tests do not work currently with MT, skipping"

    test "transactionMT": testTransactionMT()

else:
    proc testTransaction =
        var rc = Transaction:
            ydb_set("^AAA", @["1"], "noparam")
        assert rc == YDB_OK
        assert 1 == data ^AAA(1)

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            assert dta == "ABC"
            ydb_set("^AAA", @["2", dta], "cstring")
        assert rc == YDB_OK            
        assert 1 == data ^AAA(2, "ABC")

        rc = Transaction(4712):
            let dta = cast[cint](param)
            assert dta == 4712
            ydb_set("^AAA", @["3", $dta], "cint")
        assert rc == YDB_OK            
        assert 1 == data ^AAA(3, 4712)

        # Try invalid globalname -> should rollback after 4 tries
        rc = Transaction:
            ydb_set("^^AAA", @["999"], "tp_rollback")
        assert rc == YDB_TP_ROLLBACK

        rc = Transaction:
            # Nested transaction
            var rc2 = Transaction:
                ydb_set("^AAA", @["4"], "noparam")
            assert rc2 == YDB_OK
            ydb_set("^AAA", @["5"], "noparam")
        assert rc == YDB_OK           
        assert 1 == data ^AAA(4)   
        assert 1 == data ^AAA(5)

        kill: ^AAA
        rc = Transaction:
            # Nested transaction with rollback
            var rc2 = Transaction:
                ydb_set("^AAA", @["4"], "noparam")
                return YDB_TP_ROLLBACK
            assert rc2 == YDB_TP_ROLLBACK
            ydb_set("^AAA", @["5"], "noparam")
        assert rc == YDB_OK           
        assert 0 == data ^AAA(4)   
        assert 1 == data ^AAA(5)


    test "transaction": testTransaction()
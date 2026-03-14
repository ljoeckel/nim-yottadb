import std/[unittest, strformat]
import yottadb

when compileOption("threads"):
    proc testTransactionAPIMT =
        var rc = Transaction:
            ydb_set("^AAA", @["100"], fmt"tptoken={tptoken}", tptoken)
        assert 1 == ydb_data("^AAA", @["100"]) 
        
        rc = Transaction:
            Set: ^AAA(101) = fmt"tptoken={tptoken}"
        assert 1 == ydb_data("^AAA", @["101"]) 

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            ydb_set("^AAA", @["102", dta], "cstring tptoken="  & $tptoken, tptoken)
        assert 1 == ydb_data("^AAA", @["102", "ABC"]) 

        rc = Transaction(4712):
            let dta = $cast[cint](param)
            ydb_set("^AAA", @["102", dta], "cint tptoken="  & $tptoken, tptoken)
        assert 1 == ydb_data("^AAA", @["102", "4712"])             

        # Try invalid globalname -> should rollback after 4 tries
        rc = Transaction:
            ydb_set("^^AAA", @["999"], "tp_rollback", tptoken)
        assert rc == YDB_TP_ROLLBACK

        echo "Nested transaction tests do not work currently with MT, skipping"


    proc testTransactionDSLMT =
        var rc = Transaction:
            Set: ^AAA(101) = fmt"tptoken={tptoken}"
        assert 1 == Data ^AAA(101)

        rc = Transaction:
            Set: ^AAA(101) = fmt"tptoken={tptoken}"
            assert 1 == Data ^AAA(101)
        assert 1 == Data ^AAA(101)            

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            Set: ^AAA(102, dta) = fmt"tptoken={tptoken}"
            assert 10 == Data ^AAA(102) # inside transaction
        assert 1 == Data ^AAA(102, "ABC") # after transaction

        rc = Transaction(4712):
            let dta = $cast[cint](param)
            Set: ^AAA(103, dta) = fmt"tptoken={tptoken}"
        assert 1 == Data ^AAA(102, 4712)

        # Try invalid globalname -> should rollback after 4 tries
        rc = Transaction:
            Set: ^^AAA(999) = fmt"tptoken={tptoken}"
        assert rc == YDB_TP_ROLLBACK

        echo "Nested transaction tests do not work currently with MT, skipping"

    test "transactionAPI": testTransactionAPIMT()
    test "transactionDSL": testTransactionDSLMT()

else:
    proc testSimpleTransaction =
        let rc = Transaction:
            Set: ^x(1) = 1

    proc testTransaction =
        var rc = Transaction:
            ydb_set("^AAA", @["1"], "noparam")
        assert rc == YDB_OK
        assert 1 == Data ^AAA(1)

        rc = Transaction:
            Set: ^AAA(2) = "noparam"
        assert rc == YDB_OK
        assert 1 == Data ^AAA(2)

        rc = Transaction:
            let gbl = "^AAA"
            Set: @gbl(4) = "noparam"
        assert rc == YDB_OK
        assert 1 == Data ^AAA(4)

        rc = Transaction:
            let gbl = "^AAA(5)"
            Set: @gbl = "noparam"
        assert rc == YDB_OK
        assert 1 == Data ^AAA(5)

        rc = Transaction("ABC"):
            let dta = $cast[cstring](param)
            assert dta == "ABC"
            ydb_set("^AAA", @["2", dta], "cstring")
        assert rc == YDB_OK            
        assert 1 == Data ^AAA(2, "ABC")

        rc = Transaction(4712):
            let dta = cast[cint](param)
            assert dta == 4712
            ydb_set("^AAA", @["3", $dta], "cint")
        assert rc == YDB_OK            
        assert 1 == Data ^AAA(3, 4712)

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
        assert 1 == Data ^AAA(4)   
        assert 1 == Data ^AAA(5)

        Kill: ^AAA
        rc = Transaction:
            # Nested transaction with rollback
            var rc2 = Transaction:
                ydb_set("^AAA", @["4"], "noparam")
                return YDB_TP_ROLLBACK
            assert rc2 == YDB_TP_ROLLBACK
            ydb_set("^AAA", @["5"], "noparam")
        assert rc == YDB_OK           
        assert 0 == Data ^AAA(4)   
        assert 1 == Data ^AAA(5)


    test "simple": testSimpleTransaction()
    test "transaction": testTransaction()
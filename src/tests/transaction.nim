import std/[unittest, strformat]
import yottadb

when compileOption("threads"):
    proc testTransactionSetAPI =
        var rc = Transaction:
            ydb_set("^AAA", @["100"], fmt"tptoken={tptoken}", tptoken)
        assert 1 == ydb_data("^AAA", @["100"]) 
        
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


    proc testTransactionSet =
        discard Transaction:
            Set: ^AAA(101) = fmt"tptoken={tptoken}"
        assert 1 == Data ^AAA(101)

    proc testTransactionSetParam =
        discard Transaction("ABC"):
            let dta = $cast[cstring](param)
            Set: ^AAA(102, dta) = fmt"tptoken={tptoken}"
            assert 10 == Data ^AAA(102) # inside transaction
        assert 1 == Data ^AAA(102, "ABC") # after transaction

        discard Transaction(4712):
            let dta = $cast[cint](param)
            Set: ^AAA(103, dta) = fmt"tptoken={tptoken}"
        assert 1 == Data ^AAA(102, 4712)

    proc testTransactionData =
        discard Transaction:
            Set: ^AAA(101) = fmt"tptoken={tptoken}"
            assert 1 == Data ^AAA(101)
        assert 1 == Data ^AAA(101)            

    proc testTransactionRollback =
        # Try invalid globalname -> should rollback after 4 tries
        let rc = Transaction:
            Set: ^^AAA(999) = fmt"tptoken={tptoken}"
        assert rc == YDB_TP_ROLLBACK

        echo "Nested transaction tests do not work currently with MT, skipping"

    proc testTransactionKillnode =
        Set: ^AAA("counter") = 100
        discard Transaction:
            Killnode: ^AAA("counter")
        assert 0 == Data ^AAA("counter")

    proc testTransactionKill =
        Set: ^AAA("counter") = 100
        discard Transaction:
            Kill: ^AAA
        assert 0 == Data ^AAA("counter")

    proc testTransactionIncrement =
        discard Transaction:
            Kill: ^AAA("counter")
            let cnt = Increment ^AAA("counter")
            assert cnt == 1
            Set: ^AAA("data", cnt) = 1
        assert 1 == Get ^AAA("data", 1).int

    proc testTransactionQuery =
        Set:
            ^AAA(1) = 1
            ^AAA(1,1) = "1.1"
            ^AAA(2) = 2
            ^AAA(2,1) = "2.1"
            ^AAA(3) = 3
            ^AAA(3,1) = "3.1"

        echo Query ^AAA
        echo Query ^AAA.reverse
        echo Query ^AAA.keys
        echo Query ^AAA.keys.reverse
        echo Query ^AAA.kv
        echo Query ^AAA.kv.reverse
        echo Query ^AAA.val
        echo Query ^AAA.val.reverse
        echo Query ^AAA.count
        echo Query ^AAA.count.reverse

        discard Transaction:
            echo Query ^AAA
            echo Query ^AAA.reverse
            echo Query ^AAA.keys
            echo Query ^AAA.keys.reverse
            echo Query ^AAA.kv
            echo Query ^AAA.kv.reverse
            echo Query ^AAA.val
            echo Query ^AAA.val.reverse
            echo Query ^AAA.count
            echo Query ^AAA.count.reverse

    proc testTransactionOrder =
        Set:
            ^AAA(1) = 1
            ^AAA(1,1) = "1.1"
            ^AAA(2) = 2
            ^AAA(2,1) = "2.1"
            ^AAA(3) = 3
            ^AAA(3,1) = "3.1"

        var id = Order ^AAA
        while id != "":
            echo "id=", id
            id = Order ^AAA(id)

        echo Order ^AAA.reverse
        echo Order ^AAA.keys
        echo Order ^AAA.keys.reverse
        echo Order ^AAA.kv
        echo Order ^AAA.kv.reverse
        echo Order ^AAA.val
        echo Order ^AAA.val.reverse
        echo Order ^AAA.count
        echo Order ^AAA.count.reverse

        discard Transaction:
            echo "in order Transaction"
            echo Order ^AAA
            echo Order ^AAA.reverse
            echo Order ^AAA.keys
            echo Order ^AAA.keys.reverse
            echo Order ^AAA.kv
            echo Order ^AAA.kv.reverse
            echo Order ^AAA.val
            echo Order ^AAA.val.reverse
            echo Order ^AAA.count
            echo Order ^AAA.count.reverse

            
    test "transactionSetAPI": testTransactionSetAPI()
    test "transactionSet": testTransactionSet()
    test "transactionSetParam": testTransactionSetParam()
    test "transactionData": testTransactionData()
    test "transactionRollback": testTransactionRollback()
    test "transactionKillnode": testTransactionKillnode()
    test "transactionKill": testTransactionKill()
    test "transactionIncrement": testTransactionIncrement()
    test "transactionQuery": testTransactionQuery()
    test "transactionOrder": testTransactionOrder()

else:
    proc testTransactionSet =
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


    proc testTransactionQuery =
        Set:
            ^AAA(1) = 1
            ^AAA(1,1) = "1.1"
            ^AAA(2) = 2
            ^AAA(2,1) = "2.1"
            ^AAA(3) = 3
            ^AAA(3,1) = "3.1"

        echo Query ^AAA
        echo Query ^AAA.reverse
        echo Query ^AAA.keys
        echo Query ^AAA.keys.reverse
        echo Query ^AAA.kv
        echo Query ^AAA.kv.reverse
        echo Query ^AAA.val
        echo Query ^AAA.val.reverse
        echo Query ^AAA.count
        echo Query ^AAA.count.reverse

        discard Transaction:
            echo Query ^AAA
            echo Query ^AAA.reverse
            echo Query ^AAA.keys
            echo Query ^AAA.keys.reverse
            echo Query ^AAA.kv
            echo Query ^AAA.kv.reverse
            echo Query ^AAA.val
            echo Query ^AAA.val.reverse
            echo Query ^AAA.count
            echo Query ^AAA.count.reverse

    proc testTransactionOrder =
        Set:
            ^AAA(1) = 1
            ^AAA(1,1) = "1.1"
            ^AAA(2) = 2
            ^AAA(2,1) = "2.1"
            ^AAA(3) = 3
            ^AAA(3,1) = "3.1"

        echo Query ^AAA
        echo Query ^AAA.reverse
        echo Query ^AAA.keys
        echo Query ^AAA.keys.reverse
        echo Query ^AAA.kv
        echo Query ^AAA.kv.reverse
        echo Query ^AAA.val
        echo Query ^AAA.val.reverse
        echo Query ^AAA.count
        echo Query ^AAA.count.reverse

        discard Transaction:
            echo Query ^AAA
            echo Query ^AAA.reverse
            echo Query ^AAA.keys
            echo Query ^AAA.keys.reverse
            echo Query ^AAA.kv
            echo Query ^AAA.kv.reverse
            echo Query ^AAA.val
            echo Query ^AAA.val.reverse
            echo Query ^AAA.count
            echo Query ^AAA.count.reverse

            
    Kill: ^AAA
    test "transactionSet": testTransactionSet()
    test "transactionQuery": testTransactionQuery()
    test "transactionOrder": testTransactionOrder()
import std/[unittest, strformat]
import yottadb

const qItr = @["^AAA(1)","^AAA(1,1)","^AAA(2)","^AAA(2,1)","^AAA(3)","^AAA(3,1)","^AAA(5)"]
const qItrRv = @["^AAA(5)","^AAA(3,1)","^AAA(3)","^AAA(2,1)","^AAA(2)","^AAA(1,1)","^AAA(1)"]
const qItrKeys = @[ @["1"], @["1", "1"], @["2"], @["2", "1"], @["3"], @["3", "1"], @["5"] ]
const qItrKeysRv = @[ @["5"], @["3", "1"], @["3"], @["2", "1"], @["2"], @["1", "1"], @["1"] ]
const qItrKv = @[("^AAA(1)", "1"),("^AAA(1,1)", "1.1"),("^AAA(2)", "2"),("^AAA(2,1)", "2.1"),("^AAA(3)", "3"),("^AAA(3,1)", "3.1"),("^AAA(5)", "noparam")]
const qItrKvRv = @[("^AAA(5)", "noparam"),("^AAA(3,1)", "3.1"),("^AAA(3)", "3"),("^AAA(2,1)", "2.1"),("^AAA(2)", "2"),("^AAA(1,1)", "1.1"),("^AAA(1)", "1")]
const qItrVal = @["1", "1.1", "2", "2.1", "3", "3.1", "noparam"]
const qItrValRv = @["noparam","3.1","3","2.1","2","1.1","1"]
const qItrCount = @["7"]
const qItrCountRv = @["7"]

const oItr = @["1","2","3","5"]
const oItrRv = @["5","3","2","1"]
const oItrKey = @["^AAA(1)","^AAA(2)","^AAA(3)","^AAA(5)"]
const oItrKeyRv = @["^AAA(5)","^AAA(3)","^AAA(2)","^AAA(1)"]
const oItrKeys = @[ @["1"], @["2"], @["3"], @["5"] ]
const oItrKeysRv = @[ @["5"], @["3"], @["2"], @["1"] ]
const oItrKv = @[("1", "1"),("2", "2"),("3", "3"),("5", "noparam")]
const oItrKvRv = @[("5", "noparam"),("3", "3"),("2", "2"),("1", "1")]
const oItrVal = @["1","2","3","noparam"]
const oItrValRv = @["noparam","3","2","1"]
const oItrCount = @["4"]
const oItrCountRv = @["4"]

proc init() =
    Kill: ^AAA
    Set:
        ^AAA(1) = 1
        ^AAA(1,1) = "1.1"
        ^AAA(2) = 2
        ^AAA(2,1) = "2.1"
        ^AAA(3) = 3
        ^AAA(3,1) = "3.1"
        ^AAA(5) = "noparam"

proc testQueryIterators =
    var strdata: seq[string]
    var seqdata: seq[seq[string]]
    var tupdata: seq[(string, string)]
    echo "- QueryItr"
    for id in QueryItr ^AAA:
        strdata.add(id)
    assert strdata == qItr
    echo "- QueryItr.reverse"
    strdata.setLen(0)
    for id in QueryItr ^AAA.reverse:
        strdata.add(id)
    assert strdata == qItrRv            
    echo "- QueryItr.keys"
    seqdata.setLen(0)
    for id in QueryItr ^AAA.keys:
        seqdata.add(id)
    assert seqdata == qItrKeys
    echo "- QueryItr.keys.reverse"
    seqdata.setLen(0)
    for id in QueryItr ^AAA.keys.reverse:
        seqdata.add(id)
    assert seqdata == qItrKeysRv
    echo "- QueryItr.kv"
    tupdata.setLen(0)
    for (k, v) in QueryItr ^AAA.kv:
        tupdata.add((k,v))
    assert tupdata == qItrKv
    echo "- QueryItr.kv.reverse"
    tupdata.setLen(0)
    for (k, v) in QueryItr ^AAA.kv.reverse:
        tupdata.add((k,v))
    assert tupdata == qItrKvRv
    echo "- QueryItr.val"
    strdata.setLen(0)
    for val in QueryItr ^AAA.val:
        strdata.add(val)
    assert strdata == qItrVal
    echo "- QueryItr.val.reverse"
    strdata.setLen(0)
    for val in QueryItr ^AAA.val.reverse:
        strdata.add(val)
    assert strdata == qItrValRv
    echo "- QueryItr.count"
    strdata.setLen(0)
    for val in QueryItr ^AAA.count:
        strdata.add($val)
    assert strdata == qItrCount
    echo "- QueryItr.count.reverse"
    strdata.setLen(0)
    for val in QueryItr ^AAA.count.reverse:
        strdata.add($val)
    assert strdata == qItrCountRv


proc testOrderIterators =
    var strdata: seq[string]
    var seqdata: seq[seq[string]]
    var tupdata: seq[(string, string)]
    echo "- OrderItr"
    strdata.setLen(0)
    for id in OrderItr ^AAA:
        strdata.add(id)
    assert strdata == oItr
    echo "- OrderItr.reverse"
    strdata.setLen(0)
    for id in OrderItr ^AAA.reverse:
        strdata.add(id)
    assert strdata == oItrRv
    echo "- OrderItr.key"
    strdata.setLen(0)
    for id in OrderItr ^AAA.key:
        strdata.add(id)
    assert strdata == oItrKey
    echo "- OrderItr.key.reverse"
    strdata.setLen(0)
    for id in OrderItr ^AAA.key.reverse:
        strdata.add(id)
    assert strdata == oItrKeyRv
    echo "- OrderItr.keys"
    seqdata.setLen(0)
    for keys in OrderItr ^AAA.keys:
        seqdata.add(keys)
    assert seqdata == oItrKeys
    echo "- OrderItr.keys.reverse"
    seqdata.setLen(0)
    for keys in OrderItr ^AAA.keys.reverse:
        seqdata.add(keys)
    assert seqdata == oItrKeysRv
    echo "- OrderItr.kv"
    tupdata.setLen(0)
    for (k, v) in OrderItr ^AAA.kv:
        tupdata.add((k,v))
    assert tupdata == oItrKv
    echo "- OrderItr.kv.reverse"
    tupdata.setLen(0)
    for (k, v) in OrderItr ^AAA.kv.reverse:
        tupdata.add((k,v))
    assert tupdata == oItrKvRv
    echo "- OrderItr.val"
    strdata.setLen(0)
    for val in OrderItr ^AAA.val:
        strdata.add(val)
    assert strdata == oItrVal
    echo "- OrderItr.val.reverse"
    strdata.setLen(0)
    for val in OrderItr ^AAA.val.reverse:
        strdata.add(val)
    assert strdata == oItrValRv
    echo "- OrderItr.count"
    strdata.setLen(0)
    for val in OrderItr ^AAA.count:
        strdata.add($val)
    assert strdata == oItrCount
    echo "- OrderItr.count.reverse"
    strdata.setLen(0)
    for val in OrderItr ^AAA.count.reverse:
        strdata.add($val)
    assert strdata == oItrCountRv


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
        Kill: ^AAA("counter")
        let cnt = Increment ^AAA("counter")
        assert cnt == 1

        discard Transaction:
            Kill: ^AAA("counter")
            let cnt = Increment ^AAA("counter")
            assert cnt == 1
            Set: ^AAA("data", cnt) = 1
        assert 1 == Get ^AAA("data", 1).int

    proc testTransactionQuery =
        init()

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


    proc testTransactionQueryItr =
        # Test Iterators OUTSIDE the Transaction scope when --threads:on
        # tptoken=0
        init()
        testQueryIterators()

    proc testTransactionOrderItr =
        # Test Iterators OUTSIDE the Transaction scope when --threads:on
        # tptoken=0
        init()
        testOrderIterators()

    proc testTransactionQueryItrMT =
        # IMPORTANT! YOU MAY NOT CALL testQueryIterators() from inside the Transaction
        # when compiled with --threads:on
        # If a proc is used without Transaction, the process will hang
        # tptoken will be set from YottaDB in the callback to the Transaction 
        discard Transaction:
            var strdata: seq[string]
            var seqdata: seq[seq[string]]
            var tupdata: seq[(string, string)]
            echo "- QueryItr"
            for id in QueryItr ^AAA:
                strdata.add(id)
            assert strdata == qItr
            echo "- QueryItr.reverse"
            strdata.setLen(0)
            for id in QueryItr ^AAA.reverse:
                strdata.add(id)
            assert strdata == qItrRv            
            echo "- QueryItr.keys"
            seqdata.setLen(0)
            for id in QueryItr ^AAA.keys:
                seqdata.add(id)
            assert seqdata == qItrKeys
            echo "- QueryItr.keys.reverse"
            seqdata.setLen(0)
            for id in QueryItr ^AAA.keys.reverse:
                seqdata.add(id)
            assert seqdata == qItrKeysRv
            echo "- QueryItr.kv"
            tupdata.setLen(0)
            for (k, v) in QueryItr ^AAA.kv:
                tupdata.add((k,v))
            assert tupdata == qItrKv
            echo "- QueryItr.kv.reverse"
            tupdata.setLen(0)
            for (k, v) in QueryItr ^AAA.kv.reverse:
                tupdata.add((k,v))
            assert tupdata == qItrKvRv
            echo "- QueryItr.val"
            strdata.setLen(0)
            for val in QueryItr ^AAA.val:
                strdata.add(val)
            assert strdata == qItrVal
            echo "- QueryItr.val.reverse"
            strdata.setLen(0)
            for val in QueryItr ^AAA.val.reverse:
                strdata.add(val)
            assert strdata == qItrValRv
            echo "- QueryItr.count"
            strdata.setLen(0)
            for val in QueryItr ^AAA.count:
                strdata.add($val)
            assert strdata == qItrCount
            echo "- QueryItr.count.reverse"
            strdata.setLen(0)
            for val in QueryItr ^AAA.count.reverse:
                strdata.add($val)
            assert strdata == qItrCountRv


    proc testTransactionOrderItrMT =
        discard Transaction:
            var strdata: seq[string]
            var seqdata: seq[seq[string]]
            var tupdata: seq[(string, string)]
            echo "- OrderItr"
            strdata.setLen(0)
            for id in OrderItr ^AAA:
                strdata.add(id)
            assert strdata == oItr

            echo "- OrderItr.reverse"
            strdata.setLen(0)
            for id in OrderItr ^AAA.reverse:
                strdata.add(id)
            assert strdata == oItrRv
            echo "- OrderItr.key"
            strdata.setLen(0)
            for id in OrderItr ^AAA.key:
                strdata.add(id)
            assert strdata == oItrKey
            echo "- OrderItr.key.reverse"
            strdata.setLen(0)
            for id in OrderItr ^AAA.key.reverse:
                strdata.add(id)
            assert strdata == oItrKeyRv
            echo "- OrderItr.keys"
            seqdata.setLen(0)
            for keys in OrderItr ^AAA.keys:
                seqdata.add(keys)
            assert seqdata == oItrKeys
            echo "- OrderItr.keys.reverse"
            seqdata.setLen(0)
            for keys in OrderItr ^AAA.keys.reverse:
                seqdata.add(keys)
            assert seqdata == oItrKeysRv
            echo "- OrderItr.kv"
            tupdata.setLen(0)
            for (k, v) in OrderItr ^AAA.kv:
                tupdata.add((k,v))
            assert tupdata == oItrKv
            echo "- OrderItr.kv.reverse"
            tupdata.setLen(0)
            for (k, v) in OrderItr ^AAA.kv.reverse:
                tupdata.add((k,v))
            assert tupdata == oItrKvRv
            echo "- OrderItr.val"
            strdata.setLen(0)
            for val in OrderItr ^AAA.val:
                strdata.add(val)
            assert strdata == oItrVal
            echo "- OrderItr.val.reverse"
            strdata.setLen(0)
            for val in OrderItr ^AAA.val.reverse:
                strdata.add(val)
            assert strdata == oItrValRv
            echo "- OrderItr.count"
            strdata.setLen(0)
            for val in OrderItr ^AAA.count:
                strdata.add($val)
            assert strdata == oItrCount
            echo "- OrderItr.count.reverse"
            strdata.setLen(0)
            for val in OrderItr ^AAA.count.reverse:
                strdata.add($val)
            assert strdata == oItrCountRv



    proc testTransactionOrder =
        init()

        var id = Order ^AAA
        while id != "":
            echo "id=", id
            id = Order ^AAA(id)

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
    test "transactionQueryItr": testTransactionQueryItr()
    test "transactionQueryItrMT": testTransactionQueryItrMT()
    test "transactionOrderItr": testTransactionOrderItr()
    test "transactionOrderItrMT": testTransactionOrderItrMT()


else:
    proc testTransactionSet =
        Kill: ^AAA

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
        init()

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
        init()

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

            
    test "transactionSet": testTransactionSet()
    test "transactionQuery": testTransactionQuery()
    test "transactionOrder": testTransactionOrder()
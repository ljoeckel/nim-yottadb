import std/strutils
import std/sets
import std/unittest
import yottadb
import ydbutils


const 
    BENCH_MAX_RECS = 1_000_000


proc testGlobals() =
    setvar: ^GBL="gbl"
    assert "gbl" == getvar ^GBL
    setvar: ^GBL(1)="gbl(1)"
    assert "gbl(1)" == getvar ^GBL(1)
    setvar: 
        ^GBL = "gbl"
        ^GBL(4711) = "4711"
        ^GBL("4711", "ABC") = "4711,ABC"
    assert "gbl" == getvar ^GBL 
    assert "4711" == getvar ^GBL(4711)
    assert "4711,ABC" == getvar ^GBL("4711", "ABC")

    let id = "abc"
    setvar: ^GBL(id) = "abc"
    assert "abc" == getvar ^GBL(id)
    setvar: ^GBL($id) = "abc"
    assert "abc" == getvar ^GBL($id)

    let (a,b) = (getvar ^GBL(1), getvar ^GBL(4711))
    assert a == "gbl(1)" and b == "4711"


proc testGetWithType() =
    setvar: ^GBL = int.high
    setvar: ^GBL("int") = int.high
    setvar: ^GBL("int8") = int8.high
    setvar: ^GBL("int16") = int16.high
    setvar: ^GBL("int32") = int32.high
    setvar: ^GBL("int64") = int64.high
    setvar: ^GBL("uint") = uint.high
    setvar: ^GBL("uint8") = uint8.high
    setvar: ^GBL("uint16") = uint16.high
    setvar: ^GBL("uint32") = uint32.high
    setvar: ^GBL("uint64") = uint64.high
    setvar: ^GBL("float") = 3.1414
    setvar: ^GBL("float32") = 3.1414

    assert int.high == getvar ^GBL.int
    assert int.high == getvar ^GBL("int").int
    assert int8.high == getvar ^GBL("int8").int8
    assert int16.high == getvar ^GBL("int16").int16
    assert int32.high == getvar ^GBL("int32").int32
    assert int64.high == getvar ^GBL("int64").int64
    assert uint.high == getvar ^GBL("uint").uint
    assert uint8.high == getvar ^GBL("uint8").uint8
    assert uint16.high == getvar ^GBL("uint16").uint16
    assert uint32.high == getvar ^GBL("uint32").uint32
    assert uint64.high == getvar ^GBL("uint64").uint64
    assert 3.1414 == getvar ^GBL("float").float
    assert 3.1414.float32 == getvar ^GBL("float32").float32
    
    let os = toOrderedSet([1,2,3,4,5,6,7,8,9,10])
    let gbl = "^GBL(\"os\")"
    setvar: @gbl = $os
    let osdb = getvar @gbl.OrderedSet
    assert os == osdb


proc benchTestGlobals() =
    kill: ^GBL

    var rc = 0

    timed:
        echo "setvar ^GBL(i)"
        for i in 0..BENCH_MAX_RECS:
            setvar: ^GBL(i) = i
    timed:
        echo "getvar ^GBL(i)"
        var sum1, sum2 = 0
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += getvar ^GBL(i).int
        assert sum1 == sum2
    timed:
        echo "ydb_set ^GBL(@[i])"
        for i in 0..BENCH_MAX_RECS:
            ydb_set("^GBL", @[$i], $i)
    timed:
        sum1 = 0
        sum2 = 0
        echo "ydb_getvar ^GBL(@[i])"
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += parseInt(ydb_get("^GBL", @[$i]))
        assert sum1 == sum2
    timed:
        echo "nextnode @gbl Indirection"
        var gbl = "^GBL"
        while gbl != "":
            (rc, gbl) = nextnode @gbl
    timed:
        echo "killnode: nodes"
        for i in 0..BENCH_MAX_RECS:
            killnode: ^GBL(i)


proc benchTestLocals() =
    kill: LCL
    var rc = 0

    timed:
        echo "setvar LCL(i)"
        for i in 0..BENCH_MAX_RECS:
            setvar: LCL(i) = i
    timed:
        echo "getvar LCL(i)"
        var sum1, sum2 = 0
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += getvar LCL(i).int
        assert sum1 == sum2
    timed:
        echo "ydb_set LCL(i)"
        for i in 0..BENCH_MAX_RECS:
            ydb_set("LCL", @[$i], $i)
    timed:
        sum1 = 0
        sum2 = 0
        echo "ydb_get LCL(i)"
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += parseInt(ydb_get("LCL", @[$i]))
        assert sum1 == sum2
    timed:
        echo "nextnode dsl"
        var gbl = "LCL"
        while gbl != "":
            (rc, gbl) = nextnode @gbl
    timed:
        echo "Delete nodes"
        for i in 0..BENCH_MAX_RECS:
            killnode: LCL(i)
        
        gbl = "LCL"
        while gbl != "":
            (rc, gbl) = nextnode @gbl
        assert rc == YDB_ERR_NODEEND
        assert gbl == ""


proc testDeleteNode() =
    setvar: ^GBL="hallo"
    killnode: ^GBL
    assert "" == getvar ^GBL

    let gbl = "^GBL(1)"
    setvar: @gbl = "gbl(1)"
    killnode: @gbl
    assert "" == getvar @gbl

    setvar: ^GBL1="hallo"
    assert "hallo" == getvar ^GBL1
    killnode: ^GBL1
    assert "" == getvar ^GBL1

    setvar:
        ^GBL1="gbl1"
        ^GBL2="gbl2"
        ^GBL3="gbl3"
    killnode:
        ^GBL1
        ^GBL2
        ^GBL3
    assert "" == getvar ^GBL1
    assert "" == getvar ^GBL2
    assert "" == getvar ^GBL3

    setvar:
        ^GBL(1)=1
        ^GBL(2)=2
        ^GBL(3)=3
    killnode:
        ^GBL(1)
        ^GBL(2)
        ^GBL(3)
    assert "" == getvar ^GBL(1)
    assert "" == getvar ^GBL(2)
    assert "" == getvar ^GBL(3)


proc testDeleteTree() =
    setvar: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        
    kill: ^GBL(1)
    assert "" == getvar ^GBL(1,1)
    assert "" == getvar ^GBL(1,2)
    kill: ^GBL(2)
    assert "" == getvar ^GBL(2,1)
    assert "" == getvar ^GBL(2,2)
    kill: ^GBL
    assert "" == getvar ^GBL

    var
        rc = 0
        gbl = "^GBL"
    (rc, gbl) = nextnode @gbl
    assert gbl == ""


proc testData() =
    kill: ^GBL
    setvar: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        ^GBL(3,3)="3,3"
        ^GBL(5,1) = "5,1"
        ^GBL(6)="6"

    assert YDB_DATA_UNDEF == data ^GBLX
    assert YDB_DATA_VALUE_DESC == data ^GBL
    assert YDB_DATA_NOVALUE_DESC == data ^GBL(5) 
    assert YDB_DATA_VALUE_NODESC == data ^GBL(6)

proc testDelexcl() =
  # Global's / Special / Invalid names are not allowed
  doAssertRaises(YdbError): delexcl: ^SOMEGLOBAL
  doAssertRaises(YdbError): delexcl: $SOMEGLOBAL
  doAssertRaises(YdbError): delexcl: $ZVERSION
  doAssertRaises(YdbError): delexcl: {
     ^SOMEGLOBAL,
     $SOMEGLOBAL,
     $ZVERSION
  }
  
  # Set local variables
  setvar:
    DELTEST0("deltest")="deltest"
    DELTEST1="1"
    DELTEST2="2"
    DELTEST3="3"
    DELTEST4="4"
    DELTEST5="5"

  # Test if local variable is readable
  discard getvar DELTEST0("deltest")
  discard getvar DELTEST1
  
  # Remove all except the following
  delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard getvar DELTEST1
  discard getvar DELTEST3
  discard getvar DELTEST5

  # Removed vars should raise exception on access
  doAssertRaises(YdbError): discard getvar DELTEST2
  doAssertRaises(YdbError): discard getvar DELTEST4

  # delete all variables
  delexcl: {}
  doAssertRaises(YdbError): discard getvar DELTEST1


proc testIncrement() =
    setvar: ^CNT = 0
    var value = increment: ^CNT
    assert 1 == value
    value = increment: (^CNT, by=10)
    assert 11 == value

    setvar: ^CNT("txid") = 0
    value = increment: ^CNT("txid")
    assert 1 == value
    value = increment: (^CNT("txid"), by=10)
    assert 11 == value

    let id = "custid"
    setvar: ^CNT(id) = 0
    value = increment: ^CNT(id)
    assert 1 == value
    value = increment: (^CNT(id), by=10)
    assert 11 == value

    let gbl = "^CNT(123)"
    setvar: @gbl = 0
    value = increment: @gbl
    assert 1 == value
    value = increment: (@gbl, by=10)
    assert 11 == value


proc testLock() =
    lock:
        ^XXX
        ^GBL(2)
        ^GBL(2,3)
        ^GBL(2,3,"abc")
        timeout = 0.002
    assert getLockCountFromYottaDb() == 4

    let gbl = "^GBL(2)"
    lock: @gbl
    assert getLockCountFromYottaDb() == 1

    lock: {@gbl}
    assert getLockCountFromYottaDb() == 1

    lock: { ^XXX, ^GBL(2), ^GBL(2,3), ^GBL(2,3,"abc"), timeout = 0.002}
    assert getLockCountFromYottaDb() == 4

    lock: {}
    assert getLockCountFromYottaDb() == 0

    lock: {@gbl}
    assert getLockCountFromYottaDb() == 1
    lock:
        discard 
    assert getLockCountFromYottaDb() == 0


proc testLockIncrement() =
    lock: ^GBL(4711)
    assert getLockCountFromYottaDb() == 1
    lock: +^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 lock.count = 1
    lock: +^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 lock.count = 2
    lock: -^GBL(4712)
    assert getLockCountFromYottaDb() == 2 # 4712 lock.count = 1
    lock: -^GBL(4712)
    assert getLockCountFromYottaDb() == 1 # 4712 removed
    lock: {}
    assert getLockCountFromYottaDb() == 0


proc testNextNode() =
    var 
        rc = 0
        gbl = ""

    kill: ^GBL
    setvar:
        ^GBL="GBL"
        ^GBL(1)=1
        ^GBL(1,"a")="1a"
        ^GBL(1,1)="1,1"
        ^GBL(1,1,"A")="1,1,A"
        ^GBL(1,1,"B")="1,1,B"
        ^GBL(2,1)="2,1"
        ^GBL(2,1,"A")="2,1,A"
        ^GBL(3,1,"A")="3,1,A"
        ^GBL(3,1,"B")="3,1,B"

    let refdata = @["^GBL", "^GBL(1)", "^GBL(1,1)", "^GBL(1,1,A)", "^GBL(1,1,B)", "^GBL(1,a)", "^GBL(2,1)", "^GBL(2,1,A)", "^GBL(3,1,A)", "^GBL(3,1,B)"]
    var dbdata: seq[string]

    gbl = "^GBL"
    while gbl != "":
        dbdata.add(gbl)
        (rc, gbl) = nextnode @gbl
    assert rc == YDB_ERR_NODEEND
    assert refdata == dbdata

    setvar:
        LCL="GBL"
        LCL(1)=1
        LCL(1,"a")="1a"
        LCL(1,1)="1,1"
        LCL(1,1,"A")="1,1,A"
        LCL(1,1,"B")="1,1,B"
        LCL(2,1)="2,1"
        LCL(2,1,"A")="2,1,A"
        LCL(3,1,"A")="3,1,A"
        LCL(3,1,"B")="3,1,B"

    let refdataL = @["LCL", "LCL(1)", "LCL(1,1)", "LCL(1,1,A)", "LCL(1,1,B)", "LCL(1,a)", "LCL(2,1)", "LCL(2,1,A)", "LCL(3,1,A)", "LCL(3,1,B)"]
    var dbdataL: seq[string]

    gbl = "LCL"
    while gbl != "":
        dbdataL.add(gbl)
        (rc, gbl) = nextnode @gbl
    assert rc == YDB_ERR_NODEEND
    assert gbl == ""
    assert refdataL == dbdataL


proc testPreviousNode() =
    var 
        rc = 0
        gbl = ""

    kill: ^GBL
    setvar:
        ^GBL="GBL"
        ^GBL(1)=1
        ^GBL(1,"a")="1a"
        ^GBL(1,1)="1,1"
        ^GBL(1,1,"A")="1,1,A"
        ^GBL(1,1,"B")="1,1,B"
        ^GBL(2,1)="2,1"
        ^GBL(2,1,"A")="2,1,A"
        ^GBL(3,1,"A")="3,1,A"
        ^GBL(3,1,"B")="3,1,B"

    let refdata = @["^GBL(3,1,B)","^GBL(3,1,A)","^GBL(2,1,A)","^GBL(2,1)","^GBL(1,a)","^GBL(1,1,B)","^GBL(1,1,A)","^GBL(1,1)","^GBL(1)"]
    var dbdata: seq[string]

    gbl = "^GBL"
    while gbl != "":
        (rc, gbl) = prevnode @gbl
        if rc == YDB_OK:
            dbdata.add(gbl)

    assert rc == YDB_ERR_NODEEND
    assert refdata == dbdata

    setvar:
        LCL="GBL"
        LCL(1)=1
        LCL(1,"a")="1a"
        LCL(1,1)="1,1"
        LCL(1,1,"A")="1,1,A"
        LCL(1,1,"B")="1,1,B"
        LCL(2,1)="2,1"
        LCL(2,1,"A")="2,1,A"
        LCL(3,1,"A")="3,1,A"
        LCL(3,1,"B")="3,1,B"
    
    let refdataL = @["LCL(3,1,B)","LCL(3,1,A)","LCL(2,1,A)","LCL(2,1)","LCL(1,a)","LCL(1,1,B)","LCL(1,1,A)","LCL(1,1)","LCL(1)"]
    var dbdataL: seq[string]

    gbl = "LCL"
    while gbl != "":
        (rc, gbl) = prevnode @gbl
        if rc == YDB_OK:
            dbdataL.add(gbl)

    assert rc == YDB_ERR_NODEEND
    assert gbl == ""
    assert refdataL == dbdataL

proc testNextSubscript() =
    kill: ^GBL
    setvar:
        ^GBL="GBL"
        ^GBL(1)=1
        ^GBL(1,"a")="1a"
        ^GBL(1,1)="1,1"
        ^GBL(1,1,"A")="1,1,A"
        ^GBL(1,1,"B")="1,1,B"
        ^GBL(2,1)="2,1"
        ^GBL(2,1,"A")="2,1,A"
        ^GBL(3,1,"A")="3,1,A"
        ^GBL(3,1,"B")="3,1,B"
    
    var gbl = "^GBL"
    var rc = YDB_OK
    var refdata = @["^GBL(1)","^GBL(2)", "^GBL(3)"]
    var dbdata: seq[string]
    while rc == YDB_OK:
        (rc, gbl) = nextsubscript @gbl
        if rc == YDB_OK:
            dbdata.add(gbl)
    assert dbdata == refdata

    gbl = "^GBL(1,1,)"
    rc = YDB_OK
    refdata = @["^GBL(1,1,A)", "^GBL(1,1,B)"]
    dbdata = @[]
    while rc == YDB_OK:
        (rc, gbl) = nextsubscript @gbl
        if rc == YDB_OK:
            dbdata.add(gbl)
    assert dbdata == refdata

proc testPrevSubscript() =
    kill: ^GBL
    setvar:
        ^GBL="GBL"
        ^GBL(1)=1
        ^GBL(1,"a")="1a"
        ^GBL(1,1)="1,1"
        ^GBL(1,1,"A")="1,1,A"
        ^GBL(1,1,"B")="1,1,B"
        ^GBL(2,1)="2,1"
        ^GBL(2,1,"A")="2,1,A"
        ^GBL(3,1,"A")="3,1,A"
        ^GBL(3,1,"B")="3,1,B"
    
    var gbl = "^GBL"
    var rc = YDB_OK
    var refdata = @["^GBL(3)","^GBL(2)", "^GBL(1)"]
    var dbdata: seq[string]
    while rc == YDB_OK:
        (rc, gbl) = prevsubscript @gbl
        if rc == YDB_OK:
            dbdata.add(gbl)
    assert dbdata == refdata

    gbl = "^GBL(1,1,)"
    rc = YDB_OK
    refdata = @["^GBL(1,1,B)", "^GBL(1,1,A)"]
    dbdata = @[]
    while rc == YDB_OK:
        (rc, gbl) = prevsubscript @gbl
        if rc == YDB_OK:
            dbdata.add(gbl)
    assert dbdata == refdata

if isMainModule:
    test "Globals": testGlobals()
    test "Data": testData()
    test "GetWithType": testGetWithType()
    test "DeleteNode": testDeleteNode()
    test "DeleteTree": testDeleteTree()
    test "DeleteExclusive": testDelexcl()
    test "Increment": testIncrement()
    test "Lock": testLock()
    test "Lock Increment": testLockIncrement()
    test "NextNode": testNextNode()
    test "PrevNode": testPreviousNode()
    test "NextSubscript": testNextSubscript()
    test "PrevSubscript": testPrevSubscript()
    test "Bench Globals": benchTestGlobals()
    test "Bench Locals": benchTestLocals()
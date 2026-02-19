import std/strutils
import std/sets
import std/unittest
import yottadb
import ydbutils


const 
    BENCH_MAX_RECS = 1_000_000


proc testGlobals() =
    Set: ^GBL="gbl"
    assert "gbl" == Get ^GBL
    Set: ^GBL(1)="gbl(1)"
    assert "gbl(1)" == Get ^GBL(1)
    Set: 
        ^GBL = "gbl"
        ^GBL(4711) = "4711"
        ^GBL("4711", "ABC") = "4711,ABC"
    assert "gbl" == Get ^GBL 
    assert "4711" == Get ^GBL(4711)
    assert "4711,ABC" == Get ^GBL("4711", "ABC")

    let id = "abc"
    Set: ^GBL(id) = "abc"
    assert "abc" == Get ^GBL(id)
    Set: ^GBL($id) = "abc"
    assert "abc" == Get ^GBL($id)

    let (a,b) = (Get ^GBL(1), Get ^GBL(4711))
    assert a == "gbl(1)" and b == "4711"


proc testGetWithType() =
    Set: ^GBL = int.high
    Set: ^GBL("int") = int.high
    Set: ^GBL("int8") = int8.high
    Set: ^GBL("int16") = int16.high
    Set: ^GBL("int32") = int32.high
    Set: ^GBL("int64") = int64.high
    Set: ^GBL("uint") = uint.high
    Set: ^GBL("uint8") = uint8.high
    Set: ^GBL("uint16") = uint16.high
    Set: ^GBL("uint32") = uint32.high
    Set: ^GBL("uint64") = uint64.high
    Set: ^GBL("float") = 3.1414
    Set: ^GBL("float32") = 3.1414
    Set: ^GBL("float64") = 3.1414

    assert int.high == Get ^GBL.int
    assert int.high == Get ^GBL("int").int
    assert int8.high == Get ^GBL("int8").int8
    assert int16.high == Get ^GBL("int16").int16
    assert int32.high == Get ^GBL("int32").int32
    assert int64.high == Get ^GBL("int64").int64
    assert uint.high == Get ^GBL("uint").uint
    assert uint8.high == Get ^GBL("uint8").uint8
    assert uint16.high == Get ^GBL("uint16").uint16
    assert uint32.high == Get ^GBL("uint32").uint32
    assert uint64.high == Get ^GBL("uint64").uint64
    assert 3.1414 == Get ^GBL("float").float
    #assert 3.1414.float32 == Get ^GBL("float32").float32    #TODO: float32 cast gives strange result
    assert 3.1414.float64 == Get ^GBL("float64").float64
    
    let os = toOrderedSet([1,2,3,4,5,6,7,8,9,10])
    let gbl = "^GBL(\"os\")"
    Set: @gbl = $os
    let osdb = Get @gbl.OrderedSet
    assert os == osdb


proc benchTestGlobals() =
    Kill: ^GBL

    var rc = 0

    timed:
        echo "setvar ^GBL(i)"
        for i in 0..BENCH_MAX_RECS:
            Set: ^GBL(i) = i
    timed:
        echo "Get ^GBL(i)"
        var sum1, sum2 = 0
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += Get ^GBL(i).int
        assert sum1 == sum2
    timed:
        echo "ydb_set ^GBL(@[i])"
        for i in 0..BENCH_MAX_RECS:
            ydb_set("^GBL", @[$i], $i)
    timed:
        sum1 = 0
        sum2 = 0
        echo "ydb_Get ^GBL(@[i])"
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += parseInt(ydb_get("^GBL", @[$i]))
        assert sum1 == sum2
    timed:
        echo "Query @gbl Indirection"
        var gblname = "^GBL"
        for gbl in QueryItr @gblname:
            assert gbl.len > 0
    timed:
        echo "Killnode: nodes"
        for i in 0..BENCH_MAX_RECS:
            Killnode: ^GBL(i)


proc benchTestLocals() =
    Kill: LCL
    var rc = 0

    timed:
        echo "setvar LCL(i)"
        for i in 0..BENCH_MAX_RECS:
            Set: LCL(i) = i
    timed:
        echo "Get LCL(i)"
        var sum1, sum2 = 0
        for i in 0..BENCH_MAX_RECS:
            sum1 += i
            sum2 += Get LCL(i).int
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
        echo "Query dsl"
        var gblname = "LCL"
        for gbl in QueryItr @gblname:
            assert gbl.len > 0
    timed:
        echo "Delete nodes"
        for i in 0..BENCH_MAX_RECS:
            Killnode: LCL(i)
        
        gblname = "LCL"
        for gbl in QueryItr @gblname:
            assert gbl.len > 0


proc testDelexcl() =
  # Global's / Special / Invalid names are not allowed
  doAssertRaises(YdbError): Delexcl: ^SOMEGLOBAL
  doAssertRaises(YdbError): Delexcl: $SOMEGLOBAL
  doAssertRaises(YdbError): Delexcl: $ZVERSION
  doAssertRaises(YdbError): Delexcl: {
     ^SOMEGLOBAL,
     $SOMEGLOBAL,
     $ZVERSION
  }
  
  # Set local variables
  Set:
    DELTEST0("deltest")="deltest"
    DELTEST1="1"
    DELTEST2="2"
    DELTEST3="3"
    DELTEST4="4"
    DELTEST5="5"

  # Test if local variable is readable
  discard Get DELTEST0("deltest")
  discard Get DELTEST1
  
  # Remove all except the following
  Delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard Get DELTEST1
  discard Get DELTEST3
  discard Get DELTEST5

  # Removed vars should raise exception on access
  doAssertRaises(YdbError): discard Get DELTEST2
  doAssertRaises(YdbError): discard Get DELTEST4

  # delete all variables
  Delexcl: {}
  doAssertRaises(YdbError): discard Get DELTEST1

proc testNextNode() =
    var 
        rc = 0
        gbl = ""

    Kill: ^GBL
    Set:
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

    let refdata = @["^GBL(1)", "^GBL(1,1)", "^GBL(1,1,A)", "^GBL(1,1,B)", "^GBL(1,a)", "^GBL(2,1)", "^GBL(2,1,A)", "^GBL(3,1,A)", "^GBL(3,1,B)"]
    var dbdata: seq[string]

    var gblname = "^GBL"
    for gbl in QueryItr @gblname:
        dbdata.add(gbl)
    assert refdata == dbdata

    Set:
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

    let refdataL = @["LCL(1)", "LCL(1,1)", "LCL(1,1,A)", "LCL(1,1,B)", "LCL(1,a)", "LCL(2,1)", "LCL(2,1,A)", "LCL(3,1,A)", "LCL(3,1,B)"]
    var dbdataL: seq[string]

    gblname = "LCL"
    for gbl in QueryItr @gblname:
        dbdataL.add(gbl)
    assert refdataL == dbdataL


proc testPreviousNode() =
    var 
        rc = 0
        gbl = ""

    Kill: ^GBL
    Set:
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

    for k in QueryItr ^GBL.reverse:
        dbdata.add(k)
    assert refdata == dbdata

    Set:
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
    for key in QueryItr LCL.reverse:
        dbdataL.add(key)
    assert gbl == ""
    assert refdataL == dbdataL

proc testNextSubscript() =
    Kill: ^GBL
    Set:
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
    var refdata = @["^GBL(1)","^GBL(2)", "^GBL(3)"]
    var dbdata: seq[string]
    for gbl in OrderItr @gbl.key:
        dbdata.add(gbl)
    assert dbdata == refdata

    gbl = "^GBL(1,1,)"
    refdata = @["A", "B"]
    dbdata = @[]
    for gbl in OrderItr @gbl:
        dbdata.add(gbl)
    assert dbdata == refdata

proc testPrevSubscript() =
    Kill: ^GBL
    Set:
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
    var refdata = @["3","2", "1"]
    var dbdata: seq[string]
    for gbl in OrderItr @gbl.reverse:
        dbdata.add(gbl)
    assert dbdata == refdata

    gbl = "^GBL(1,1,)"
    refdata = @["B", "A"]
    dbdata = @[]
    for gbl in OrderItr @gbl.reverse:
        dbdata.add(gbl)
    assert dbdata == refdata

if isMainModule:
    test "Globals": testGlobals()
    test "GetWithType": testGetWithType()
    test "DeleteExclusive": testDelexcl()
    test "NextNode": testNextNode()
    test "PrevNode": testPreviousNode()
    test "NextSubscript": testNextSubscript()
    test "PrevSubscript": testPrevSubscript()
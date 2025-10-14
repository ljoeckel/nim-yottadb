import macros
import std/strutils
import std/strformat
import std/sets
import std/unittest
import ydbdsl
import libs/ydbapi
import libs/ydbtypes
import utils
when compileOption("profiler"):
  import std/nimprof


proc testLocals() =
    setvar: LOCAL = "a single local"
    assert "a single local" == get LOCAL

    setvar:
        LOCAL = "Hallo"
        LOCAL(4711) = "Hello 4711"
        LOCAL("4711", "ABC") = "Hello from 4711,ABC"
    assert "Hallo" == get LOCAL
    assert "Hello 4711" == get LOCAL(4711)
    assert "Hello from 4711,ABC" == get LOCAL("4711", "ABC")

    let (a, b) = (get LOCAL, get LOCAL(4711))
    assert a == "Hallo" and b == "Hello 4711"


proc testGlobals() =
    setvar: ^GBL="gbl"
    assert "gbl" == get ^GBL
    setvar: ^GBL(1)="gbl(1)"
    assert "gbl(1)" == get ^GBL(1)
    setvar: 
        ^GBL = "gbl"
        ^GBL(4711) = "4711"
        ^GBL("4711", "ABC") = "4711,ABC"
    assert "gbl" == get ^GBL 
    assert "4711" == get ^GBL(4711)
    assert "4711,ABC" == get ^GBL("4711", "ABC")

    let id = "abc"
    setvar: ^GBL(id) = "abc"
    assert "abc" == get ^GBL(id)
    setvar: ^GBL($id) = "abc"
    assert "abc" == get ^GBL($id)


    let (a,b) = (get ^GBL(1), get ^GBL(4711))
    assert a == "gbl(1)" and b == "4711"



proc testGetWithType() =
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

    assert int.high == get ^GBL("int").int
    assert int8.high == get ^GBL("int8").int8
    assert int16.high == get ^GBL("int16").int16
    assert int32.high == get ^GBL("int32").int32
    assert int64.high == get ^GBL("int64").int64
    assert uint.high == get ^GBL("uint").uint
    assert uint8.high == get ^GBL("uint8").uint8
    assert uint16.high == get ^GBL("uint16").uint16
    assert uint32.high == get ^GBL("uint32").uint32
    assert uint64.high == get ^GBL("uint64").uint64
    assert 3.1414 == get ^GBL("float").float
    assert 3.1414.float32 == get ^GBL("float32").float32
    
    let os = toOrderedSet([1,2,3,4,5,6,7,8,9,10])
    let gbl = "^GBL(\"os\")"
    setvar: @gbl = $os
    let osdb = get @gbl.OrderedSet
    assert os == osdb

proc testSpecialVars() =
    echo get $ZVERSION

proc testIndirection() =
    let gbl = "^GBL"
    setvar: @gbl = "gbl"
    assert "gbl" == get @gbl

    let gbl123 = "^GBL(123, 4711)"
    setvar: @gbl123 = "gbl(123)"
    assert "gbl(123)" == get @gbl123

proc benchTest() =
    const maxrecs = 1_000_000
    timed:
        echo "setvar ^GBL(i)"
        for i in 0..maxrecs:
            setvar: ^GBL(i) = i
    timed:
        echo "get ^GBL(i)"
        var sum1, sum2 = 0
        for i in 0..maxrecs:
            sum1 += i
            sum2 += get ^GBL(i).int
        assert sum1 == sum2
    timed:
        echo "ydb_set ^GBL(i)"
        for i in 0..maxrecs:
            ydb_set("^GBL", @[$i], $i)
    timed:
        sum1 = 0
        sum2 = 0
        echo "ydb_get ^GBL(i)"
        for i in 0..maxrecs:
            sum1 += i
            sum2 += parseInt(ydb_get("^GBL", @[$i]))
        assert sum1 == sum2

proc testDeleteNode() =
    setvar: ^GBL="hallo"
    delnode: ^GBL
    doAssertRaises(YdbError): discard get ^GBL

    let gbl = "^GBL(1)"
    setvar: @gbl = "gbl(1)"
    delnode: @gbl
    doAssertRaises(YdbError): discard get @gbl

    setvar: ^GBL1="hallo"
    assert "hallo" == get ^GBL1
    delnode: ^GBL1
    doAssertRaises(YdbError): discard get ^GBL1

    setvar:
        ^GBL1="gbl1"
        ^GBL2="gbl2"
        ^GBL3="gbl3"
    delnode:
        ^GBL1
        ^GBL2
        ^GBL3
    doAssertRaises(YdbError): discard get ^GBL1
    doAssertRaises(YdbError): discard get ^GBL2
    doAssertRaises(YdbError): discard get ^GBL3

    setvar:
        ^GBL(1)=1
        ^GBL(2)=2
        ^GBL(3)=3
    delnode:
        ^GBL(1)
        ^GBL(2)
        ^GBL(3)
    doAssertRaises(YdbError): discard get ^GBL(1)
    doAssertRaises(YdbError): discard get ^GBL(2)
    doAssertRaises(YdbError): discard get ^GBL(3)

proc testDeleteTree() =
    setvar: 
        ^GBL="gbl"
        ^GBL(1,1)="1,1"
        ^GBL(1,2)="1,2"
        ^GBL(2,1)="2,1"
        ^GBL(2,2)="2,2"
        
    deltree: ^GBL(1)
    doAssertRaises(YdbError): discard get ^GBL(1,1)
    doAssertRaises(YdbError): discard get ^GBL(1,2)
    deltree: ^GBL(2)
    doAssertRaises(YdbError): discard get ^GBL(2,1)
    doAssertRaises(YdbError): discard get ^GBL(2,2)
    deltree: ^GBL
    doAssertRaises(YdbError): discard get ^GBL

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


if isMainModule:
    testLocals()
    testGlobals()
    testSpecialVars()
    testIndirection()
    testGetWithType()
    testDeleteNode()
    testDeleteTree()
    testIncrement()
    benchTest()



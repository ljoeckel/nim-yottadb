import yottadb
import std/unittest
import std/strutils
import ydbutils

let strSeq = @["A","B","C","D","E","F","G","H","I","J"]
let intSeq = @[1,2,3,4,5,6,7,8,9,10]
let floatSeq = @[1.1, 2.3, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10]
let boolSeq = @[true, true, false, false, false, true, true, true, true, false]

proc dumpData() =
    for (k,v) in QueryItr ^Sequence.kv:
        echo k,"=",v

proc dumpKeys() =
    for key in QueryItr ^Sequence:
        echo "key=", key


proc testStringSeq() =
    Set: ^Sequence(1) = join(strSeq, ",")
    assert strSeq == Get ^Sequence(1).seqStr

proc testIntSeq() =
    Set: ^Sequence(2) = join(intSeq, ",")
    assert intSeq == Get ^Sequence(2).seqInt

proc testFloatSeq() =
    Set: ^Sequence(3) = join(floatSeq, ",")
    assert floatSeq == Get ^Sequence(3).seqFloat

proc testBoolSeq() =
    Set: ^Sequence(4) = join(boolSeq, ",")
    assert boolSeq == Get ^Sequence(4).seqBool

proc testSeq() =
    Set: ^Sequence(10) = strSeq
    assert strSeq == Get ^Sequence(10).seqStr
    Set: ^Sequence(11) = intSeq
    assert intSeq == Get ^Sequence(11).seqInt
    Set: ^Sequence(12) = floatSeq
    assert floatSeq == Get ^Sequence(12).seqFloat
    Set: ^Sequence(13) = boolSeq
    assert boolSeq == Get ^Sequence(13).seqBool

proc testHugeSeq() =
    var hugeInt: seq[int]
    var hugeStr: seq[string]
    var hugeFloat: seq[float]
    var hugeBool: seq[bool]

    for i in 0..500_000:
        hugeInt.add(i)
        hugeStr.add($i)
        hugeFloat.add(i.float * 1.25)
        hugeBool.add(if i mod 3 == 0: true else: false)

    timed:
        Set: ^Sequence("hugeStr") = hugeStr
        assert hugeStr == Get ^Sequence("hugeStr").seqStr
        echo hugeStr[0..10]

    timed:
        Set: ^Sequence("hugeInt") = hugeInt
        assert hugeInt == Get ^Sequence("hugeInt").seqInt
        echo hugeInt[0..10]

    timed:
        Set: ^Sequence("hugeFloat") = hugeFloat
        assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat
        echo hugeFloat[0..10]

    timed:
        Set: ^Sequence("hugeBool") = hugeBool
        assert hugeBool == Get ^Sequence("hugeBool").seqBool
        echo hugeBool[0..10]



proc testRedirection() =
    var global = "^Sequence"
    Set: @global(5) = join(strSeq,",")
    assert strSeq == Get @global(5).seqStr

    let id = 5.5
    Set: @global(id) = join(strSeq,",")
    assert strSeq == Get @global(id).seqStr

    global = "^Sequence(6)"
    Set: @global = join(strSeq,",")
    assert strSeq == Get @global.seqStr


when isMainModule:
  Kill ^Sequence

  suite "Sequences Tests":
    test "string": testStringSeq()
    test "int": testIntSeq()
    test "float": testFloatSeq()
    test "bool": testBoolSeq()
    test "redirection": testRedirection()
    test "save seq direct": testSeq()
    test "Huge Sequence": testHugeSeq()
  
  #dumpData()
  #dumpKeys()

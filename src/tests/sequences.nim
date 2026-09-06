import yottadb
import std/unittest
import std/strutils
import ydbutils

let strSeq = @["A","B","C","D","E","F","G","H","I","J"]
let intSeq = @[1,2,3,4,5,6,7,8,9,10]
let floatSeq = @[1.1, 2.3, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10]
let boolSeq = @[true, true, false, false, false, true, true, true, true, false]

const MAX_ELEMENTS = 1_000_000
var hugeInt = newSeqOfCap[int](MAX_ELEMENTS) # seq[int]
var hugeStr = newSeqOfCap[string](MAX_ELEMENTS) # seq[int]
var hugeFloat = newSeqOfCap[float](MAX_ELEMENTS) # seq[int]
var hugeBool = newSeqOfCap[bool](MAX_ELEMENTS) # seq[int]
for i in 0..MAX_ELEMENTS:
    hugeInt.add(i)
    hugeStr.add($i)
    hugeFloat.add(i.float * 1.25)
    hugeBool.add(if i mod 3 == 0: true else: false)

proc testStringSeq() =
    Set: ^Sequence(1) = join(strSeq, ",")
    assert strSeq == Get ^Sequence(1).seqString

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
    Kill ^Sequence
    Set: ^Sequence(10) = strSeq
    assert strSeq == Get ^Sequence(10).seqString
    Set: ^Sequence(11) = intSeq
    assert intSeq == Get ^Sequence(11).seqInt
    Set: ^Sequence(12) = floatSeq
    assert floatSeq == Get ^Sequence(12).seqFloat
    Set: ^Sequence(13) = boolSeq
    assert boolSeq == Get ^Sequence(13).seqBool

proc testHugeSeq() =
    Kill ^Sequence
    timed:
        Set: ^Sequence("hugeStr") = hugeStr
        assert hugeStr == Get ^Sequence("hugeStr").seqString

    timed:
        Set: ^Sequence("hugeInt") = hugeInt
        assert hugeInt == Get ^Sequence("hugeInt").seqInt

    timed:
        Set: ^Sequence("hugeFloat") = hugeFloat
        assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat

    timed:
        Set: ^Sequence("hugeBool") = hugeBool
        assert hugeBool == Get ^Sequence("hugeBool").seqBool


proc testHugeSeqGzip() =
    Kill ^Sequence
    timed:
        Set: ^Sequence("hugeStr") = hugeStr.gzip
        assert hugeStr == Get ^Sequence("hugeStr").seqString.gzip

    timed:
        Set: ^Sequence("hugeInt") = hugeInt.gzip
        assert hugeInt == Get ^Sequence("hugeInt").seqInt.gzip

    timed:
        Set: ^Sequence("hugeFloat") = hugeFloat.gzip
        assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat.gzip

    timed:
        Set: ^Sequence("hugeBool") = hugeBool.gzip
        assert hugeBool == Get ^Sequence("hugeBool").seqBool.gzip

proc testHugeSeqZlib() =
    Kill ^Sequence
    timed:
        Set: ^Sequence("hugeStr") = hugeStr.zlib
        assert hugeStr == Get ^Sequence("hugeStr").seqString.zlib

    timed:
        Set: ^Sequence("hugeInt") = hugeInt.zlib
        assert hugeInt == Get ^Sequence("hugeInt").seqInt.zlib

    timed:
        Set: ^Sequence("hugeFloat") = hugeFloat.zlib
        assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat.zlib

    timed:
        Set: ^Sequence("hugeBool") = hugeBool.zlib
        assert hugeBool == Get ^Sequence("hugeBool").seqBool.zlib


proc testRedirection() =
    var global = "^Sequence"
    Set: @global(5) = join(strSeq,",")
    assert strSeq == Get @global(5).seqString

    let id = 5.5
    Set: @global(id) = join(strSeq,",")
    assert strSeq == Get @global(id).seqString

    global = "^Sequence(6)"
    Set: @global = join(strSeq,",")
    assert strSeq == Get @global.seqString


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
    test "Huge Sequence GZIP": testHugeSeqGzip()
    test "Huge Sequence ZLIB": testHugeSeqZlib()

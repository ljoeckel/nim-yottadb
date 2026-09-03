import yottadb
import std/unittest
import std/strutils

let strSeq = @["A","B","C","D","E","F","G","H","I","J"]
let intSeq = @[1,2,3,4,5,6,7,8,9,10]
let floatSeq = @[1.1, 2.3, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10]
let boolSeq = @[true, true, false, false, false, true, true, true, true, false]

proc dumpData() =
    for (k,v) in QueryItr ^Sequence.kv:
        echo k,"=",v


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
    dumpData()
    assert strSeq == Get ^Sequence(10).seqStr


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
    #test "save seq": testSeq()

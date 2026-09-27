import std/[unittest]
import yottadb
import ydbutils

const 
    ITER = 10
    refKeys = @["^hello(0)","^hello(1)","^hello(2)","^hello(3)","^hello(4)","^hello(5)","^hello(6)","^hello(7)","^hello(8)","^hello(9)"]
    refSubs = @[@["0"], @["1"], @["2"],@["3"], @["4"], @["5"], @["6"], @["7"], @["8"], @["9"]]
    refKV = @["^hello(0)=0", "^hello(1)=1", "^hello(2)=2", "^hello(3)=3", "^hello(4)=4", "^hello(5)=5", "^hello(6)=6", "^hello(7)=7", "^hello(8)=8", "^hello(9)=9"]
    refSV = @["@[\"0\"]=0", "@[\"1\"]=1", "@[\"2\"]=2", "@[\"3\"]=3", "@[\"4\"]=4", "@[\"5\"]=5", "@[\"6\"]=6", "@[\"7\"]=7", "@[\"8\"]=8", "@[\"9\"]=9"]

proc create() =
    Kill: ^hello
    for id in 0..<ITER:
        Set: ^hello(id)=id

proc testIter() =
    var dbKeys: seq[string]
    for key in QueryItr ^hello:
        dbKeys.add(key)
    assert dbKeys == refKeys

proc testIterFrom() =
    var dbKeys: seq[string]
    for key in QueryItr ^hello(5):
        dbKeys.add(key)
    assert dbKeys == refKeys[6..^1]

proc testIterSeq() =
    var dbSubs: seq[seq[string]]
    for subs in QueryItr ^hello.keys:
        dbSubs.add(subs)
    assert dbSubs == refSubs

proc testIterKV() =
    var dbKV: seq[string]
    for (key, value) in QueryItr ^hello.kv:
        dbKV.add(key & "=" & value)
    assert dbKV == refKV

proc testIterSV() =
    var dbSV: seq[string]
    for (subs, value) in QueryItr ^hello.sv:
        assert subs.len == 1
        assert value.len > 0
        dbSV.add($subs & "=" & value)
    assert dbSV == refSV


proc singleKey() =
    let key = Query ^hello(5)
    assert key == "^hello(6)"

proc test() =
    var cnt = 0
    var subs = Query ^hello.keys
    while subs.len > 0:
        inc cnt
        subs = Query ^hello(subs).keys
    assert cnt == 10

proc testIterMacro() =
    var cnt = 0
    for subs in QueryItr ^hello.keys:
        inc cnt
    assert cnt == ITER

proc testIterMacroIndirect() =
    var cnt = 0
    let gblname = "^hello"
    for gbl in QueryItr @gblname:
        inc cnt
    assert cnt == ITER

proc testIterMacroIndirectStart() =
    var cnt = 0
    let gblname = "^hello"
    let half = ITER div 2
    for gbl in QueryItr @gblname(half):
        inc cnt
    assert cnt == half - 1



proc getdata() =
    for id in 0..<ITER:
        let val = Get ^hello(id)

proc delete() =
    for id in 0..<ITER:
        Killnode: ^hello(id)

proc collectGlobals(): seq[string] =
    var gbl = Query ^hello
    while gbl.len > 0:
        result.add(gbl)
        gbl = Query @gbl
    assert ITER == result.len

proc collectGlobalsWithIter(): seq[string] =
    for gbl in QueryItr ^hello:
        result.add(gbl)
    assert ITER == result.len

proc getDataFromCollection() =
    var cnt = 0
    for id in collectGlobals():
        let val = Get @id
        assert $cnt == val
        inc cnt

proc getDataFromCollectionWithIter() =
    var cnt = 0
    for id in collectGlobalsWithIter():
        let val = Get @id
        assert $cnt == val
        inc cnt


when isMainModule:
    test "create": create()
    test "test": test()
    test "testIterMacro": testIterMacro()
    test "testIter": testIter()
    test "testIterFrom": testIterFrom()
    test "testIterSeq": testIterSeq()    
    test "testIterKV": testIterKV()    
    test "testIterSV": testIterSV()    
    test "singleKey": singleKey()
    test "testIterMacroIndirect": testIterMacroIndirect()
    test "testIterMacroIndirectStart": testIterMacroIndirectStart()
    test "getdata": getdata()
    test "getDataFromCollection": getDataFromCollection()
    test "getDataFromCollectionWithIter": getDataFromCollectionWithIter()
    test "delete": delete()

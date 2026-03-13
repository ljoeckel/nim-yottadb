import std/unittest
import yottadb

const LOCAL_IDS = @["local(0)","local(1)","local(2)","local(3)","local(4)","local(5)","local(6)","local(7)","local(8)","local(9)","local(10)"]
const LOCAL_IDS1 = @["local(0)","local(1)","local(2)","local(3)","local(5)","local(6)","local(7)","local(8)","local(9)","local(10)"]
const LOCAL_IDS2 = @["local(0)","local(1)","local(2)","local(3)","local(6)","local(7)","local(8)","local(10)"]
const LOCAL_IDS3 = @["local(0)","local(1)","local(2)","local(3)","local(6)","local(8)","local(10)"]

proc getLocals(): seq[string] =
    for id in QueryItr local:
        result.add(id)

proc testLocals() =
    for i in 0..10:
        Set: local(i) = i
    assert LOCAL_IDS == getLocals()

    Killnode: local(4)
    assert LOCAL_IDS1 == getLocals()

    Killnode:
        local(5)
        local(9)
    assert LOCAL_IDS2 == getLocals()

    let lcl = "local(7)"
    Killnode: @lcl
    assert LOCAL_IDS3 == getLocals()

    Kill: local
    assert getLocals().len == 0

when isMainModule:
    test "locals": testLocals()

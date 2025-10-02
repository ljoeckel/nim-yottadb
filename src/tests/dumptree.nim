#import macros
import yottadb

#dumpTree:
#    var cnt1 = increment(^CNT("AUTO", by=5))



proc testIncrementBy() =
    delnode: ^CNT("XXX")
    var x = increment: ^CNT("XXX")
    assert x == 1
    x = increment: ^CNT("XXX", by=100)
    assert x == 101

    for i in 0..10:
        var z = increment local("abc", by=5)
        assert z == i * 5 + 5

    delnode ^CNT("XXX")
    for i in 0..10:
        var z = increment ^CNT("XXX", by=5)
        assert z == i * 5 + 5

testIncrementBy()

var x = increment: ^CNT("XXX")
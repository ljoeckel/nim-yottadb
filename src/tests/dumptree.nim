import macros
import yottadb

dumpTree:
    lock localvar(4711)

#lock: {+^loc2, loc3, +loc4, loc5, -loc6, -^loc3, loc9}
#lock +^var1
#lock: +^var2
#lock -^var3
#lock: -^var4
#lock { var1, ^var2(123), var3("abc",4711), timeout="987654321" }
#lock { +var1, variable(123), ^globalvar(1,2,3), +^var2(123), +var3("abc",4711), -var1, -^gbl(815,"def"), timeout="987654321" }
#lock {var1, var2(), var3(4711), var4("abc", 4711, "def"), var5}
# echo "pid=", get($JOB)
# lock {^var1, +^var2}
# lock {+^var3, timeout=999888777}
# lock {-^var2}
# lock +^var2
# lock {+^var2(4711)}
# lock {+^var2(4711,"ABC"), ^var4()}
# lock +^varx(4711)
# lock -^var2(4711, "ABC")

lock +localvar1
lock +localvar2
lock +localvar3
echo getLocksFromYottaDb()
lock -localvar1
lock -localvar2
lock -localvar3
echo getLocksFromYottaDb()

echo get(^lj)
echo get ^lj





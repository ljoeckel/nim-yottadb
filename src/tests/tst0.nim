import yottadb
import ydbutils

setvar:
    ^x="x"
    ^x(1)=1
    ^x(1,1)=2
    ^x(1,1,1)=3
    ^x(2)=4
    ^x(2,1)=5
    ^x(3,1)=6

listVar("^x")

kill:
    #^x(1,1,1)
    # ^x(1,1)
    #^x(1)
    ^x

echo "-----------------"
listVar("^x")
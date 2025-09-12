# nim-yottadb
**Nim Language implementation for the YottaDB database**

This project adds 'Nim' (https://nim-lang.org) as another language to access YottaDB NoSQL database. (https://yottadb.com)

YottaDB is a proven Multi-Language NoSQL database engine whose code base has decades of maturity and continuous investment. It is currently in production at some of the largest real-time core banking applications and electronic health record deployments.

The nim-yottadb implementation delievers the following features:
### Simple-API ###
- ydb_data (Get the state of a node or tree)
- ydb_delete (Node or Tree)
- ydb_delete_excl (Delete local variables except ...)
- ydb_get (Get a local or global variable)
- ydb_incr (Atomic Increment a local or global variable)
- ydb_lock (Lock 1 or more global variables)
- ydb_lock_incr / ydb_lock_dec (Increment or decrement a lock count)
- ydb_node_next (Get the next node of a global)
- ydb_node_previous (Like next, but other direction)
- ydb_set (Set the value of a local or global variable)
- ydb_subscript_next (Traverse the subscript tree of a Global). Up to 32 subscripts are allowed
- ydb_subscript_previous (Like ydb_subscript_next, but other direction)
- ydb_tp (Start a transaction)
- ydb_ci (Call a M-Routine via Call-In Interface)

### Extensions to the Simple-API
- Iterator for next/previous node
- Iterator for next/previous subscript
- YdbVar with $ and [] operator
```nim
for i in 0..MAX:
    var v = newYdbVar("^Geo", @["LAND", "ORT", i])
    # update db with new value
    v[] = "New " & v.value
```
### DSL
- set: 
```nim
set: ^Customer(4711,"Name")="John Doe"
```
- incr:
```nim
let: int txid = incr: ^CNT("TXID")
```
- get:
```nim
let name = get: ^Customer(4711,"Name")
let f: float = get: ^Customer(4711, accountId, transactionId, "amount").float
nim let i: int = get: ^Customer(4711, accountId, "somevalue").int
```
- nextn:
```nim var
  rc: int
  node: Subscripts
(rc, node) = nextn: ^House("FLOOR")
```
- prevn:
```nim
(rc, node) = prevn: ^House("FLOOR", "9999")
```
- nextsub:
```nim
(rc, node) = prevn: ^House("ELECTRIC")
```
- prevsub:
```nim
(rc, node) = prevn: ^House("ELECTIRC", "CABLES")
```
- data:
```nim
let dta: int = data: ^House("FLOOR")
'dta' can have the following values:
enum YdbData:
  NO_DATA_NO_SUBTREE
  DATA_NO_SUBTREE
  DATA_AND_SUBTREE
  NO_DATA_WITH_SUBTREE
```
- delnode:
```nim
delnode: ^House("FLOOR",1)
```
- deltree:
```nim
deltree: ^House("FLOOR")
```
- delexcl:
```nim
delexcl: { DELTEST1, DELTEST3, DELTEST5 }
```
- lock:
```nim
lock: { ^House("FLOOR", 11), ^House("FLOOR", 12) }
```
- lockincr:
```nim
lockincr: ^House("FLOOR", 11)
```
- lockdecr:
```nim
lockdecr: ^House("FLOOR", 11)
```


All API-Calls are available in a single- or multi-threaded version and ara automatically selected via the **when compileOption("threads")**


For the project's architecture details look at https://deepwiki.com/ljoeckel/nim-yottadb/1-overview


This project was started to learn NIM (https://nim-lang.org)
I'm truly impressed by the simplicity, power, and flexibility of Nim. The possibilities offered by macros and templates, in particular, make Nim a powerful tool. Developing software is finally fun again.




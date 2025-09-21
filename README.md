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
The DSL allows to write programs with globals in very natural way.
```nim
  withlock(4711):
    set:
      let id = @["4711", "Acc123"]
      var amount = get: ^account(id).float
      amount += 1500.0
      ^account(id) = amount # update db
  echo "Done"
  # lock automatically released here
```
To set an id for a global some different variants are available
```nim
set:
  ^gbl(1)=1
  ^gbl(1,1)=1.1
  ^gbl("B")="..."
  ^gbl("B","C")="..."
  let (id1, id2, id3) = (4711, "CSTM", 1.0)
  ^gbl(id1, id2, id3) = "....."
  let subs: Subscripts = @["ACCNT", "4711", "1.1"]
  ^gbl(subs)="...."
```

### Currently the following DSL is supported:
- ### set: 
```nim
set: ^Customer(4711,"Name")="John Doe"
```
- incr:
```nim
let: int txid = incr: ^CNT("TXID")
```
- ### get:
```nim
let name = get: ^Customer(4711,"Name")
let f: float = get: ^Customer(4711, accountId, transactionId, "amount").float
let i: int = get: ^Customer(4711, accountId, "somevalue").int
```
- ### nextnode:
```nim var
  rc: int
  node: Subscripts
(rc, node) = nextnode: ^House("FLOOR")
```
- ### prevnode:
```nim
(rc, node) = prevnode: ^House("FLOOR", "9999")
```
- ### nextsubscript:
```nim
(rc, node) = nextsubscript: ^House("ELECTRIC")
```
- ### prevsubscript:
```nim
(rc, node) = prevsubscript: ^House("ELECTIRC", "CABLES")
```
- ### data:
```nim
let dta: int = data: ^House("FLOOR")
'dta' can have the following values:
enum YdbData:
  NO_DATA_NO_SUBTREE
  DATA_NO_SUBTREE
  DATA_AND_SUBTREE
  NO_DATA_WITH_SUBTREE
```
- ### delnode:
```nim
delnode: ^House("FLOOR",1)
```
- ### deltree:
```nim
deltree: ^House("FLOOR")
```
- ### delexcl:
```nim
delexcl: { DELTEST1, DELTEST3, DELTEST5 }
```
- ### lock:
```nim
lock: { ^House("FLOOR", 11), ^House("FLOOR", 12) }
```
- ### lockincr:
```nim
lockincr: ^House("FLOOR", 11)
```
- ### lockdecr:
```nim
lockdecr: ^House("FLOOR", 11)
```

All API-Calls are available in a single- or multi-threaded version and ara automatically selected via the **when compileOption("threads")**


For the project's architecture details look at https://deepwiki.com/ljoeckel/nim-yottadb/1-overview

- [Blog](doc/blog.md) gives some general information about the project
- Go to [Installation](doc/installation_and_using.md) for installation details.
- For ARM Architecture look [here](doc/installation_yottadb.md)
- [dsl](doc/dsl.md) for details about the Domain Specific Language
- Details about the Call-In Interface are found [here](doc/callin_interface.md)
- [Object-Serialization](doc/object_serialization.md) gives infos how to serialize and deserialize Nim object to YottaDB.
- Some details about Transactions are [here](doc/yottadb.md). Need's further work
- Benchmark results (few) are [here](doc/benchmark.md)

This project was started to learn NIM (https://nim-lang.org)
I'm truly impressed by the simplicity, power, and flexibility of Nim. The possibilities offered by macros and templates, in particular, make Nim a powerful tool. Developing software is finally fun again.

### Test's and Examples
In a cloned repo, you can run the tests and examples with
```bash
nimble test
nimble examples
```

### Feedback
nim-yottadb is a **work in progress** and any feedback or suggestions are welcome. It is hosted on GitHub [nim-yottadb](https://github.com/ljoeckel/nim-yottadb) with an MIT license so issues, forks and PRs are most appreciated. 


If you want to contact me please email to **lothar.joeckel@gmail.com**

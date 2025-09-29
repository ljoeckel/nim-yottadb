# Nim meets YottaDB:  Exploring the "nim-yottadb" Wrapper

If you’re a Nim developer interested in working with a powerful hierarchical NoSQL engine, or a M developer interested in working with powerful modern programming language then this is for you.

I’m pleased to announce nim-yottadb, a language binding that connects Nim with the YottaDB database. This gives you direct access to global / local variables, transactions, iteration, locks, and more — all from Nim.

In this post, I want to walk you through:

- What YottaDB is (at a high level)
- Why binding it to Nim is interesting
- What features nim-yottadb currently offers
- How its API and DSL design works
- Caveats, threading, and implementation notes
- Examples and next steps

## Key Features of YottaDB

YottaDB is a high-performance, schema-less, key-value database designed for extreme scalability and reliability, particularly in transaction-heavy environments. Its design philosophy is rooted in the M (or MUMPS) language and database, which has been battle-tested in critical systems for decades.

#### Key-Value Data Model with a Hierarchical Twist:
At its core, data is stored as sparse,multi-dimensional arrays. A variable (or "global") can have subscripts, creating a natural tree structure.
```
^Patients("Smith", "John", 2024, "Visit") = "Checkup"
```
This model is incredibly flexible (schema-less) and allows for efficient hierarchical data access.

#### Extreme Performance and Low Latency:
YottaDB is an in-memory database with a transaction journal for durability. All data operations are performed directly in memory, making it exceptionally fast.

It uses a single, highly optimized database engine process per region, with application processes connecting to it. This eliminates per-connection overhead and resource contention.

#### Massive Scalability:
It scales efficiently on multi-core servers. You can run multiple database engine processes (for different database regions) on a single server to leverage many CPU cores.

It supports a "Application Multiplexing" architecture, allowing multiple application servers to access a single YottaDB database instance, which is a classic scale-out pattern.

#### Rock-Solid Reliability and ACID Transactions:
YottaDB is designed for environments where data loss is unacceptable (e.g., banks, hospitals).

It provides full ACID (Atomicity, Consistency, Isolation, Durability) compliance through a robust transaction processing system and write-ahead journaling. Database updates are first written to a journal file before being applied to the database, ensuring data can be recovered even after a crash.

#### Tight Integration of Database and Programming Language:
This is a hallmark of the M lineage. The database operations are intrinsic commands within the M (or MUMPS) language.

There is no separate query language (like SQL) or connection string. A simple command like SET ^Customer(123)="John" both updates the variable in memory and commits the change to the database.

This eliminates object-relational mapping (ORM) overhead and makes the code very concise for data manipulation.

#### Mature and Robust Codebase:
The codebase has its roots in the 1960s MUMPS database. YottaDB itself is a direct descendant and has been hardened over decades of use in critical, high-availability systems.

#### Efficient Database Replication:
Provides built-in, low-latency replication between database instances. This is crucial for creating hot-standby systems for disaster recovery and for distributing load in a geographically distributed system.

Primary Use Cases: Core banking systems, electronic health records (EHR), stock exchanges, and any other application requiring high-throughput, low-latency, and ultra-reliable transaction processing.

#### Other Database Vendors Using the Same Underlying Technology
YottaDB is a direct, open-source descendant of the proprietary GT.M database (which was originally developed by Greystone Technology and later sold to FIS). Because of this shared lineage, the "same underlying technology" primarily refers to the MUMPS database engine and the M programming language paradigm.

The most significant other player in this specific niche is:
`InterSystems IRIS` (and its predecessor, `Caché`):

## Key features of the "Nim" programming language?
The Nim programming language is a statically typed, compiled systems language that has a unique and powerful set of features. It's often described as having the performance of C or C++, the expressiveness of Python, and the safety of Rust or Ada.

#### Python-like Syntax with Static Typing
This is one of the most immediately appealing features.
Nim's syntax uses significant whitespace (indentation) like Python, making it clean and easy to read.

Unlike Python, it's statically typed, meaning type errors are caught at compile time, leading to more robust and performant code. The compiler does all the type checking before the program ever runs.

#### Looks like Python, but is statically typed and compiled!
```nim
proc greet(name: string, age: int): string =
  return "Hello, " & name & ". You are " & $age & " years old."

echo greet("Alice", 30)
````

#### Compiles to Efficient C, C++, and JavaScript
Nim doesn't have a virtual machine. Instead, it compiles its source code down to another language.

By compiling to C, C++, or even Objective-C, it achieves performance comparable to these native languages. The generated C code can be compiled on virtually any platform.

The JavaScript target allows you to write both your backend and frontend logic in the same language, enabling full-stack development with Nim.

#### Powerful Metaprogramming
This is one of Nim's superpowers. You can generate code at compile time, reducing boilerplate and creating powerful Domain-Specific Languages (DSLs).

With Templates you perform simple syntactic substitutions (hygienic macros). They are like C macros but much safer and more integrated.

The most powerful feature is Macros. You can manipulate the Abstract Syntax Tree (AST) of your code at compile time. This allows you to implement new language features, validate complex conditions, or generate code based on custom logic.

#### Memory Safety and Control
Nim offers a pragmatic approach to memory management.

It comes with several built-in garbage collectors (e.g., deferred reference counting, mark-and-sweep, ..). The default is fast and pause-free for most applications.

For systems programming or real-time applications where GC pauses are unacceptable, you can use manual memory management (alloc, dealloc) or leverage the --gc:arc or --gc:orc (Owned Reference Counting) options, which provide deterministic, non-tracing memory management without a garbage collector.

#### Generics, Union Types, and More
Nim's type system is both practical and expressive.

Full support for generic programming, allowing you to write flexible and reusable code for different types.

Sum Types (Variant Objects) let you define a type that can hold values of different, but fixed, types. This is excellent for modeling state.

With Distinct Types you create a new type that has the same underlying representation as an existing type but is considered incompatible with it (e.g., type Meter = distinct int and type Kilogram = distinct int prevents you from accidentally adding meters to kilograms).

#### Zero-Cost Abstraction and Efficiency
Nim is designed to be highly efficient.

- No Runtime Overhead: Features like iterators, templates, and generics are resolved at compile time, resulting in code that is as fast as hand-written C.

- Value Types: Structs are value types by default (stored on the stack), which is cache-friendly and fast.

- Direct Control: You have low-level control over memory layout, pointers, and can even inline assembly code when needed.

#### Unified Function Call Syntax (UFCS)
This syntactic sugar allows for both method-call and function-call syntax, where a.f(b) is equivalent to f(a, b).

This enables a fluent, "chaining" style of programming that is very readable, similar to what you find in Unix pipes or Rust.

#### Cross-Platform and Interoperability
- Native Executables: Nim compiles to a single, dependency-free native executable, making deployment trivial.

- Excellent C/C++ Interop: You can directly import and call C/C++ functions and libraries with minimal effort, making it easy to leverage existing codebases.

- Cross-Compilation: It's straightforward to compile for a different target platform (e.g., compile for Windows on a Linux machine).

#### Async/Await for Concurrency
Nim has a built-in async/await mechanism for writing highly scalable asynchronous I/O operations, similar to what you find in Python, JavaScript, or C#. This makes it well-suited for network servers and clients.


## What nim-yottadb provides
Many environments use YottaDB already (e.g. legacy systems, M-based suites). By having a Nim binding, one can write new components or tooling in Nim that integrate with existing YottaDB data.

The flexibility of Nim’s metaprogramming (macros, templates) enables a nicer API and DSL wrapper over the more “raw” C interface. You can mask lower-level details, make code more expressive, and reduce boilerplate.

### Core (Simple-API)

The binding exposes a basic set of database operations, roughly mapping to YottaDB capabilities:

- ydb_data — inspect node or subtree state (e.g. whether there is data, subtree, both or neither)

- ydb_delete — delete a node or an entire subtree

- ydb_delete_excl — delete local variables except some exclusions

- ydb_get / ydb_set — read or assign the value of a local or global variable

- ydb_incr — atomic increment (local or global)

- ydb_lock — lock one or more global variables

- ydb_lock_incr / ydb_lock_dec — manipulate a lock count

- ydb_node_next / ydb_node_previous — traverse siblings or nodes in and out of order

- ydb_subscript_next / ydb_subscript_previous — step through subscript ranges under a global

- ydb_ci — call a routine (M / YottaDB “Call-In Interface”)

These correspond fairly directly to typical YottaDB / GT.M C-level APIs (or M primitives). The binding supports both single-threaded and multi-threaded modes (automatically selected when compiling with --threads). 

## Extensions & syntactic sugar

To make working with the binding more ergonomic, nim-yottadb adds:

### Iterators
to iterate over next/previous node or subscript — you can loop over nodes instead of manually calling next/sub

### YdbVar
A type with overloaded operators ($, []) so that a global can be referenced in a natural, array-like way

### DSL
A DSL that offers Nim-style keywords/mnemonics for common operations

#### set / get
```nim
set:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"
```
#### Postfix notation
get with type conversion (int/float/binary)
```nim
set: ^CUST(@["4711", "Acct123"]) = 1500.50
var amount = get: ^CUST(subs).float
```
#### Support for mixed type subscripts
```nim
let id = 1
set: ^X(id, 4711, "pi") = 3.1414
let s = get: ^X(id, 4711, "pi").float
assert f == 3.1414
```
#### set: in a loop
```nim
set:
    for id in 0..<5:
        ^CUST(id, "Timestamp") = cpuTime()
```
## incr
Increment a global in the database
```nim
let nexttxid = incr: ^CNT("TXID")
```
## data
Test if a node or tree exists and has a subtree
```nim
set:
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
  dta = data: ^X(5)
  assert YdbData(dta) == DATA_AND_SUBTREE
  dta = data: ^X(7)
  assert YdbData(dta) == NO_DATA_WITH_SUBTREE
```

## delnode
Delete a node. If all nodes of a global are removed, the global itself is removed.
```nim
set: ^X(1)="hello"
var rc = delnode: ^X(1) # delete node
```

## deltree
Delete a subtree of a global. If all nodes are removed, the global itself is removed.
```nim
  set: ^X(1,1)="hello"
  set: ^X(1,2)="world"
  let dta = data: ^X(1) # returns 10 (no data but subtree)
  rc = deltree: ^X(1)
```

## lock
Lock upto 35 Global variables. Other processes trying to lock one of the globals will wait until the lock is released. {} Have to be used if more than one global will be locked or an empty one to release all locks.
If lock: is called again, the previous locks are automatically released first.
```nim
lock:
  {
    ^LL("HAUS", "11"),
    ^LL("HAUS", "12"),
    ^LL("HAUS", "XX"), # not yet existent, but ok
  }
var numOfLocks = getLockCountFromYottaDb()
assert 3 == numOfLocks
lock: {} # release all locks
assert 0 == getLockCountFromYottaDb()
```

## nextnode
Traverse the global and get the next node in the collating sequence.
```nim
(rc, node) = nextnode: ^LL()
@["HAUS"]
(rc, node) = nextnode: ^LL(node)
  @["HAUS", "ELEKTRIK"]
```

## prevnode
Traverse the global backward and get the previous node in the collating sequence.
```nim
(rc, subs) = prevnode: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
assert subs = @["HAUS", "ELEKTRIK", "DOSEN"]

(rc, subs) = prevnode: ^LL("HAUS", "ELEKTRIK")
assert subs = @["HAUS"]
```

## nextsubscript
Traverse on the globals on a given index level.
```nim
  var rc:int
  var subs: Subscripts
  (rc, subs) = nextsubscript: ^LL("HAUS", "ELEKTRIK")
  assert subs == @["HAUS", "FLAECHEN"]
  (rc, subs) = nextsubscript: ^LL("HAUS")
  assert subs == @["LAND"]
  (rc, subs) = nextsubscript: ^LL("")
  assert subs == @["HAUS"]
  (rc, subs) = nextsubscript: ^LL("ZZZZZZZ")
  assert rc == YDB_ERR_NODEEND and subs == @[""]
```

## prevsubscript
Traverse the globals backwards on a given index level.
```nim
  var rc:int
  var subs: Subscripts
  (rc, subs) = prevsubscript: ^LL("HAUS", "FLAECHEN")
  assert subs == @["HAUS", "ELEKTRIK"]
  (rc, subs) = prevsubscript: ^LL("LAND")
  assert subs == @["HAUS"]
  (rc, subs) = prevsubscript: ^LL("HAUS")
  assert rc == YDB_ERR_NODEEND and subs == @[""]
```

## lockincr / lockdecr
```nim
template withlock(lockid: untyped, body: untyped): untyped =
    var rc = lockincr: ^LOCKS(lockid)
    body
    rc = lockdecr: ^LOCKS(lockid)
```
Using:
```nim
proc update() =
    withlock(4711):
        echo "locks set:", getLockCountFromYottaDb()
        # do the work here
        
    echo "After locks:", getLockCountFromYottaDb()
```
## str2zwr
Save binary data through YottaDB's api.
Theoretically the maximum size of the useable data is the half of the maximum string length of 1MB.
```nim
  let x = str2zwr("hello\9World")
  assert str2zwr("hello\9World") == """"hello"_$C(9)_"World""""
```
Use `binary` postfix as an alternative for binary data.

## zwr2str
Read back data stored in the `str2zwr` format.
```nim
  assert zwr2str(""""hello"_$C(9)_"World"""") == "hello\9World"
```
Use `binary` postfix as an alternative for binary data.

# 'get' with postfix
It is possible to enforce a type when getting data from YottaDB. By using a 'postfix' a expected type can be defined and tested.
```nim
let i = get: ^global(1).int16
let f = get: ^global(4711).float32
let u = get: ^global(815).uint8
```
If the value from the db is greater or smaller than the range defined through the postfix, a `ValueError` exception is raised.

The following postfixes are implemented:
- int, int8, int16, int32, int64
- uint, uint8, uint16, uint32, uint64
- float, float32, float64

# .binary Postfix
The `binary` postfix allows to read back binary data from the DB.
```nim
  var binval: string
  for i in 0 .. 255:
    binval.add(i.char) 

  set: ^tmp(4711) = binval
  let dbval = get: ^tmp(4711).binary
  assert dbval == binval
```

# .OrderedSet Postfix
Allows to read back a OrderedSet.
When the string form '$' is saved then the saved data looks normally like `{9, 5, 1}`. The data may also be stored in the form `9,5,1` which is more efficient. The .OrderedSet postfix handles both forms.
```nim
  var os = toOrderedSet([9, 5, 1])
  # os: {9, 5, 1}
  set: ^tmp("set1") = $os
  let osdb: OrderedSet[int] = get: ^tmp("set1").OrderedSet
  assert osdb == os
```
In the momemnt, only type 'int' is implemented for this postfix.
It's experimental and may be removed in the future.

# Local Variables
All methods available for globals can also be applied for local variables.
```nim
set:
  myvar(1) = 1
  myvar("a") = "..."
  myvar(@[id, "4711"]) = "..."
  # and so on
```
# Special Variables
Getting a value, use get:
```nim
  let zversion = get: $ZVERSION
  echo zversion
```

To set a special variable via the DSL, use set:
It is important to use an empty bracket ().
```nim
  set: $ZMAXTPTIME()="2"
```

## Performance Impressions3n1+ Problem
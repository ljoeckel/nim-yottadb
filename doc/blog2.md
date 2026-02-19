# [Nim](https://nim-lang.org) meets [YottaDB](https://yottadb.com/):  Exploring the [nim-yottadb](https://github.com/ljoeckel/nim-yottadb) Wrapper

If you’re a Nim developer interested in working with a powerful hierarchical NoSQL engine, or a M developer interested in working with powerful modern programming language then this is for you.

I’m pleased to announce nim-yottadb, a language binding that connects Nim with the YottaDB database. This gives you direct access to global / local variables, transactions, iteration, locks, and more — all from Nim.

The combination of Nim's modern language features with YottaDB's battle-tested database engine creates a powerful stack for building high-performance, reliable systems. This binding bridges the gap between a decades-proven database architecture and a contemporary systems programming language.

## Simple example showing the clean syntax
```nim
Set:
  ^Users("john_doe", "profile", "name") = "John Doe"
  ^Users("john_doe", "profile", "email") = "john@example.com"

let userName = Get ^Users("john_doe", "profile", "name")
echo "Hello, ", userName
```

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
At its core, Data is stored as sparse,multi-dimensional arrays. A variable (or "global") can have subscripts, creating a natural tree structure.
```
^Patients("Smith", "John", 2024, "Visit") = "Checkup"
```
This model is incredibly flexible (schema-less) and allows for efficient hierarchical Data access.

#### Extreme Performance and Low Latency:
YottaDB is an in-memory database with a transaction journal for durability. All Data operations are performed directly in memory, making it exceptionally fast.

It uses a single, highly optimized database engine process per region, with application processes connecting to it. This eliminates per-connection overhead and resource contention.

#### Massive Scalability:
It scales efficiently on multi-core servers. You can run multiple database engine processes (for different database regions) on a single server to leverage many CPU cores.

It supports a "Application Multiplexing" architecture, allowing multiple application servers to access a single YottaDB database instance, which is a classic scale-out pattern.

#### Rock-Solid Reliability and ACID Transactions:
YottaDB is designed for environments where Data loss is unacceptable (e.g., banks, hospitals).

It provides full ACID (Atomicity, Consistency, Isolation, Durability) compliance through a robust transaction processing system and write-ahead journaling. Database updates are first written to a journal file before being applied to the database, ensuring Data can be recovered even after a crash.

#### Tight Integration of Database and Programming Language:
This is a hallmark of the M lineage. The database operations are intrinsic commands within the M (or MUMPS) language.

There is no separate Query language (like SQL) or connection string. A simple command like SET ^Customer(123)="John" both updates the variable in memory and commits the change to the database.

This eliminates object-relational mapping (ORM) overhead and makes the code very concise for Data manipulation.

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
```

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
Many environments use YottaDB already (e.g. legacy systems, M-based suites). By having a Nim binding, one can write new components or tooling in Nim that integrate with existing YottaDB Data.

The flexibility of Nim’s metaprogramming (macros, templates) enables a nicer API and DSL wrapper over the more “raw” C interface. You can mask lower-level details, make code more expressive, and reduce boilerplate.

### Core (Simple-API)

The binding exposes a basic set of database operations, roughly mapping to YottaDB capabilities:

- ydb_data — inspect node or subtree state (e.g. whether there is Data, subtree, both or neither)

- ydb_delete — delete a node or an entire subtree

- ydb_delete_excl — delete local variables except some exclusions

- ydb_get / ydb_set — read or assign the value of a local or global variable

- ydb_incr — atomic Increment (local or global)

- ydb_lock — Lock one or more global variables

- ydb_lock_incr / ydb_lock_dec — manipulate a Lock count

- ydb_node_next / ydb_node_previous — traverse siblings or nodes in and out of Order

- ydb_subscript_next / ydb_subscript_previous — step through subscript ranges under a global

- ydb_ci — call a routine (M / YottaDB “Call-In Interface”)

These correspond fairly directly to typical YottaDB / GT.M C-level APIs (or M primitives). The binding supports both single-threaded and multi-threaded modes (automatically selected when compiling with --threads). 

### Extensions & syntactic sugar

To make working with the binding more ergonomic, nim-yottadb adds:

### Iterators
to iterate over next/previous node or subscript — you can loop over nodes instead of manually calling next/sub

### YdbVar
A type with overloaded operators ($, []) so that a global can be referenced in a natural, array-like way

### DSL
Instead of using the simple api directly an alternative exists with a DSL (Domain Specific Language)
The DSL offers Nim-style keywords/mnemonics for common operations. So instead of writing
```nim
ydb_set("^building", @["Room", "1", "size"], "22.5")
```
you can write
```nim
Set: ^building("Room", 1, "Window")=22.5
```

#### setvar / get / .binary
```nim
Set:
    ^XX(1,2,3)=123
    ^XX("B",1)="AB"
let var1 = Get ^XX(1,2,3)
let image = Get ^images(4711).binary
```
#### Support for mixed type subscripts
```nim
Set: ^X(id, 4711, "pi") = 3.1414
```
#### Set: in a loop
```nim
for id in 0..<5:
Set:
    ^CUST(id, "Timestamp") = cpuTime()
    ^CUST(id, "loop") = id
```
#### Increment ####
Increment a global in the database by 1 or 5
```nim
let nexttxid1 = Increment: ^CNT("TXID")
let nexttxid5 = Increment: ^CNT("TXID", by=5)
```
#### Data
Test if a node or tree exists and has a subtree
```nim
Set:
    ^X(5)="F"
    ^X(5,1)="D"
dta = Data: ^X(5)
assert YdbData(dta) == YDB_DATA_VALUE_DESC
```
#### Killnode
Delete a node. If all nodes of a global are removed, the global itself is removed.
No descendents are removed.
```nim
Killnode: ^X(1) # delete node
```
#### Kill
Delete a subtree of a global. If all nodes are removed, the global itself is removed.
```nim
Kill: ^X(1)
```
#### Lock
Lock upto 35 Global variables. Other processes trying to Lock one of the globals will wait until the Lock is released. {} Have to be used if more than one global will be locked or an empty one to release all locks.
If Lock: is called again, the previous locks are automatically released first.
```nim
Lock:
  {
    ^LL("HAUS", "11"),
    ^LL("HAUS", "12"),
    ^LL("HAUS", "XX"), # not yet existent, but ok
  }
```
The template `withlock` simplifies the locking further:
```nim
let amount = 1500.50
withlock(4711):
  Set:
    ^custacct(4711, "amount") = amount
    ^booking(4711, "txnbr") = amount
```
On leaving the withlock block, the Lock is automatically released.

#### nextnode / prevnode / nextsubscript / prevsubscript
Traverse a global/subscript in the collating sequence.
```nim
(rc, node) = nextnode: ^LL()
(rc, node) = prevnode: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
(rc, subs) = nextsubscript: ^LL("HAUS", "ELEKTRIK")
(rc, subs) = prevsubscript: ^LL("HAUS", "FLAECHEN")
```
#### 'get' with postfix
It is possible to enforce a type when getting Data from YottaDB. By using a 'postfix' a expected type can be defined and tested.
```nim
let i = Get ^global(1).int16
let f = Get ^global(4711).float32
```
If the value from the db is greater or smaller than the range defined through the postfix, a `ValueError` exception is raised.

The following postfixes are implemented:
- int, int8, int16, int32, int64
- uint, uint8, uint16, uint32, uint64
- float, float32, float64


## Saving a Nim Object-Tree to the database
Based on the Nim object model, it is possible to store objects, even complex ones, in the database. A global variable is created for each type, e.g., "Address," "Customer," etc. Attributes are then stored with their corresponding names.
```nim
type 
  Address* = object of RootObj
    street*: string
    zip*: uint
    city*: string
    state*: string

let address = Address(street: "Bachstrasse 14", zip:6033, city:"Buchs", state:"AG")
store(@["4711"], address)
```
The Data is stored as
```nim
^Address(4711,"city")="Buchs"
^Address(4711,"state")="AG"
^Address(4711,"street")="Bachstrasse 14"
^Address(4711,"zip")=6033
```

## Performance
In general, the Nim / YottaDB language binding has excellent performance.
Simple tests on a MacMini M4 with a virtualized Ubuntu (2 Cores / 4GB Memory) gives the following figures where every test had 10 million different records.
```
upcount dsl    2439 ms. (Increment a Global)
set dsl        2479 ms. (Set global value)
nextnode dsl   1536 ms. (Iterator over all nodes)
delnode dsl    2774 ms. (Delete all nodes)
```
This means writing 4.100.041 records per second and traversing the nodes with 6.510.416 nodes per second. I think impressive numbers!

#### Nim vs. Rust
Comparing the nim-yottadb implementation with the official YottaDB Rust implementation with the following code shows also that Nim performs very close to Rust with standard memory settings. 
With some memory management configurations, Nim outperforms Rust in this scenario. The practical implications may be minimal. The difference per iteration is extremly low.

## Conclusion
The nim-yottadb binding successfully bridges two powerful technologies from different eras of computing. YottaDB brings decades of refinement in hierarchical Data management and transaction processing, while Nim offers modern language features, metaprogramming capabilities, and performance characteristics that rival lower-level systems languages.

What makes this integration particularly compelling is how Nim's DSL capabilities and clean syntax make YottaDB's hierarchical Data model feel natural and expressive. The ability to write database operations that look like native Nim code, while maintaining the performance and reliability of a battle-tested database engine, represents the best of both worlds.

The performance benchmarks demonstrate that this binding doesn't sacrifice speed for convenience—Nim applications can leverage YottaDB's capabilities with minimal overhead, making it suitable for the same high-performance, transaction-heavy use cases that YottaDB has traditionally served.

For developers working with existing YottaDB systems, nim-yottadb provides a path to modernize tooling and develop new components without abandoning proven database infrastructure. For Nim developers, it opens access to a unique class of hierarchical database that excels in scenarios where relational databases might struggle.

As the binding continues to evolve, it represents not just a technical achievement, but a practical solution for building robust, high-performance systems that need both modern development ergonomics and proven Data reliability. Whether you're extending legacy M applications or building new systems from scratch, nim-yottadb offers a compelling combination of performance, reliability, and developer experience.

The project is available on [github](https://github.com/ljoeckel/nim-yottadb) and welcomes contributions from both the Nim and YottaDB communities.
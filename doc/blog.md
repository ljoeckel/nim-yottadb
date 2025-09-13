# Nim meets YottaDB:  Exploring the `nim-yottadb` Wrapper

[YottaDB](https://yottadb.com) is a mature, high-performance, multi-language NoSQL database engine. It’s been used for decades in demanding domains like healthcare and finance. On the other side, [Nim](https://nim-lang.org) is a modern, compiled language that combines the performance of C with Python-like readability and powerful metaprogramming.

The [`nim-yottadb`](https://github.com/ljoeckel/nim-yottadb) project bridges these two worlds: it provides a Nim wrapper around the YottaDB C API, making it possible to work with globals, subscripts, transactions, and even legacy M-code directly from Nim.

---

## Key Features of `nim-yottadb`

Here are some of the highlights:

1. **Simple API**  
   Core YottaDB operations are exposed, including:
   - `ydb_get` / `ydb_set` — read and write values
   - `ydb_data` — check if a node or subtree has data
   - `ydb_delete` / `ydb_delete_excl` — remove nodes or subtrees
   - `ydb_incr` — atomic increments
   - Navigation: `ydb_node_next`, `ydb_node_previous`, `ydb_subscript_next`, etc.

2. **Locking and Concurrency**  
   - `ydb_lock`, `ydb_lock_incr`, and `ydb_lock_dec` help coordinate concurrent processes.

3. **Transactions**  
   - `ydb_tp` allows safe, transactional updates.

4. **Call-In Interface (CI)**  
   - `ydb_ci` lets you call existing M routines, making it easier to integrate with legacy YottaDB applications.

5. **Nim-Friendly DSL**  
   - A `YdbVar` type with operator overloads and iterators makes code expressive and readable.
   - Example DSL syntax:
     ```nim
     set: ^Customer(4711,"Name") = "John Doe"
     let name = get: ^Customer(4711,"Name")
     ```

6. **Nim Oject Serializer**  
   - Save and restore Nim complex objects to YottaDB (see example 'clientser')

7. **Thread Awareness**  
   - The wrapper chooses the correct underlying YottaDB APIs based on whether Nim was compiled with thread support.

---

### Example 1: Simple Set / Get
```nim
import yottadb

# Set a value
let id = 4711
set: ^Customer(id, "Name") = "John Doe"
let name = get: ^Customer(id, "Name") # Get the value back
let txCount = get: ^CNT("TXID").int # Get as a typed value
echo fmt"Customers Name: {name} txCount: {txCount}"
```
### Example 2: Traversal & Deletion
```nim
import yottadb

set:
    ^LL("HAUS")=""
    ^LL("HAUS", "ELEKTRIK", "DOSEN")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL")=""
    ^LL("HAUS", "ELEKTRIK", "SICHERUNGEN")=""
    ^LL("HAUS", "FLAECHEN", "RAUM1")=""
    ^LL("HAUS", "HEIZUNG")=""
    ^LL("LAND")=""
    ^LL("ORT")=""

proc traverse(start: Subscripts = @[]) =
    echo "Traverse tree from ": start
    var rc: int
    var nodeData = start
    (rc, nodeData) = nextsub: ^LL(start)
    while rc == YDB_OK:
        echo nodeData.repr  # inspect the subscript list
        (rc, nodeData) = nextsub: ^LL(nodeData)

traverse()
traverse(@["HAUS", "ELEKT.."])
traverse(@["HAUS", "ELEKTRIK", ""])
delnode: ^LL("HAUS", "FLAECHEN", "RAUM1") # Delete a node [HAUS, FLAECHEN] remains
deltree: ^LL("HAUS", "ELEKTRIK") # Delete an entire subtree
traverse(@["HAUS",""])
```
Produces the following output:
```
Traverse tree from @[]
@["HAUS"]
@["LAND"]
@["ORT"]
Traverse tree from @["HAUS", "ELEKT.."]
@["HAUS", "ELEKTRIK"]
@["HAUS", "FLAECHEN"]
@["HAUS", "HEIZUNG"]
Traverse tree from @["HAUS", "ELEKTRIK", ""]
@["HAUS", "ELEKTRIK", "DOSEN"]
@["HAUS", "ELEKTRIK", "KABEL"]
@["HAUS", "ELEKTRIK", "SICHERUNGEN"]
Traverse tree from @["HAUS", ""]
@["HAUS", "FLAECHEN"]
@["HAUS", "HEIZUNG"]
```
## Who Benefits?

- Nim developers who want a robust, transactional NoSQL database.

- YottaDB users who prefer Nim’s modern syntax and tooling.

- Integration projects where existing M/YottaDB logic can be reused from Nim.

## Conclusion

nim-yottadb makes it possible to combine Nim’s expressive, efficient syntax with YottaDB’s proven, transactional NoSQL engine. With simple APIs, a handy DSL, and support for transactions and locks, it lowers the barrier for building modern applications on top of YottaDB.

👉 Check it out here: [nim-yottadb](github.com/ljoeckel/nim-yottadb)
# nim-yottadb User Guide: API and DSL

This guide covers both the direct Nim wrappers around the YottaDB Simple API in
[`src/libs/ydbimpl.nim`](../src/libs/ydbimpl.nim) and the **DSL**
(domain-specific language) implemented in [`src/libs/dsl.nim`](../src/libs/dsl.nim).
The DSL provides compact Nim-native syntax for reading and writing YottaDB
global variables, local variables and intrinsic (special) variables. The direct
API is useful when you want explicit key objects, cursor traversal or control
over the underlying operations.

Both surfaces are available through one import:

```nim
import yottadb
```

The top-level module re-exports the DSL, direct API, YottaDB types/constants,
object serialization and database statistics. DSL expressions are parsed by
Nim macros/templates; the literal variable structure is determined at compile
time, while runtime expressions such as subscripts and values are evaluated
when the operation runs.

---

## 1. Variables

| Kind | Syntax | Example |
|------|--------|---------|
| Global | `^name` | `^Customer` |
| Local | `name` | `tmp` |
| Intrinsic (special) | `$name` | `$JOB` |

Globals are persistent database variables; locals live in the current process;
intrinsic variables are read-only system values (a few, like `$ZMAXTPTIME()`,
can be written).

```nim
Set: ^Customer(4711) = "Lothar"   # global
Set: tmp = "hello"                # local
let pid = Get $JOB                # special variable (read)
Set: $ZMAXTPTIME() = "2"          # special variable (write)
```

---

## 2. Subscripts

Subscripts follow the variable name in parentheses and are separated by commas.
Up to **31** subscript levels are supported.

A subscript can be:

* a string literal: `^gbl("11")`
* an integer literal: `^gbl(11)`
* a float literal: `^gbl(1.1)`
* a variable: `^gbl(id)`
* any expression: `^gbl(id + 10)`, `^gbl($id)`
* a **sequence** (spread into multiple subscripts): `^gbl(@["5", "x"])` or `^gbl(subs)`

```nim
let id = 1
Set: ^X(id, "s") = "pi"          # mixed variable + string
let i = Get ^X(id, "i").int

let subs = @["4711", "Acct123"]
Set: ^CUST(subs) = 1500.50       # seq[string] spread into 2 subscripts
Set: ^CUST(@["4711", "Acct123"]) = 1500.50   # same, inline
```

Writing more than 31 subscripts raises a `YdbError`; exactly 31 is allowed.

---

## 3. Indirection (`@`)

Prefixing with `@` means *"the variable name comes from a Nim variable (or
expression) at run time"*, instead of being a literal.

```nim
let gbl = "^TMP(1,2,3)"          # full qualified name, subscripts included
Set: @gbl = "zz"
assert "zz" == Get @gbl

# Name + extra subscripts (name may itself contain subscripts)
let global = "^global(7)"
Set: @global("x") = "7"          # -> ^global(7,"x")
assert "7" == Get @global("x")

# Also works with quoted key strings
let v = Get @"^LL(HAUS,ELEKTRIK)"
```

Any expression evaluating to a string may be used after `@`.

---

## 4. `Set:` — write a value

Assigns a value to a global/local/special variable. It is a **statement** macro
(the `:` is required) and may contain **multiple** assignments:

```nim
Set: ^tmp = 1

Set:
    ^tmp1 = 1
    ^tmp2 = 2
    ^hello("users", "42", "name") = "Alice"
```

Values may be arbitrary Nim expressions:

```nim
let id = 123
Set: ^X(id, "Timestamp") = cpuTime()
Set: ^X(id, "Name") = "Lothar"
Set: ^X(id, "Amount") = 1500.50
```

---

## 5. `Get` — read a value

`Get` returns the stored value as a `string`:

```nim
Set: ^tmp = 1
assert "1" == Get ^tmp
assert "1" == Get(^tmp)          # parentheses optional
```

An empty string (`""`) is returned for a non-existent node.

### Type conversion postfixes

Append a postfix to read the value already converted to a Nim type. A missing
node yields `0` (or `false` for `.bool`):

| Postfix | Result type |
|---------|-------------|
| `.int` | `int` |
| `.int8` `.int16` `.int32` `.int64` | fixed-width ints |
| `.uint` `.uint8` `.uint16` `.uint32` `.uint64` | unsigned ints |
| `.float` `.float64` | floats |
| `.bool` | `bool` |
| `.seqString` `.seqInt` `.seqFloat` `.seqBool` | delimited sequence value → `seq[T]` |

```nim
Set: ^GBL("int") = int.high
assert int.high == Get ^GBL("int").int
assert 3.1414 == Get ^GBL("float").float

let os = @[1,2,3,4,5]
Set: ^gbl = join(os, ",")
assert os == Get ^gbl.seqInt
```

Out-of-range values raise `RangeDefect` / `ValueError`.

> `.float32` is currently **not** supported. The string postfix is
> `.seqString` (not `.seqStr`).

### Default value

```nim
let name = Get (^customer(123, "name"), default="<noname>")
```

If the node does not exist, the `default` value is returned.

---

## 6. `Data` — check existence / type

`Data` returns an `int` describing a node:

| Constant | Value | Meaning |
|----------|-------|---------|
| `YDB_DATA_UNDEF` | 0 | node does not exist |
| `YDB_DATA_VALUE_NODESC` | 1 | has a value, no descendants |
| `YDB_DATA_NOVALUE_DESC` | 10 | no value, has descendants |
| `YDB_DATA_VALUE_DESC` | 11 | has a value and descendants |

```nim
Set: ^X(1) = "hello"
assert Data(^X(1)) == YDB_DATA_VALUE_NODESC

Killnode: ^X(1)
assert Data(^X(1)) == YDB_DATA_UNDEF
```

`Data` may also be used with indirection:

```nim
let gbl = "^dta(4712)"
assert 1 == Data @gbl
```

---

## 7. `Increment` — atomic counter

Atomically increments a node and returns the new value:

```nim
Set: ^CNT("AUTO") = 1
let c = Increment ^CNT("AUTO")            # +1, returns 2
let c5 = Increment (^CNT("AUTO"), by=5)   # +5
```

Works on globals and locals; `by=` sets the increment amount (default `1`).

---

## 8. `Kill`, `Killnode`, `Delexcl` — deletion

* **`Kill:`** deletes a whole tree (variable and all descendants).
* **`Killnode:`** deletes a single node only.
* **`Delexcl:`** deletes *all* local variables **except** the listed ones.

```nim
Kill: ^X            # delete whole tree

Killnode:
    ^tmp2(1001)
    ^tmp2(1002)     # delete individual nodes

Killnode: @gbl      # via indirection

Delexcl: { DELTEST1, DELTEST3, DELTEST5 }   # keep only these locals
```

`Delexcl` only applies to local variables — global and special names are
rejected with a `YdbError`.

---

## 9. `Lock` — concurrency control

Locks up to 35 variables at once. Other processes trying to lock the same
variable block until the lock is released or a timeout expires.

```nim
# lock one variable
Lock: { ^CNT("TEMPLATE_TEST") }

# lock several variables
Lock: { ^CNT(id), ^CNT("ABC"), ^XYZ(123) }

# with a timeout (nanoseconds, or seconds with a decimal point)
Lock: { ^CNT(id), timeout=1 }
Lock: { timeout=0.5, ^CNT(id) }

# add / remove a single variable without releasing the others
Lock +^gbl
Lock -^gbl

# release all locks
Lock: {}
```

The default timeout is `YDB_LOCK_TIMEOUT` (~2.147 seconds). Values `> 2.147`
seconds are treated as the default. A lock that cannot be acquired raises
`YdbError` (`YDB_LOCK_TIMEOUT`).

Convenience wrapper:

```nim
withlock:                       # lock ^LOCKS(int.high) for the block
    Set: ^hello(subs) = 1500

withlock(4711):                 # lock ^LOCKS(4711) for the block
    ...
```

---

## 10. `Query` / `QueryItr` — traverse nodes

`Query` returns the **next node** in collating order (a fully qualified key like
`"^LL(HAUS)"`); `QueryItr` is its iterator form.

| Postfix | Result |
|---------|--------|
| *(none)* | next key as `string`, e.g. `"^LL(HAUS)"` |
| `.keys` | next key as `seq[string]`, e.g. `@["HAUS"]` |
| `.kv` | `(key, value)` tuple |
| `.sv` | `(subscripts, value)` tuple |
| `.val` | value only |
| `.count` | number of matching nodes |
| `.reverse` | traverse backwards |

```nim
echo Query ^LL                    # ^LL(HAUS)
echo Query ^LL("HAUS")            # ^LL(HAUS,ELEKTRIK)

echo Query ^LL("HAUS", "ELEKTRIK").reverse   # ^LL(HAUS)

for key in QueryItr ^LL:
    echo key                      # ^LL(HAUS), ^LL(HAUS,ELEKTRIK), ...

for subs in QueryItr ^hello.keys:
    echo subs                     # @["0"], @["1"], ...

for (key, value) in QueryItr ^hello.kv:
    echo key, "=", value

for (subs, value) in QueryItr ^hello.sv:
    echo subs, "=", value

for cnt in QueryItr ^hello.count:
    echo cnt
```

`Query`/`QueryItr` work on globals and locals, and accept indirection:

```nim
let gblname = "^hello"
for gbl in QueryItr @gblname:
    echo gbl

var gbl = Query ^hello
while gbl.len > 0:
    echo gbl
    gbl = Query @gbl             # advance using the returned key
```

---

## 11. `Order` / `OrderItr` — traverse subscripts

`Order` returns the **next subscript** at the last given level (a plain string
like `"HAUS"`); `OrderItr` is its iterator form.

| Postfix | Result |
|---------|--------|
| *(none)* | next subscript as `string` |
| `.key` | full key, e.g. `"^LL(HAUS,ELEKTRIK)"` |
| `.keys` | full key as `seq[string]` |
| `.kv` | `(key, value)` tuple |
| `.val` | value only |
| `.count` | number of matching subscripts |
| `.reverse` | traverse backwards |

```nim
echo Order ^LL                  # HAUS
echo Order ^LL("HAUS")          # LAND
echo Order ^LL("LAND").reverse  # HAUS

for key in OrderItr ^LL:
    echo key                    # HAUS, LAND, ORT

for key in OrderItr ^LL("HAUS", "").key:
    echo key                    # ^LL(HAUS,ELEKTRIK), ...

for subs in OrderItr ^LL("HAUS", "").keys:
    echo subs                   # @["HAUS", "ELEKTRIK"], ...

for value in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").val:
    echo value                  # Telefondose, Steckdose, ...

for key, value in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").kv:
    echo key, "=", value
```

> Use an empty trailing subscript (`""`) with `OrderItr` to iterate over the
> children of a node. `Order .key` is **not** available for `Query`.

---

## 12. `CallM` — Call-In interface

Calls an M routine registered in the call-in table (`ydb_ci`), exchanging data
through the local variable `CTX`. The result is read back from `RESULT`.

```nim
# single argument -> CTX
let result = CallM method2("Hello World")
assert result == "TheResultFrom YDB CTX=Hello World"

# multiple arguments -> CTX(1), CTX(2), ...
CallM method3("a", "b", "c", "d")

# JSON object -> CTX(sub1, sub2, ...)
let data = parseJson("""{ "total": 10, "name": "Lothar" }""")
CallM method1(data)
```

For an example call-in table and M routines see `src/tests/callin.nim`.

---

## 13. `Transaction` — atomic transactions

Wraps a block in a YottaDB transaction. If a concurrent update conflicts, the
block is re-run automatically (up to 4 restarts).

```nim
let rc = Transaction:
    Set: ^AAA(1) = "transaction1"
    Set: ^AAA(2) = "transaction2"
```

`Transaction` can take an optional parameter, which is made available in the
body as the injected symbol `param`. Strings and integers are passed through
YottaDB's callback parameter directly; cast them to the desired representation
inside the body:

```nim
let rc = Transaction("4711B"):
    let nbr = $cast[cstring](param)
    let id = Increment ^IDS("customer")
    Set: ^Customer(id, "account", nbr) = "Data"
```

Other parameter types `T` (for example, an object) are copied into a local
variable for the duration of the transaction call and passed to the callback
by address. Read the value in the body by casting `param` to `ptr T` and
dereferencing it:

```nim
type TxInput = object
    customerId: int
    account: string

let input = TxInput(customerId: 4711, account: "A-42")
let rc = Transaction(input):
    let txInput = cast[ptr TxInput](param)[]
    Set: ^Customer(txInput.customerId, "account") = txInput.account
```

The pointer is valid only while the transaction call is active. Treat the
parameter as input: YottaDB may re-run the transaction body after a conflict,
so avoid relying on mutations to the parameter or performing non-transactional
side effects in the body. A `pointer` parameter is passed through unchanged.

Object serialization with `saveObject` and `loadObject` also works inside a
`Transaction`; the database operations participate in the transaction. You can
construct the object in the transaction body or pass an object as the
transaction parameter:

```nim
type Dummy = object
    name: string
    age: int

var rc = Transaction:
    let obj = Dummy(name: "lothar", age: 100)
    saveObject[Dummy](4711, obj)

let input = Dummy(name: "martina", age: 99)
rc = Transaction(input):
    let obj = cast[ptr Dummy](param)[]
    saveObject[Dummy](4712, obj)
```

This is the pattern used in
[`transaction_bingoser.nim`](../src/tests/transaction_bingoser.nim). The
parameter is passed by address as described above; the serialization itself
uses the current transaction context, so a committed transaction makes the
saved object available to `loadObject`.

Return value: `YDB_OK` on success, `YDB_TP_ROLLBACK` when rolled back. Raising an
exception requests a restart (`YDB_TP_RESTART`).

Compiled with `--threads:on`, the transaction runs multi-threaded; inside the
body the following are injected: `tptoken`, `errstr`, `param`. In single-threaded
mode only `param` is injected.

---

## 14. Binary data & large records

`Set`/`Get` handle arbitrary binary `string`s transparently — no special
postfix is needed. Records larger than the 1 MB internal buffer are stored in
blocks and reassembled automatically:

```nim
Set: ^tmp("binary") = createBinData(1024)   # 1 KB of binary bytes
let data = Get ^tmp("binary")               # identical bytes back
assert data == createBinData(1024)
```

---

## 15. Direct `ydbimpl.nim` API

The direct API uses a mutable `YdbKey` instead of parsing DSL expressions.
Create a key with a variable name and zero or more string subscripts, then pass
it to the `ydb_*` wrappers. Reuse the key for repeated operations to avoid
rebuilding it:

```nim
var key = initYdbKey("^orders", "customer", "42")
ydb_set(key, "open")
assert ydb_get(key) == "open"
assert ydb_data(key) == YDB_DATA_VALUE_NODESC

discard ydb_increment(key, 1)
ydb_delete(key, YDB_DEL_NODE)
```

`initYdbKey` accepts subscripts as strings (or one `Subscripts` sequence).
For numeric or other values, convert them to strings, or use the `setSub` /
`addSub` helpers, which also accept integers, floats and booleans. The
`YdbKey` accessors include `setName`, `setSub`, `addSub`, `delSub`,
`setSubsLen`, `clearSubs`, `globalName`, `subscript`, `subscripts` and
`subCount`. Prefer these helpers over assigning the public buffer fields
directly.

### Direct operations

| Wrapper | Purpose |
|---------|---------|
| `ydb_get(key)` / `ydb_set(key, value)` | Read or write a node; `ydb_get` returns `""` when a local/global node has no value. |
| `ydb_data(key)` | Return the node state (`YDB_DATA_*`, also used by `Data`). |
| `ydb_delete(key, YDB_DEL_NODE)` | Delete only the node value. |
| `ydb_delete(key, YDB_DEL_TREE)` | Delete the node and all descendants. |
| `ydb_increment(key, amount = 1)` | Atomically increment and return the resulting integer. |
| `ydb_delete_excl(names)` | Delete all local variables except the listed names. |
| `ydb_lock(timeoutNsec, keys)` | Acquire the specified locks; timeout is in nanoseconds. |
| `ydb_lock_incr(timeoutNsec, key)` / `ydb_lock_decr(key)` | Increment or decrement one lock's count. |
| `ydb_ci(name)` | Call an M call-in routine without arguments; exchange data via local variables. |
| `str2zwr(value)` / `zwr2str(value)` | Convert to or from YottaDB's zwrite representation. |
| `ydb_tp(callback, param, transid)` | Run a single-threaded transaction callback. |
| `ydb_tp_mt(callback, param, transid)` | Run a multi-threaded transaction callback. |
| `ydbMessage(status)` | Format a YottaDB status code as a message. |

For `ydb_lock`, each entry in `keys` is a `Subscripts` sequence whose first
element is the variable name, followed by its subscripts. An empty `keys`
sequence releases all locks. At most `YDB_MAX_NAMES` (35) locks can be
requested together.

### Direct traversal

The `ydb_node_*` wrappers move a `YdbKey` cursor to the next or previous node
in collating order. `ydb_subscript_*` move it through subscripts at the current
level. The status-returning overloads report `YDB_OK` for an item and
`YDB_ERR_NODEEND` when traversal is complete; they raise `YdbError` for other
YottaDB errors. The key remains at the last returned item, so subsequent calls
continue from that position:

```nim
var cursor = initYdbKey("^orders")
var status = ydb_node_next(cursor)
while status == YDB_OK:
  echo $cursor, " = ", ydb_get(cursor)
  status = ydb_node_next(cursor)

var children = initYdbKey("^orders", "customer", "")
var child: string
while ydb_subscript_next(children, child) == YDB_OK:
  echo child
```

`ydb_subscript_next(key)` and `ydb_subscript_previous(key)` also have
string-returning convenience overloads. Use the status-returning overload when
an empty subscript must be distinguished from the end of traversal.

### Statuses, errors and limits

`YDB_OK` is zero. The `YDB_DATA_UNDEF`, `YDB_DATA_VALUE_NODESC`,
`YDB_DATA_NOVALUE_DESC` and `YDB_DATA_VALUE_DESC` constants describe node
existence and descendants as shown in the [`Data` section](#6-data--check-existence--type).
The public error/status constants include `YDB_ERR_GVUNDEF`,
`YDB_ERR_NODEEND`, `YDB_ERR_TPTIMEOUT`, `YDB_TP_RESTART`,
`YDB_TP_ROLLBACK` and `YDB_LOCK_TIMEOUT`.

YottaDB failures raised by the wrappers use `YdbError`; transaction control
statuses may raise `TpRestart` or `TpRollback`. Up to `YDB_MAX_SUBS` (31)
subscripts and `YDB_MAX_NAMES` (35) names are supported. Values larger than
`YDB_MAX_BUF_SIZE` (1 MiB) are split into internal child nodes and transparently
reassembled by `ydb_get`; avoid directly using the reserved child-subscript
space for your own data. Reading a special variable that has no value also
raises `YdbError`.

Build with `--threads:on` to use YottaDB's threaded entry points. The
`ydb_tp_mt` callback receives the transaction token, error buffer and parameter;
the ordinary `ydb_tp` callback receives the parameter. For most transaction
code, the [`Transaction` DSL](#13-transaction--atomic-transactions) handles
callback setup and retries more conveniently.

## 16. Serialization

`yottadb` re-exports the object serialization helpers from `bingoser.nim`.
They store Nim objects in YottaDB globals, using object field names as
subscripts. By default, an object of type `Customer` is stored under
`^Customer`; the id (or subscript path) identifies one object record.

```nim
type Customer = object
  id: int
  name: string
  active: bool
  tags: seq[string]

let customer = Customer(
  id: 4711,
  name: "Alice",
  active: true,
  tags: @["new", "priority"]
)

saveObject(customer.id, customer)
let restored = loadObject[Customer](customer.id)
assert restored == customer

deleteObject[Customer](customer.id)
```

### Save, load and delete

The exported operations accept a sequence of subscripts or a single integer or
string id:

```nim
saveObject(@["tenant-a", "4711"], customer)
let restored = loadObject[Customer](@["tenant-a", "4711"])
deleteObject[Customer](@["tenant-a", "4711"])
```

`saveObject` and `loadObject` take an optional `globalName` parameter. The
default is the Nim type name with a leading `^`; either `"Customer"` or
`"^Customer"` can be supplied explicitly:

```nim
saveObject("4711", customer, "^CUSTOMER_RECORDS")
let restored = loadObject[Customer]("4711", "^CUSTOMER_RECORDS")
```

`loadObject` returns a default-initialized object when the requested record
does not exist. Fields are matched by their Nim field names. Extra fields in
the database are ignored, and missing fields generally retain their default
values, which allows adding or removing fields without making old records
unreadable. Renaming a field changes its stored subscript and is therefore a
data migration.

Nested object values are stored in globals named for their own object type;
sequences are stored under indexed subscripts. Scalar fields, nested objects,
and sequences of strings and objects are exercised by the project examples and
tests. `bingoser.nim` also has handlers for numeric and boolean values,
characters, enums, options, tuples, arrays and set-like collections. As with
any generic serializer, test the exact field/container type combinations used
by your application before relying on them.

`saveObject` writes the fields in the supplied object; it does not first remove
unknown fields or old sequence entries from the database. When replacing a
record with a different shape, delete it first if stale child nodes must not
remain:

```nim
deleteObject[Customer](customer.id)
saveObject(customer.id, customer)
```

### Secondary indexes

Fields can declare an index with the `INDEX` pragma. The pragma value names the
field that contains the record id:

```nim
type Customer = object
  id: int
  name: string
  email {.INDEX: "id".}: string

let customer = Customer(id: 4711, name: "Alice", email: "alice@example.com")
saveObject(customer.id, customer)
```

Saving creates an index global named by appending the upper-cased indexed field
name to the object type's global name. The index value is empty; its subscripts
are the indexed value and then the referenced id. For the example, the entry
is stored at `^CustomerEMAIL("alice@example.com","4711")`. `deleteObject`
removes index entries for the object's current field values along with its
record.

When an indexed field changes, explicitly remove the old index entry before
saving the new value; `saveObject` adds the new entry but does not discover and
remove an old value automatically. A straightforward approach is to delete the
old record (which also removes its current indexes) and then save the updated
object.

See [`serialization_test.nim`](../src/tests/serialization_test.nim) for a
round-trip example, and [`clientser.nim`](../src/examples/clientser.nim) for
examples with nested objects, sequences and sets.

## 17. Related utilities (outside the DSL)

These are also re-exported by `yottadb` and are commonly used with the DSL:

* `str2zwr` / `zwr2str` — convert binary strings to/from YottaDB's zwrite format
  (`ydbimpl.nim`).
* `newYdbVar`, `$`, `[]=` — object-style access to a node:

  ```nim
  var customer = newYdbVar("^Customer", @["4711", "name"])
  customer[] = "Alice"
  assert $customer == "Alice"
  ```

* `gzip`, `zlib`, `lz4`, `zstd` — compress strings or sequences before storing
  them. Read compressed values with the matching `Get` postfix:

  ```nim
  Set: ^payload = gzip("record")
  assert Get ^payload.gzip == "record"
  ```

  Sequence postfixes can be combined with compression postfixes, for example
  `Get ^numbers.seqInt.zstd`.

---

## Appendix: quick reference

| Statement | Purpose | Example |
|-----------|---------|---------|
| `Set:` | write | `Set: ^gbl(1) = "x"` |
| `Get` | read | `Get ^gbl(1).int` |
| `Data` | existence/type | `Data ^gbl(1)` |
| `Increment` | atomic counter | `Increment ^CNT("AUTO")` |
| `Kill:` | delete tree | `Kill: ^gbl` |
| `Killnode:` | delete node | `Killnode: ^gbl(1)` |
| `Delexcl:` | delete locals except | `Delexcl: {A, B}` |
| `Lock` | locks | `Lock: { ^gbl(1), timeout=1 }` |
| `Query` / `QueryItr` | next node | `Query ^gbl` |
| `Order` / `OrderItr` | next subscript | `Order ^gbl("k")` |
| `CallM` | call-in | `CallM method2("x")` |
| `Transaction` | atomic block | `Transaction: ...` |
| `withlock` | scoped lock | `withlock: ...` |

Global: `^name` · Local: `name` · Special: `$name` · Indirection: `@expr`

# nim-yottadb DSL — User Guide

This document describes the **DSL** (domain-specific language) implemented in
[`src/libs/dsl.nim`](../src/libs/dsl.nim). The DSL provides a compact, Nim-native
syntax for reading and writing **YottaDB** global variables, local variables and
intrinsic (special) variables, without having to deal with the low-level C API.

Everything is available through a single import:

```nim
import yottadb
```

> **Important**: every operation below is a **macro**. Literal parts of the
> expression are resolved at *compile time* into a `YdbVar`; only the runtime
> values (subscripts, values, indirection targets) are evaluated at run time.

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
| `.seqStr` `.seqInt` `.seqFloat` `.seqBool` | comma-separated value → `seq[T]` |

```nim
Set: ^GBL("int") = int.high
assert int.high == Get ^GBL("int").int
assert 3.1414 == Get ^GBL("float").float

let os = @[1,2,3,4,5]
Set: ^gbl = join(os, ",")
assert os == Get ^gbl.seqInt
```

Out-of-range values raise `RangeDefect` / `ValueError`.

> `.float32` is currently **not** supported.

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

Pass a `string` parameter into the transaction:

```nim
let rc = Transaction("4711B"):
    let nbr = $cast[cstring](param)
    let id = Increment ^IDS("customer")
    Set: ^Customer(id, "account", nbr) = "Data"
```

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

## 15. Related utilities (outside the DSL)

These live outside `dsl.nim` but are commonly used together with the DSL:

* `str2zwr` / `zwr2str` — convert binary strings to/from YottaDB's zwrite format
  (`libs/ydbimpl.nim`).
* `saveObject` / `loadObject` — object (de)serialization into globals
  (`libs/bingoser.nim`).
* `newYdbVar`, `$`, `[]=` — object-style access to a node (`yottadb.nim`).

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

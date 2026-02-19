# DSL Statements and Expressions

## setvar / Get / .binary
```nim
Set:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"
```
Get already converted Data (string/int/float)

# DSL Statements and Expressions

## setvar / Get / .binary
```nim
Set:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"
```
Get already-converted Data (string/int/float)
```nim
let subs = @["4711", "Acct123"]
Set: ^CUST(subs) = 1500.50
var amount = Get ^CUST(subs).float
amount += 1500.50
Set: ^CUST(subs) = amount
let dbamount = Get ^CUST(subs).float  # read from db
assert dbamount == amount
```

Set with mixed variable and string subscripts
```nim
let id = 1
Set: ^X(id, "s") = "pi"
let s = Get ^X(id, "s")
assert s == "pi"
Set: ^X(id, "i") = 3
let i = Get ^X(id, "i").int
assert i == 3
Set: ^X(id, "f") = 3.1414
let f = Get ^X(id, "f").float
assert f == 3.1414
```

Set: in a loop
```nim
for id in 0..<5:
  let tm = cpuTime()
  Set: ^CUST(id, "Timestamp") = tm
  let s = Get ^CUST(id, "Timestamp").float
  assert s == tm
```

Up to 31 index levels are possible
```nim
Set: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"Z")="xxx"
```

nim-yottadb supports binary Data and can handle very large record sizes (practically limited by available memory). You can read back binary Data with the `.binary` postfix.
```nim
let image = Get ^images(4711).binary
```

## Get - 'default'
Get supports a `default` value:
```nim
let name = Get (^customer(123,"name"), default="<noname>")
let discount = Get (^account(123,"discount"), default=2.75).float
```
The global variable with its subscripts will be automatically created if it does not yet exist.

## Increment
Atomic Increment of a global in the database
```nim
let incrval = Increment: ^CNT("TXID")
let c5 = Increment: (^CNT("AUTO"), by=5)
```

## Data
Test whether a node or tree exists and whether it has descendants
```nim
Set:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  
var dta = Data: ^X(0)
assert YdbData(dta) == YDB_DATA_UNDEF
dta = Data: ^X(6)
assert YdbData(dta) == YDB_DATA_VALUE_NODESC
dta = Data: ^X(5)
assert YdbData(dta) == YDB_DATA_NOVALUE_DESC
dta = Data: ^X(7)
assert YdbData(dta) == YDB_DATA_VALUE_DESC
```

## Killnode
Delete a single node. If all nodes of a variable are removed, the variable itself is removed.
No descendants are removed.
```nim
Set: ^X(1)="hello"
Killnode: ^X(1) # delete only this node
```

## Kill
Delete a subtree of a variable. If all nodes are removed, the variable itself is removed.
```nim
Set: ^X(1,1)="hello"
Set: ^X(1,2)="world"
let dta = Data: ^X(1) # returns 10 (no Data but subtree)
Kill: ^X(1)
```

## Lock
Lock up to 35 global variables at once. Other processes trying to Lock one of the globals will wait until the Lock is released or until a timeout expires.

Use `{}` to enclose multiple variables and an optional `timeout` value. An empty `{}` releases all locks.

`timeout` is specified in nanoseconds and defines how long to wait for a Lock. The default is `2147483643` nanoseconds (the value of `YDB_LOCK_TIMEOUT`). You may also specify the timeout in seconds with a decimal point; values greater than 2.147 seconds are treated as the default.

Locks are visible within each thread, and global locks affect processes on the same host.

By default, each new `Lock` operation replaces previous locks. You can add or remove a single variable from the current Lock set using `+` and `-` without releasing the other locks.
```nim
# Lock one variable at a time. This replaces previous locks
Lock localvar
Lock lclv(4711)
Lock ^globalvar
Lock ^gbl(4711)

# Lock multiple variables at once (use braces)
Lock:
  {
    ^LL("HAUS", "11"),
    ^LL("HAUS", "12"),
    ^LL("HAUS", "XX"), # not yet existent, but OK
  }
assert 3 == getLockCountFromYottaDb()
Lock: {} # release all locks
assert 0 == getLockCountFromYottaDb()

var id = 4711
# Set a timeout value in seconds
Lock { ^CNT(id), timeout=0.5 }

# Add or remove an individual Lock without releasing others
Lock +^gbl # add Lock
Lock -^gbl # remove only ^gbl from locks
Lock +lclv # add Lock for local variable
```

## Query
Traverse the global and get the next node in the collating sequence.
```nim
echo Query ^LL
# ^LL(HAUS)
echo Query ^LL("HAUS")
# ^LL(HAUS, ELEKTRIK)
```

## Query.reverse
Traverse the global backward and get the previous node in the collating sequence.
```nim
echo Query ^LL("HAUS", "ELEKTRIK", "DOSEN", "1").reverse
# ^LL(HAUS,ELEKTRIK,DOSEN)
echo Query ^LL("HAUS", "ELEKTRIK").reverse
# ^LL(HAUS)
```

## Order
Traverse the globals at a given index level.
```nim
echo Order ^LL
# HAUS
echo Order ^LL("HAUS")
# LAND
```

## Order.reverse
Traverse the globals backwards at a given index level.
```nim
echo Order ^LL("LAND").reverse
# HAUS
```
## QueryItr
```nim
for key in QueryItr ^LL:
  echo key
  # ^LL(HAUS)
  # ^LL(HAUS,ELEKTRIK)
  # ^LL(HAUS,ELEKTRIK,DOSEN)
  # ^LL(HAUS,ELEKTRIK,DOSEN,1)
  # ^LL(HAUS,ELEKTRIK,DOSEN,2)
```
## OrderItr
```nim
for key in OrderItr ^LL:
  echo key
  # HAUS
  # LAND
  # ORT

for key in OrderItr ^LL("HAUS",""):
  echo key
  # ELEKTRIK
  # FLAECHEN
  # HEIZUNG
```
## Iterator postfix
For both `Order` and `Query` there are iterators which simplify access.
With a postfix notation the value returned by the iterator can be controlled:
- .key - Return the full subscripted key (e.g. ^Customer(1,"Name"))
- .keys - Return the full key as `seq[string]` (e.g. @["1", "Name"])
- .kv - Return the key and the value as a tuple (key, value)
- .val - Return the value for the key
- .reverse - Traverse in backward direction
- .count - Return the number of entries
```nim
for key in OrderItr ^LL:
  echo key
  # HAUS
  # LAND
  # ORT

for key in OrderItr ^LL("HAUS", "").key:
  echo key
  # ^LL(HAUS,ELEKTRIK)
  # ^LL(HAUS,FLAECHEN)
  # ^LL(HAUS,HEIZUNG)

for key in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").key:
  echo key, "=", Get @key
  # ^LL(HAUS,ELEKTRIK,DOSEN,1)=Telefondose
  # ^LL(HAUS,ELEKTRIK,DOSEN,2)=Steckdose
  # ^LL(HAUS,ELEKTRIK,DOSEN,3)=IP-Dose
  # ^LL(HAUS,ELEKTRIK,DOSEN,4)=KFZ-Dose

for subs in OrderItr ^LL("HAUS", "").keys:
  echo subs
  # @["HAUS", "ELEKTRIK"]
  # @["HAUS", "FLAECHEN"]
  # @["HAUS", "HEIZUNG"]

for value in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").val:
  echo value
  # Telefondose
  # Steckdose
  # IP-Dose
  # KFZ-Dose

for key, value in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").kv:
  echo key, "=", value
  # 1=Telefondose
  # 2=Steckdose
  # 3=IP-Dose
  # 4=KFZ-Dose

for cnt in OrderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").count:
  echo cnt
  # 4
```

## str2zwr
Save binary Data through YottaDB's API. This API is provided for compatibility; for most modern use cases the `binary` postfix is the preferred approach.
```nim
let x = str2zwr("hello\9World")
assert str2zwr("hello\9World") == """"hello""_$C(9)_"""World""""
```
Use the `binary` postfix as an alternative for binary Data.

## zwr2str
Read back Data stored in the `str2zwr` format.
```nim
assert zwr2str(""""hello""_$C(9)_"""World"""") == "hello\9World"
```
The `str2zwr` and `zwr2str` functions exist for compatibility. For new applications prefer the `binary` postfix or other modern APIs. The historical 1 MB record-size limit no longer applies; nim-yottadb can handle much larger records, practically limited by available memory. A streaming interface may be provided in the future to support effectively unlimited record sizes.

# 'Get' with postfix
You can enforce an expected type when reading Data from YottaDB using a postfix. If the stored value is out of the specified type range, a `ValueError` is raised.
```nim
let i = Get ^global(1).int16
let f = Get ^global(4711).float32
let u = Get ^global(815).uint8
```
Supported postfixes include:
- int, int8, int16, int32, int64
- uint, uint8, uint16, uint32, uint64
- float, float32, float64

# .OrderedSet Postfix
Allows reading back an `OrderedSet` saved as a string. The saved form may be `{9, 5, 1}` or the more efficient `9,5,1`; the `.OrderedSet` postfix handles both formats.
```nim
var os = toOrderedSet([9, 5, 1])
# os: {9, 5, 1}
Set: ^tmp("set1") = $os
let osdb: OrderedSet[int] = Get ^tmp("set1").OrderedSet
assert osdb == os
```
Currently only `int` is supported for this postfix. This feature is experimental and may change or be removed in the future.

# Local Variables
All methods available for globals can also be applied to local variables.

```nim
Set:
  myvar(1) = 1
  myvar("a") = "..."
  myvar(@[id, "4711"]) = "..."
  # and so on
```

# Special Variables
To read a special variable, use `Get`:
```nim
let zversion = Get $ZVERSION
echo zversion
```
To set a special variable via the DSL use `Set:` with empty parentheses `()`:
```nim
Set: $ZMAXTPTIME() = "2"
```

# Transactions
`Transaction` supports both single-threaded and multi-threaded transactions.

For single-threaded transactions use:
```nim
let rc = Transaction:
  Set: ^AAA(1) = "transaction1"
```
If the transaction succeeds, `rc` is `YDB_OK`; if it is rolled back due to an error, `rc` is `YDB_TP_ROLLBACK`. Returning `YDB_TP_RESTART` from the transaction body requests a restart; returning `YDB_TP_ROLLBACK` aborts and rolls back the transaction.

YottaDB detects concurrent changes to underlying blocks and will retry the transaction (re-running the code block) up to 3 times. If the contention persists it falls back to pessimistic locking to allow the transaction to commit.

If a `Transaction` raises an exception, the macro returns `YDB_TP_RESTART` to retry. If the issue persists beyond the retry limit, the transaction is aborted with `YDB_TP_ROLLBACK`. See `src/tests/transaction` for an example.

You can pass a single `string` parameter to `Transaction("ABC")`. Inside the body cast `param` to `cstring` to access it:
```nim
# single-threaded (--threads:off)
let rc = Transaction("ABC"):
  let s = $cast[cstring](param)
  Set: ^gbl(101, s) = "Data"
```

In single-threaded mode you may use both the API and the DSL inside the transaction body (e.g. `ydb_set`, `setvar`, or using a dynamic global name via `let gbl = "^AAA"` and `Set: @gbl(4) = "..."`).

For multi-threaded transactions you must pass the `tptoken` parameter to YottaDB API calls. DSL-style `setvar` is not currently supported inside multi-threaded `Transaction` bodies; use the API form (`ydb_set(..., tptoken)`). If `tptoken` is omitted in a multi-threaded context, the call will block.
```nim
# multi-threaded (--threads:on)
let rc2 = Transaction(4712):
  let id = $cast[cint](param)
  ydb_set("^gbl", @[id], "Data", tptoken)
```

Inside the multi-threaded transaction body you have access to:
- `tptoken`: uint64
- `errstr`: ptr struct_ydb_buffer_t
- `param`: pointer

Transactions commit automatically at the end of their scope. For an example of `Transaction` usage see `m/bidwars.nim`. 



If you need access to variables outside the `Transaction` scope then the variable must be in Nim's global scope:
```bash
var somedata = "ABC"
proc doTransaction() =
    let somevar = "DEF"
    let rc = Transaction:
        Set: ^Data(4711) = somedata
        # Set: ^Data(4712) = somevar # this will NOT work
```
Instead you can use YottaDB's local variables to pass Data between your proc and the Transaction scope:
```bash
Set: ctx("somedata") = "ABC"
proc doTransaction() =
    let rc = Transaction:
        Set: ^Data(4711) = Get ctx("somedata")
```

For background on YottaDB multi-threaded transactions read the YottaDB docs: https://docs.yottadb.com/MultiLangProgGuide/programmingnotes.html#threads-txn-proc
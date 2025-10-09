# DSL Statements and Expressions

## setvar / get / getblob
```nim
setvar:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"
```
Get already converted data (string/int/float)
```nim
let subs = @["4711", "Acct123"]
setvar: ^CUST(subs) = 1500.50
var amount = get: ^CUST(subs).float
amount += 1500.50
setvar: ^CUST(subs) = amount
let dbamount = get: ^CUST(subs).float  # read from db
assert dbamount == amount
```

Set with mixed variable and string subscripts
```nim
let id = 1
setvar: ^X(id, "s") = "pi"
let s = get: ^X(id, "s")
assert s == "pi"
setvar: ^X(id, "i") = 3
let i = get: ^X(id, "i").int
assert i == 3
setvar: ^X(id, "f") = 3.1414
let f = get: ^X(id, "f").float
assert f == 3.1414
```

setvar: in a loop
```nim
for id in 0..<5:
  let tm = cpuTime()
  setvar: ^CUST(id, "Timestamp") = tm
  let s = get: ^CUST(id, "Timestamp").float
  assert s == tm
```

Upto 31 Index-Levels are possible
```nim
setvar: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"Z")="xxx"
```

nim-yottadb supports binary data with a max recordsize of 99999999 MB. You can read back binary data with `getblob`
```nim
let image = getblob(^images(4711))
```

## increment
Atomic increment a global in the database
```nim
let rc = delnode: ^CNT("TXID")
var incrval = increment: ^CNT("TXID")
assert 1 == incrval
incrval = increment: ^CNT("TXID", by=10)
assert 11 == incrval
```

## data
Test if a node or tree exists and has a subtree
```nim
setvar:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  
  var dta = data: ^X(0)
  assert YdbData(dta) == YDB_DATA_UNDEF
  dta = data: ^X(6)
  assert YdbData(dta) == YDB_DATA_VALUE_NODESC
  dta = data: ^X(5)
  assert YdbData(dta) == YDB_DATA_NOVALUE_DESC
  dta = data: ^X(7)
  assert YdbData(dta) == YDB_DATA_VALUE_DESC
```

## delnode
Delete a node. If all nodes of a global are removed, the global itself is removed.
```nim
setvar: ^X(1)="hello"
var rc = delnode: ^X(1) # delete node
```

## deltree
Delete a subtree of a global. If all nodes are removed, the global itself is removed.
```nim
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  let dta = data: ^X(1) # returns 10 (no data but subtree)
  rc = deltree: ^X(1)
```

## lock
Lock upto 35 Global variables at once. Other processes trying to lock one of the globals will wait until the lock is released or a timeout expires. 

A {} has to be used to enclose more than one variable and an optional `timeout` value. 

A empty {} will release all locks.

A `timeout` defines the time in nsec how long to wait for a lock.
Defaults to 2147483643 nano seconds, the value of YDB_LOCK_TIMEOUT.
The `timeout` value can also be specified in seconds with a decimal point. Values > 2.147 seconds are set to the default.

Locks are visible in each Thread. Global lock's affects each process on the same host.

Each new lock operation releases earlier locks.

A single variable can be added or removed to the lock table with '+' or '-' without releasing earlier locks.

```nim
# Lock one variable at the time. Release old locks
lock localvar
lock lclv(4711)
lock ^globalvar
lock ^gbl(4711)

# Lock multiple variables at once
lock:
  {
    ^LL("HAUS", "11"),
    ^LL("HAUS", "12"),
    ^LL("HAUS", "XX"), # not yet existent, but ok
  }
assert 3 == getLockCountFromYottaDb()
lock: {} # release all locks
assert 0 == getLockCountFromYottaDb()

var id = 4711
# Set a timeout value in seconds
lock { ^CNT(id), timeout=0.5 }

lock +^gbl # add lock without releasing old locks
lock -^gbl # release only ^gbl from locks
lock +lclv # add lock for local variable
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
var (rc, subs) = nextsubscript: ^images(@[""]) # -> @["223"]
while rc == YDB_OK:
   let path    = get(^images(subs, "path"))
   # do something with path
   (rc, subs) = nextsubscript: ^images(subs)
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
The `str2zwr`and `zwr2str` methods are available for compatibility reasons only. For new applications there is no need. The database limit of 1MB for record size is no longer in effect. nim-yottadb handles larger record sizes up to 99_999_999 MB. The size is only limited due to memory constraints.
In the future there will be a `stream-interface`to handle virtual unlimited record sizes.

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

# .OrderedSet Postfix
Allows to read back a OrderedSet.
When the string form '$' is saved then the saved data looks normally like `{9, 5, 1}`. The data may also be stored in the form `9,5,1` which is more efficient. The .OrderedSet postfix handles both forms.
```nim
  var os = toOrderedSet([9, 5, 1])
  # os: {9, 5, 1}
  setvar: ^tmp("set1") = $os
  let osdb: OrderedSet[int] = get: ^tmp("set1").OrderedSet
  assert osdb == os
```
In the momemnt, only type 'int' is implemented for this postfix.
It's experimental and may be removed in the future.

# Local Variables
All methods available for globals can also be applied for local variables.

```nim
setvar:
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

To set a special variable via the DSL, use setvar:
It is important to use an empty bracket ().
```nim
  setvar: $ZMAXTPTIME()="2"
```
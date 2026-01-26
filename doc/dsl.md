# DSL Statements and Expressions

## setvar / getvar / .binary
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
var amount = getvar  ^CUST(subs).float
amount += 1500.50
setvar: ^CUST(subs) = amount
let dbamount = getvar  ^CUST(subs).float  # read from db
assert dbamount == amount
```

Set with mixed variable and string subscripts
```nim
let id = 1
setvar: ^X(id, "s") = "pi"
let s = getvar  ^X(id, "s")
assert s == "pi"
setvar: ^X(id, "i") = 3
let i = getvar  ^X(id, "i").int
assert i == 3
setvar: ^X(id, "f") = 3.1414
let f = getvar  ^X(id, "f").float
assert f == 3.1414
```

setvar: in a loop
```nim
for id in 0..<5:
  let tm = cpuTime()
  setvar: ^CUST(id, "Timestamp") = tm
  let s = getvar  ^CUST(id, "Timestamp").float
  assert s == tm
```

Upto 31 Index-Levels are possible
```nim
setvar: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"Z")="xxx"
```

nim-yottadb supports binary data with a max recordsize of 99999999 MB. You can read back binary data with `.binary`
```nim
let image = getvar ^images(4711).binary
```
=======
## getvar - 'default'
getvar supports a 'default' value:
```nim
let name = getvar (^customer(123,"name"), default="<noname>")
let discount = getvar (^account(123,"discount"), default=2.75).float
```
The global variable with it's subscripts will be automatically created.

## increment
Atomic increment a global in the database
```nim
let incrval = increment: ^CNT("TXID")
let c5 = increment: (^CNT("AUTO"), by=5)
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

## killnode
Delete a node. If all nodes of a variable are removed, the variable itself is removed.
No descendents are removed.
```nim
setvar: ^X(1)="hello"
killnode: ^X(1) # delete only this node
```

## kill
Delete a subtree of a variable. If all nodes are removed, the variable itself is removed.
```nim
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  let dta = data: ^X(1) # returns 10 (no data but subtree)
  kill: ^X(1)
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

## query
Traverse the global and get the next node in the collating sequence.
```nim
echo query ^LL
^LL(HAUS)
echo query ^LL("HAUS")
^LL(HAUS, ELEKTRIK)
```

## query.reverse
Traverse the global backward and get the previous node in the collating sequence.
```nim
echo query ^LL("HAUS", "ELEKTRIK", "DOSEN", "1").reverse
^LL(HAUS,ELEKTRIK,DOSEN)
echo query ^LL("HAUS", "ELEKTRIK").reverse
^LL(HAUS)
```

## order
Traverse on the globals on a given index level.
```nim
echo order ^LL
HAUS
echo order ^LL("HAUS")
LAND
```

## order.reverse
Traverse the globals backwards on a given index level.
```nim
echo order ^LL("LAND").reverse
HAUS
```
## queryItr
```nim
for key in queryItr ^LL:
  echo key
^LL(HAUS)
^LL(HAUS,ELEKTRIK)
^LL(HAUS,ELEKTRIK,DOSEN)
^LL(HAUS,ELEKTRIK,DOSEN,1)
^LL(HAUS,ELEKTRIK,DOSEN,2)
...
```
## orderItr
```nim
for key in queryItr ^LL:
  echo key
HAUS
LAND
ORT
for key in queryItr ^LL("HAUS",""):
  echo key
ELEKTRIK
FLAECHEN
HEIZUNG
```
## Iterator postfix
For both `order` and `query` there exists an iterator which simplifies the access further.
With a postfix notation the value returned by the iterator can be controlled:
- .key - Return the full subscripted key (^Customer(1,Name))
- .keys - Return the full key as seq[string] (@["1", "Name"])
- .kv - Return the key and the value as tuple (^Customer(1,"Name", "Lothar")
- .val - Returns the value for the key 
- .reverse - Traverses in backward direction
- .count - Count the number of entries
```nim
for key in orderItr ^LL:
    echo key 
HAUS
LAND
ORT

for key in orderItr ^LL("HAUS","").key:
    echo key 
^LL(HAUS,ELEKTRIK)
^LL(HAUS,FLAECHEN)
^LL(HAUS,HEIZUNG)

for key in orderItr ^LL("HAUS", "ELEKTRIK", "DOSEN", "").key:
    echo key, "=", getvar @key
^LL(HAUS,ELEKTRIK,DOSEN,1)=Telefondose
^LL(HAUS,ELEKTRIK,DOSEN,2)=Steckdose
^LL(HAUS,ELEKTRIK,DOSEN,3)=IP-Dose
^LL(HAUS,ELEKTRIK,DOSEN,4)=KFZ-Dose

for subs in orderItr ^LL("HAUS","").keys:
    echo subs 
@["HAUS", "ELEKTRIK"]
@["HAUS", "FLAECHEN"]
@["HAUS", "HEIZUNG"]

for value in orderItr ^LL("HAUS","ELEKTRIK","DOSEN", "").val:
    echo value    
Telefondose
Steckdose
IP-Dose
KFZ-Dose

for key,value in orderItr ^LL("HAUS","ELEKTRIK","DOSEN", "").kv:
    echo key,"=",value    
1=Telefondose
2=Steckdose
3=IP-Dose
4=KFZ-Dose

for cnt in orderItr ^LL("HAUS","ELEKTRIK","DOSEN", "").count:
    echo cnt
4
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

# 'getvar' with postfix
It is possible to enforce a type when getting data from YottaDB. By using a 'postfix' a expected type can be defined and tested.
```nim
let i = getvar  ^global(1).int16
let f = getvar  ^global(4711).float32
let u = getvar  ^global(815).uint8
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
  let osdb: OrderedSet[int] = getvar  ^tmp("set1").OrderedSet
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
Getting a value, use getvar 
```nim
  let zversion = getvar  $ZVERSION
  echo zversion
```

To set a special variable via the DSL, use setvar:
It is important to use an empty bracket ().
```nim
  setvar: $ZMAXTPTIME()="2"
```

# Transactions
`Transaction` can handle both single- and multithreaded transactions.
For single-threaded Transactions you write:
```nim
let rc = Transaction:
  setvar: ^AAA(1) = "transaction1"
```
If the transaction succeeds, 'rc' is YDB_OK, otherwise YDB_TP_ROLLBACK if the transaction was rolled back due to an error.
By returning YDB_TP_RESTART, you can restart a transaction if desired or returning YDB_TP_ROLLBACK to abort and roll back a transaction.

YottaDB checks all DB blocks if another process has changed the data in the meantime. If so, it restarts the Transaction by calling the codeblock in `Transaction` up to 3 times. After that it switches to pessimistic locking and holding the other processes so that a transaction can successfully commit.

If a Transaction raises an exception, the macro implementation returns a YDB_TP_RESTART so that the transaction is restarted. If the problem persists, then also after the 4'th time, the transaction is aborted with YDB_TP_ROLLBACK. 
Check the src/tests/transaction example.

You can pass a single `string` parameter to  `Transaction("ABC")`. To access the parameter inside the body a cast to `cstring` is required:
```nim
# single threaded --threads:off
let rc = Transaction("ABC"):
  let s = $cast[cstring](param)
  setvar: ^gbl(101, s) = "data"
```

For the single-threaded Transaction, you can use the API and DSL features.
- ydb_set("^AAA", @["1"], "noparam")
- setvar: ^AAA(2) = "noparam"
- let gbl = "^AAA"
  setvar: @gbl(4) = "noparam"
- let gbl = "^AAA(5)"
  setvar: @gbl = "noparam"



For multi-threaded transactions, you need to pass the `tptoken` parameter to the ydb-API calls.
DSL is currently not supported with multi-threaded Transactions.
If no tptoken is set, YottaDB would block the call and the process is hanging.

```bash
# multi-threaded --threads:on (tptoken used)
let rc2 = Transaction(4712):
  let id = $cast[cint](param)
  ydb_set("^gbl", @[id], "data", tptoken)
```

Inside the body you have access to the parameters that YottaDB passes over:
  - tptoken:  uint64,
  - errstr: ptr struct_ydb_buffer_t,
  - param: pointer

In general, there is no limit in 'Transaction' statements within the code. 
Each 'Transaction' is commited automatically at the end of the code scope.

Currently, the multi-threaded 'Transaction' does not support the DSL statements like 'setvar'. Instead you have to use the API form (ydb_set(..,tptoken)). This will be changed in future. 
In the single-threaded form 'Transaction' you can freely use any DSL statements.

A good example to see how `Transaction` is used, look at m/bidwars.nim

To understand how YottaDB handles multi-threaded Transactions it is important to read their documents. (https://docs.yottadb.com/MultiLangProgGuide/programmingnotes.html#threads-txn-proc)
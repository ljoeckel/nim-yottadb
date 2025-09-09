# DSL commands

## set / get
```nim
set:
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
set: ^CUST(subs) = 1500.50
var amount = get: ^CUST(subs).float
amount += 1500.50
set: ^CUST(subs) = amount
let dbamount = get: ^CUST(subs).float  # read from db
assert dbamount == amount
```

Set with mixed variable and string subscripts
```nim
let id = 1
set: ^X(id, "s") = "pi"
let s = get: ^X(id, "s")
assert s == "pi"
set: ^X(id, "i") = 3
let i = get: ^X(id, "i").int
assert i == 3
set: ^X(id, "f") = 3.1414
let f = get: ^X(id, "f").float
assert f == 3.1414
```

set: in a loop
```nim
for id in 0..<5:
  let tm = cpuTime()
  set: ^CUST(id, "Timestamp") = tm
  let s = get: ^CUST(id, "Timestamp").float
  assert s == tm
```

Upto 31 Index-Levels are possible
```nim
set: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,"Z")="xxx"
```

## incr
Atomic increment a global in the database
```nim
let rc = delnode: ^CNT("TXID")
var incrval = incr: ^CNT("TXID")
assert 1 == incrval
incrval = incr: ^CNT("TXID") = 10
assert 11 == incrval
```

## data
Test if a node or tree exists and has a subtree
```nim
set:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  
  var dta = data: ^X(0)
  assert YdbData(dta) == NO_DATA_NO_SUBTREE
  dta = data: ^X(6)
  assert YdbData(dta) == DATA_NO_SUBTREE
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

## nextn
Traverse the global and get the next node in the collating sequence.
```nim
(rc, node) = nextn: ^LL()
@["HAUS"]
(rc, node) = nextn: ^LL(node)
  @["HAUS", "ELEKTRIK"]
```

## prevn
Traverse the global backward and get the previous node in the collating sequence.
```nim
(rc, subs) = prevn: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
assert subs = @["HAUS", "ELEKTRIK", "DOSEN"]

(rc, subs) = prevn: ^LL("HAUS", "ELEKTRIK")
assert subs = @["HAUS"]
```

## nextsub
Traverse on the globals on a given index level.
```nim
  var rc:int
  var subs: Subscripts
  (rc, subs) = nextsub: ^LL("HAUS", "ELEKTRIK")
  assert subs == @["HAUS", "FLAECHEN"]
  (rc, subs) = nextsub: ^LL("HAUS")
  assert subs == @["LAND"]
  (rc, subs) = nextsub: ^LL("")
  assert subs == @["HAUS"]
  (rc, subs) = nextsub: ^LL("ZZZZZZZ")
  assert rc == YDB_ERR_NODEEND and subs == @[""]
```

## prevsub
Traverse the globals backwards on a given index level.
```nim
  var rc:int
  var subs: Subscripts
  (rc, subs) = prevsub: ^LL("HAUS", "FLAECHEN")
  assert subs == @["HAUS", "ELEKTRIK"]
  (rc, subs) = prevsub: ^LL("LAND")
  assert subs == @["HAUS"]
  (rc, subs) = prevsub: ^LL("HAUS")
  assert rc == YDB_ERR_NODEEND and subs == @[""]
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
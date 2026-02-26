# Changelog for version 0.4.5
- Serialization now supports an .INDEX. pragma on data fields. The index is automatically created, modified or deleted for each field.
## Breaking Changes
- Serialization does not longer support "Binary object stream". Only by 'decomposition' is available
- Use saveObject, loadObject, deleteObject for serialization

# Changelog for version 0.4.4
## Breaking Changes
- The DSL names have been renamed with a `ydb` prefix to avoit namespace problems (g.E. Kill is also used in std/os)
- setvar -> Set, get -> Get, kill -> Kill, etc.


# Changelog for version 0.4.2
- The transaction macros have been refactored and simplified
- There is no longer a need to number transactions (Transaction1, TransactionMT1)
  'Transaction' handles now both, single- and multi-threaded transactions
- The code for Query/Order iterators has been refactored and simplified
- Bugfix #42 (Kill: ^gbl, @gbl) Mixed Global's with Indirections
- Some code refactorings
# Changelog for version 0.4.0
- Upgrade YottaDB to version 2.03
- Added TransactionMT templates for use in multi-threaded applications
- Reworked / extended transaction examples
- YdbVar now usable in multi-threaded applications
- Reworked YottaDB error handling (Restart/Rollback/Timeout,.)
- There are now 2 basic iterators 'QueryItr' that behaves like the M-function $Query and 'OrderItr' like $Order.
- Iterators now have the postfixes:
  - "count" - Count the number of entries
  - "key" - Return the full subscripted key (^Customer(1,"Name"))
  - "keys" - Return the full key as seq[string] (@["1", "Name"])
  - "kv" - Return the key and the value as tuple (^Customer(1,"Name"), "Lothar Jöckel")
  - "val" - Returns the value for the key 
  "reverse" - Traverses in backward direction

## Breaking Changes
- Iterators are moved from the ydbapi to the DSL
- Iterators are renamed to get closer to M semantics
There is now only 'OrderItr' and 'QueryItr'. The direction is per default forward.
'.reverse' traverses in reverse direction
```nim
for key in QueryItr ^Customer.reverse
  echo key  # ^Customer(99999,profile,name)
```
.reverse can be appended to another postfix:
```nim
for keys in QueryItr ^Customer.keys.reverse
  echo keys  # @["999999","profile","name"]
```
The 'hello_customer' example show the different form on how to use the iterators with the postfix .key, .keys, .value, .count
- iterators nextKeys, prevKeys, nextValues, prevValues, nextPairs, prevPairs, nextSubscript, prevSubscript, nextSubscriptValues, prevSubscriptValues, nextSubscriptPairs, prevSubscriptPairs
are now removed and replaced with 'OrderItr' and 'QueryItr'

# Changelog for version 0.3.3
## Breaking Changes
#### Get semantic changed
'Get' now returns always an empty string if no Data found in the database. This follows the semantic of M $get function. 
Before, an exception was thrown.

#### Iterator naming
The naming for the iterators has changed:
  - 'ydb_node_next_iter' -> 'QueryItr'
  - 'ydb_node_previous_iter' -> 'prevKeys'
  - 'ydb_subscript_next_iter' -> 'nextSubscript'
  - 'ydb_subscript_previous_iter' -> 'prevSubscript'
  - 'nextValues'
  - 'prevValues'

## New functionality
#### Transaction Macro
A `Transaction` macro simplifies the execution of transactions.
Before `Transaction` you have to write the code like:
```nim
proc bidTx(p0: pointer): cint {.cdecl.} =
    try:
        let first = (pid == Get @auction("Leader"))
        if not first:
            let price = Get @auction("Price").int
            let raisedBy = rand(1..10)
            let newprice = price + raisedBy
            Set:
                @auction("Leader") = pid
                @auction("Price") = newprice
    except:
        return YDB_TP_RESTART
    YDB_OK

while (Get @auction("Active")) == "Yes":
  var rc = ydb_tp(bidTx, "") # place bid
```
With the new `Transaction` macro you can now write:
```nim
while (Get @auction("Active")) == "Yes":
  let rc = Transaction:
    let first = (pid == Get @auction("Leader"))
    if not first:
      let price = Get @auction("Price").int
      let raisedBy = rand(1..10)
      let newprice = price + raisedBy
      Set:
        @auction("Leader") = pid
        @auction("Price") = newprice
```
There is no need anymore to check for YDB_TP_RESTART. This will be done inside the macro.
You can have up to 5 Transaction per compilation unit. (Transaction, Transaction2, Transaction3, Transaction4, Transaction5)

You cannot reuse the Transaction. If you need more than 5 transactions you can append them in `dsl.nim`.
```nim
template Transaction6*(body: untyped): untyped =
  tximpl("TX6"):
    body
  ydb_tp(TX6, "")
template Transaction6*(param: string = "", body: untyped): untyped =
  tximpl("TX6P"):
    body
  ydb_tp(TX6P, param)
```
#### Improved Transaction handling on restarts
All Simple-API calls to YottaDB now handle YDB_TP_RESTART and YDB_TP_ROLLBACK.

This can happen when the client calls an API function (g.e. ydb_increment_db) and an external process has commited on the same resource. In this case, YottaDB returns a YDB_TP_RESTART and calls the transaction logic again. The client code may decide to rollback the transaction by returning YDB_TP_ROLLBACK.

To handle this in the correct way the client transaction code needs to check for an exception. Getting the value of the YottaDB special var `$TRESTART` shows how many times a restart was requested from the DB. A maximum of 4 restarts are possible. There is a new example `bidwars` in the `m` folder that implements that.

```nim
proc bizzTX(p0: pointer): cint {.cdecl.} =
  try:
    let cnt = Increment ^CNT("up")
    ...
  except:
      echo getCurrentExceptionMsg(), " # of restarts:", $(Get $TRESTART)
      return YDB_TP_RESTART
  YDB_OK
```
#### Get
- Get now returns an empty string/int/float if no Data in the database found.
- Get allows now to set a default value.
```nim
  let valdefault = Get (^GBL(4711), default=4711)
  let valint = Get (^GBL(4711), default=4711).int
  let gbl = "^GBL(4711)"
  valindirekt = Get (@gbl, default="test")
  valindirekt = Get (@gbl("Test"), default="test")
```

# Changelog for version 0.3.1
## @ Indirection Index Extension
It is now allowed to extend the index of a variable that is defined as @ indirection.
```nim
var gbl = "^GBL"
Set: @gbl(1) = 1
assert "1" == Get @gbl(1)

Set: @gbl(1,"A") = "1A"
assert "1A" == Get @gbl(1, "A")

gbl = "^GBL(1,A)"
assert "1A" == Get @gbl

# ---- test with index in the variable ----
gbl = "^GBL(123815)"
Set: @gbl = "123815"
assert "123815" == Get @gbl

# Index extended
Set: @gbl(1) = "123815,1" # -> ^GBL(123815,1)
assert "123815,1" == Get @gbl(1)
Set: @gbl("ABC") = "ABC" # -> ^GBL(123815, "ABC")
assert "ABC" == Get @gbl("ABC")
Set: @gbl(123, "ABC") = "123ABC" # -> ^GBL(123815, 123, "ABC")
assert "123ABC" == Get @gbl(123, "ABC")

# With variable in the index
let id = "4714"
Set: @gbl(id, "ABC") = "idABC"
assert "idABC" == Get @gbl(id, "ABC")
Set: @gbl(@["XYZ", id, "ABC"]) = "XYZABC"
assert "XYZABC" == Get @gbl("XYZ", id, "ABC")
```
A simple example to show customers Data:
```nim
echo "Iterate over all customers Indirection"
    var (rc, gbl) = nextsubscript @"^CUSTOMER"
    while rc == YDB_OK:
      let name = Get @gbl("Name")
      let email = Get @gbl("Email")
      echo fmt"{gbl}: name: {name}, email:{email}"
      (rc, gbl) = nextsubscript @gbl
```
Prints out:
```bash
Iterate over all customers Indirection
^CUSTOMER(1): name: John Doe, email:john-doe.@gmail.com
^CUSTOMER(2): name: Jane Smith, email:jane.smith.@yahoo.com
```


# Changelog for version 0.3.0

## Breaking Changes for version 0.3.0
- DSL `delnode` has been renamed to `Killnode`. It kills (removes) a single node independent of descendents.
- DSL `deltree` has been renamed to `Kill`. It removes the nodes and the descendents
This is to bring nim-yottadb more close to M naming.
Simply rename all `deltree` to `Kill` and `delnode` to `Killnode`.

- Utility functions are refactored `ydbutils` now. Rename `import utils` to `import ydbutils`.

- deletevar has been replaced through `Kill` which does exactly that.

- `get` has been renamed to `Get` to be more consistent with setvar.

# Changelog for version 0.2.0
## DSL rewrite
The code to implement the Domain Specific Language (DSL) has been rewritten. Most changes where related to `Indirection`.

## deletevar
Instead of calling `deleteGlobal("^solver")`you can now use the DSL `Kill: ^solver`

## Indirektion with @
With the `@` (indirection) parameter you get now the full variablename with the key components `^global(1,A)`.
With that you can access all DSL methods:
Killnode @gbl, Get @gbl, Set: @gbl, ...

The following examples show a typical usage:
```nim
proc Gets(): seq[string] =
    var (rc, gbl) = nextnode: ^hello
    while rc == YDB_OK:
        result.add(gbl)
        (rc, gbl) = nextnode: @gbl

for id in Gets():
    let val = Get @id
```
 ## Tests
 Tests are now partially factored out to seperate files. Not yet complete.

## Breaking Changes for version 0.2.0
### next/prev
The familiy of next/prev node and next/prev subscript are now defaulting to the `@` indirection form.

That means that instead of a `seq[string]` which contains the key components, a single `string` with the variable name and the keys are now returned by default.

If you need the old `seq[string]` form, you have to add `.keys`to the variable.
```nim
var (rc: int, gbl: string) = nextnode: ^BENCHMARK2
```
Returns `^BENCHMARK(1,A)`.  With that, you can now call any further DSL command, like `Get @gbl``
```nim
var (rc: int, subs: seq[string]) = nextnode: ^BENCHMARK2().keys
```
returns `@["1", "A"]`.

### getblob
The `getblob` DSL no longer exists. Instead you can use `Get` and add `.binary` at the end of the variable. This can read Data > 1MB.
```nim
let img = Get ^images(subs).binary
```

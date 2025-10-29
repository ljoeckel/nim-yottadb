# Changelog for version 0.3.3
## Breaking Changes
#### getvar semantic changed
'getvar' now returns always an empty string if no data found in the database. This follows the semantic of M $get function. 
Before, an exception was thrown.

#### Iterator naming
The naming for the iterators has changed:
  - 'ydb_node_next_iter' -> 'nextKeys'
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
        let first = (pid == getvar @auction("Leader"))
        if not first:
            let price = getvar @auction("Price").int
            let raisedBy = rand(1..10)
            let newprice = price + raisedBy
            setvar:
                @auction("Leader") = pid
                @auction("Price") = newprice
    except:
        return YDB_TP_RESTART
    YDB_OK

while (getvar @auction("Active")) == "Yes":
  var rc = ydb_tp(bidTx, "") # place bid
```
With the new `Transaction` macro you can now write:
```nim
while (getvar @auction("Active")) == "Yes":
  let rc = Transaction:
    let first = (pid == getvar @auction("Leader"))
    if not first:
      let price = getvar @auction("Price").int
      let raisedBy = rand(1..10)
      let newprice = price + raisedBy
      setvar:
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
    let cnt = increment ^CNT("up")
    ...
  except:
      echo getCurrentExceptionMsg(), " # of restarts:", $(getvar $TRESTART)
      return YDB_TP_RESTART
  YDB_OK
```
#### getvar
- getvar now returns an empty string/int/float if no data in the database found.
- getvar allows now to set a default value.
```nim
  let valdefault = getvar (^GBL(4711), default=4711)
  let valint = getvar (^GBL(4711), default=4711).int
  let gbl = "^GBL(4711)"
  valindirekt = getvar (@gbl, default="test")
  valindirekt = getvar (@gbl("Test"), default="test")
```

# Changelog for version 0.3.1
## @ Indirection Index Extension
It is now allowed to extend the index of a variable that is defined as @ indirection.
```nim
var gbl = "^GBL"
setvar: @gbl(1) = 1
assert "1" == getvar @gbl(1)

setvar: @gbl(1,"A") = "1A"
assert "1A" == getvar @gbl(1, "A")

gbl = "^GBL(1,A)"
assert "1A" == getvar @gbl

# ---- test with index in the variable ----
gbl = "^GBL(123815)"
setvar: @gbl = "123815"
assert "123815" == getvar @gbl

# Index extended
setvar: @gbl(1) = "123815,1" # -> ^GBL(123815,1)
assert "123815,1" == getvar @gbl(1)
setvar: @gbl("ABC") = "ABC" # -> ^GBL(123815, "ABC")
assert "ABC" == getvar @gbl("ABC")
setvar: @gbl(123, "ABC") = "123ABC" # -> ^GBL(123815, 123, "ABC")
assert "123ABC" == getvar @gbl(123, "ABC")

# With variable in the index
let id = "4714"
setvar: @gbl(id, "ABC") = "idABC"
assert "idABC" == getvar @gbl(id, "ABC")
setvar: @gbl(@["XYZ", id, "ABC"]) = "XYZABC"
assert "XYZABC" == getvar @gbl("XYZ", id, "ABC")
```
A simple example to show customers data:
```nim
echo "Iterate over all customers Indirection"
    var (rc, gbl) = nextsubscript @"^CUSTOMER"
    while rc == YDB_OK:
      let name = getvar  @gbl("Name")
      let email = getvar @gbl("Email")
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
- DSL `delnode` has been renamed to `killnode`. It kills (removes) a single node independent of descendents.
- DSL `deltree` has been renamed to `kill`. It removes the nodes and the descendents
This is to bring nim-yottadb more close to M naming.
Simply rename all `deltree` to `kill` and `delnode` to `killnode`.

- Utility functions are refactored `ydbutils` now. Rename `import utils` to `import ydbutils`.

- deletevar has been replaced through `kill` which does exactly that.

- `get` has been renamed to `getvar` to be more consistent with setvar.

# Changelog for version 0.2.0
## DSL rewrite
The code to implement the Domain Specific Language (DSL) has been rewritten. Most changes where related to `Indirection`.

## deletevar
Instead of calling `deleteGlobal("^solver")`you can now use the DSL `kill: ^solver`

## Indirektion with @
With the `@` (indirection) parameter you get now the full variablename with the key components `^global(1,A)`.
With that you can access all DSL methods:
killnode @gbl, getvar @gbl, setvar: @gbl, ...

The following examples show a typical usage:
```nim
proc getVars(): seq[string] =
    var (rc, gbl) = nextnode: ^hello
    while rc == YDB_OK:
        result.add(gbl)
        (rc, gbl) = nextnode: @gbl

for id in getVars():
    let val = getvar @id
```
 ## Tests
 Tests are now partially factored out to seperate files. Not yet complete.

## Breaking Changes for version 0.2.0
### next/prev
The familiy of next/prev node and next/prev subscript are now defaulting to the `@` indirection form.

That means that instead of a `seq[string]` which contains the key components, a single `string` with the variable name and the keys are now returned by default.

If you need the old `seq[string]` form, you have to add `.seq`to the variable.
```nim
var (rc: int, gbl: string) = nextnode: ^BENCHMARK2
```
Returns `^BENCHMARK(1,A)`.  With that, you can now call any further DSL command, like `getvar @gbl``
```nim
var (rc: int, subs: seq[string]) = nextnode: ^BENCHMARK2().seq
```
returns `@["1", "A"]`.

### getblob
The `getblob` DSL no longer exists. Instead you can use `getvar` and add `.binary` at the end of the variable. This can read data > 1MB.
```nim
let img = getvar ^images(subs).binary
```

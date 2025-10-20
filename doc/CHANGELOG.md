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
killnode @gbl, get @gbl, setvar: @gbl, ...

The following examples show a typical usage:
```nim
proc getVars(): seq[string] =
    var (rc, gbl) = nextnode: ^hello
    while rc == YDB_OK:
        result.add(gbl)
        (rc, gbl) = nextnode: @gbl

for id in getVars():
    let val = get @id
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
Returns `^BENCHMARK(1,A)`.  With that, you can now call any further DSL command, like `get @gbl``
```nim
var (rc: int, subs: seq[string]) = nextnode: ^BENCHMARK2().seq
```
returns `@["1", "A"]`.

### getblob
The `getblob` DSL no longer exists. Instead you can use `get` and add `.binary` at the end of the variable. This can read data > 1MB.
```nim
let img = get ^images(subs).binary
```

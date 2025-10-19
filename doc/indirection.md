## next/prev node/subscript

**nextsubscript** `string`

When calling the next/prev family of DSL commands, you get an string with the variable name and all key components like "^LL(HAUS,ELEKTRIK,KABEL)".
With this you can directly call any other DSL method.
For example: `lock: @gbl`

If you need control over the key components, you can use the `.seq` postfix to mark so.
(rc, gbl) = nextsubscript @"^LL(HAUS,ELEKTRIK,DOSEN)"`.seq`
You get then back a seq[string] like @["HAUS", "ELEKTRIK", "DOSEN", "2"]

```nim
var rc: int
var gbl: string

(rc, gbl) = nextsubscript @"^LL(HAUS,ELEKTRIK,DOSEN)"
assert gbl == "^LL(HAUS,ELEKTRIK,KABEL)"

(rc, gbl) = nextsubscript @"^LL(HAUS,ELEKTRIK,DOSEN,)".seq
assert gbl == @["HAUS", "ELEKTRIK", "DOSEN", "1"]
```
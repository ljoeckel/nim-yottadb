# DSL commands

## set
## get
## incr
## nextn
## prevn
## nextsub
## prevsub
## data
## delnode
## deltree
## lock
....

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
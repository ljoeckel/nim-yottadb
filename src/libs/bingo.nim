import macros, strutils, options, tables, sets
import yottadb_api


proc saveInYdb(global: string, subs: seq[string], key: string, value: string) =
  var subscpy = subs
  subscpy.add(key)
  #echo "saveInYdb global:", global," subs:", subs, " key:", key, " value:", value
  ydbSet(global, subscpy, value)

proc loadFromYdb(global: string, subs: seq[string], key: string): string =
  var subscpy = subs
  subscpy.add(key)
  result = ydbGet(global, subscpy)


# serialization
proc store(global: string, subs: seq[string], k: string; x: bool) =
  saveInYdb(global, subs, k, $x)
  
proc store(global: string, subs: seq[string], k: string; x: char) =
  saveInYdb(global, subs, k, $x)

proc store(global: string, subs: seq[string], k: string; x: string) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: SomeNumber](global: string, subs: seq[string], k: string; x: T) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: enum](global: string, subs: seq[string], k: string; x: T) =
  saveInYdb(global, subs, k, $ord(x))
  
proc store[S, T](global: string, subs: seq[string], k: string; x: array[S, T]) =
  for elem in items(x):
    store(global, subs, k, elem)

proc store[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] | set[T]) =
  echo "82 set seq T ", $typeof(T), " k:", k
  var idx = 0
  for elem in x.items():
    var subscpy = subs
    when T is RootObj:
      subscpy.add($idx)
      store(subscpy, elem)
    elif T is enum:
      subscpy.add(k)
      subscpy.add($idx)
      ydbSet(global, subscpy, $ord(elem))
    else:
      # it's a seq[string],...
      subscpy.add(k)
      subscpy.add($idx)
      ydbSet(global, subscpy, $elem)
    
    inc(idx)

proc store[K, V](global: string, subs: seq[string], kv: string; o: (Table[K, V]|OrderedTable[K, V])) =
  for k, v in pairs(o):
    store(global, subs, kv, k)
    store(global, subs, kv, v)

proc store[T](global: string, subs: seq[string], k: string; o: ref T) =
  let isSome = o != nil
  if isSome:
    store(global, subs, k, o[])

proc store[T](global: string, subs: seq[string], k: string; o: Option[T]) =
  let isSome = isSome(o)
  if isSome:
    store(global, subs, k, get(o))

proc store[T: tuple](global: string, subs: seq[string], k: string; o: T) =
    for k,v in fieldPairs(o):
      store(global, subs, k, v)

# Type on field Customer.Adress
proc store[T](global: string, subs: seq[string], k: string, o: T) =
  for k,v in fieldPairs(o):
    let gbl = "^" & $T
    store(gbl, subs, k, v)

proc store*[T: object](subs: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  for k,v in fieldPairs(o):
    store(gbl, subs, k, v)


# Deserialisation
# BOOL
proc load(global: string, subs: seq[string], k: string; x: var bool) =
  let value = loadFromYdb(global, subs, k)
  if value == "true": x = true else: x = false

# CHAR
proc load(global: string, subs: seq[string], k: string; x: var char) =
  x = loadFromYdb(global, subs, k)[0]

# STRING
proc load(global: string, subs: seq[string], k: string; x: var string) =
  x = loadFromYdb(global, subs, k)

# SOME NUMBER
proc load[T: var SomeNumber](global: string, subs: seq[string], k: string; x: var T) =
  echo "148 gbl:", global, " subs:", subs, " k:", k, " o:", x
  let s = loadFromYdb(global, subs, k)
  when T is SomeInteger:
    x = parseInt(s).T
  else:
    x = parseFloat(s).T

# ENUM
proc load[T: enum](global: string, subs: seq[string], k: string; x: var T) =
  echo "158 gbl:", global, " subs:", subs, " k:", k, " o:", x 
  let value = parseInt(loadFromYdb(global, subs, k))
  if value >= low(T).ord and value <= high(T).ord:
    x = T(value)
  else:
    raise newException(ValueError, "Invalid enum value: " & $value)

# SET 
proc load[T](global: string, subs: seq[string], k: string; x: var set[T]) =
  echo "167 load ", $typeof(T), " global:", global, " subs:", subs, " k:", k
  var idx, rc = 0
  var subscripts = subs
  subscripts.add( @[k, ""] )
  while(rc == YDB_OK):
    rc = ydb_subscript_next(global, subscripts)
    if rc == YDB_OK:
      let value = ydbGet(global, subscripts)
      when typeof(x) is set[char]:
        x.incl(value[0])
      else:
        x.incl(parseInt(value).T)
  inc(idx)


proc load[S, T](global: string, subs: seq[string], k: string; x: var array[S, T]) =
  echo "180 gbl:", global, " subs:", subs, " k:", k, " o:", x
  for elem in items(x):
    load(global, subs, k, elem)

# HashSet, OrderedSet
proc load[T: var SomeSet](global: string, subs: seq[string], k: string; x: var T ) =
  echo "185 gbl:", global, " subs:", subs, " k:", k, " o:", x
  var idx, rc = 0
  var subscripts = subs
  subscripts.add(@[k, ""])
  while(rc == YDB_OK):
    rc = ydb_subscript_next(global, subscripts)
    if rc == YDB_OK:
      x.incl(ydbGet(global, subscripts))
    inc(idx)

# seq[T] | seq[T of RootObj]
proc load[T](global: string, subs: seq[string], k: string; x: var seq[T] ) =
  echo "202 gbl:", global, " subs:", subs, " k:", k, " o:", x      
  var rc = 0
  when T is RootObj:
    var subscripts = subs
    subscripts.add("")
    let gbl = "^" & $T
    while(rc == YDB_OK):
      rc = ydb_subscript_next(gbl, subscripts)
      if rc == YDB_OK:
        var t:T = T()
        load(gbl, subscripts, t)
        x.add(t)
  else:
    var subscripts = subs
    subscripts.add(@[k,""])
    while(rc == YDB_OK):
      rc = ydb_subscript_next(global, subscripts)
      if rc == YDB_OK:
        x.add(ydbGet(global, subscripts))

proc load[K, V](global: string, subs: seq[string], kv: string; o: var (Table[K, V]|OrderedTable[K, V])) =
  echo "224 gbl:", global, " subs:", subs, " kv:", kv, " o:", o      
  for k, v in pairs(o):
    load(global, subs, kv, k)
    load(global, subs, kv, v)

proc load[T](global: string, subs: seq[string], k: string; o: ref var T) =
  echo "234 gbl:", global, " subs:", subs, " k:", k, " o:", o    
  let isSome = o != nil
  if isSome:
    load(global, subs, k, o[])

proc load[T](global: string, subs: seq[string], k: string; o: var Option[T]) =
  echo "234 gbl:", global, " subs:", subs, " k:", k, " o:", o    
  let isSome = isSome(o)
  if isSome:
    load(global, subs, k, get(o))

proc load[T: var tuple](global: string, subs: seq[string], k: string; o: var T) =
  for k,v in fieldPairs(o):
    echo "240 gbl:", global, " subs:", subs, " k:", k, " v:", v    
    load(global, subs, k, v)

proc load[T](global: string, subs: seq[string], k: string; o: var T) =
  for k,v in fieldPairs(o):
    let gbl = "^" & $T
    echo "245 gbl:", gbl, " subs:", subs, " k:", k, " v:", v
    load(gbl, subs, k, v)

proc load*[T: var object](subs: seq[string]; o: var T) =
  let gbl = "^" & $typeof(o)
  echo "250 gbl:", gbl, " subs:", subs, " o:", $typeof(o)
  load(gbl, subs, o)

proc load*[T: var object](gbl: string, subs: seq[string]; o: var T) =
  for k,v in fieldPairs(o):
    echo "255 gbl:", gbl, " subs:", subs, " k:", k, " v:", v, " ", $typeof(v)
    load(gbl, subs, k, v)

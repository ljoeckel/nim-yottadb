import macros, strutils, options, tables, sets
import libs/ydbapi
import libs/ydbtypes

proc saveInYdb(global: string, subs: seq[string], key: string, value: string) =
  var subscpy = subs
  subscpy.add(key)
  ydb_set(global, subscpy, value)

proc loadFromYdb(global: string, subs: seq[string], key: string): string =
  var subscpy = subs
  subscpy.add(key)
  try:
    result = ydb_get(global, subscpy)
  except:
    echo "ERROR: " & getCurrentExceptionMsg()


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
  var idx = 0
  for elem in x.items():
    var subscpy = subs
    when T is object:
      subscpy.add($idx)
      store(subscpy, elem)
    elif T is enum:
      subscpy.add(k)
      subscpy.add($idx)
      ydb_set(global, subscpy, $ord(elem))
    else:
      # it's a seq[string],...
      subscpy.add(k)
      subscpy.add($idx)
      ydb_set(global, subscpy, $elem)
    
    inc(idx)

proc store[K, V](global: string, subs: seq[string], kv: string; o: (Table[K, V]|OrderedTable[K, V])) =
  for fn, fv in pairs(o):
    store(global, subs, kv, fn)
    store(global, subs, kv, fv)

proc store[T](global: string, subs: seq[string], k: string; o: Option[T]) =
  let isSome = isSome(o)
  if isSome:
    store(global, subs, k, get(o))

proc store[T: tuple](global: string, subs: seq[string], k: string; o: T) =
  for fn, fv in fieldPairs(o):
    store(global, subs, fn, fv)

# Need forward declaration for "ref object" cases
#proc store[T](global: string, subs: seq[string], k: string; o: T)

# For references to objects (e.g. Foo)
#proc store[T: object](global: string, subs: seq[string], k: string; o: ref T) =
#  echo "76 ref T typeof(o):", $typeof(o)
#  if o != nil:
#    store[T](global, subs, k, o[])  # unwrap and call object version

# For plain objects
proc store[T](global: string, subs: seq[string], k: string; o: T) =
  let gbl = "^" & $T
  for fn, fv in fieldPairs(o):
    store(gbl, subs, fn, fv)


proc store*[T: object](subs: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  for fn, fv in fieldPairs(o):
    store(gbl, subs, fn, fv)


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
  try:
    let s = loadFromYdb(global, subs, k)
    when T is SomeInteger:
      x = parseInt(s).T
    else:
      x = parseFloat(s).T
  except:
    echo "ERROR: " & getCurrentExceptionMsg()

# ENUM
proc load[T: enum](global: string, subs: seq[string], k: string; x: var T) =
  let value = parseInt(loadFromYdb(global, subs, k))
  if value >= low(T).ord and value <= high(T).ord:
    x = T(value)
  else:
    raise newException(ValueError, "Invalid enum value: " & $value)

# SET 
proc load[T](global: string, subs: seq[string], k: string; x: var set[T]) =
  var idx, rc = 0
  var subscripts = subs
  subscripts.add( @[k, ""] )
  while(rc == YDB_OK):
    (rc, subscripts) = ydb_subscript_next(global, subscripts)
    if rc == YDB_OK:
      let value = ydb_get(global, subscripts)
      when typeof(x) is set[char]:
        x.incl(value[0])
      else:
        x.incl(parseInt(value).T)
  inc(idx)


proc load[S, T](global: string, subs: seq[string], k: string; x: var array[S, T]) =
  for elem in items(x):
    load(global, subs, k, elem)

# HashSet, OrderedSet
proc load[T: var SomeSet](global: string, subs: seq[string], k: string; x: var T ) =
  var idx, rc = 0
  var subscripts = subs
  subscripts.add(@[k, ""])
  while(rc == YDB_OK):
    (rc, subscripts) = ydb_subscript_next(global, subscripts)
    if rc == YDB_OK:
      x.incl(ydb_get(global, subscripts))
    inc(idx)

# seq[T] | seq[T of object]
proc load[T](global: string, subs: seq[string], k: string; x: var seq[T] ) =
  var rc = 0
  when T is object:
    var subscripts = subs
    subscripts.add("")
    let gbl = "^" & $T
    while(rc == YDB_OK):
      (rc, subscripts) = ydb_subscript_next(gbl, subscripts)
      if rc == YDB_OK:
        var t:T = T()
        load(gbl, subscripts, t)
        x.add(t)
  else:
    var subscripts = subs
    subscripts.add(@[k,""])
    while(rc == YDB_OK):
      (rc, subscripts) = ydb_subscript_next(global, subscripts)
      if rc == YDB_OK:
        x.add(ydb_get(global, subscripts))

proc load[K, V](global: string, subs: seq[string], kv: string; o: var (Table[K, V]|OrderedTable[K, V])) =
  for fn, fv in pairs(o):
    load(global, subs, kv, fn)
    load(global, subs, kv, fv)

#proc load[T](global: string, subs: seq[string], k: string; o: var T)

# proc load[T](global: string, subs: seq[string], k: string; o: var ref T) =
#   #echo "234 gbl:", global, " subs:", subs, " k:", k, " o:", o    
#   #let isSome = o != nil
#   #if isSome:
#   if o.isNil:
#     new(o)
#   echo "190 o=", o[]
#   load[T](global, subs, k, o[])

proc load[T](global: string, subs: seq[string], k: string; o: var Option[T]) =
  let isSome = isSome(o)
  if isSome:
    load(global, subs, k, get(o))

proc load[T: var tuple](global: string, subs: seq[string], k: string; o: var T) =
  for fn, fv in fieldPairs(o):
    load(global, subs, fn, fv)

proc load[T](global: string, subs: seq[string], k: string; o: var T) =
  for fn, fv in fieldPairs(o):
      var gbl = "^" & $T
      #if gbl.contains(':'): gbl = gbl.split(':')[0]
      load(gbl, subs, fn, fv)

proc load*[T: var object](subs: seq[string]; o: var T) =
  let gbl = "^" & $typeof(o)
  load(gbl, subs, o)

proc load*[T: var object](gbl: string, subs: seq[string]; o: var T) =
  for fn, fv in fieldPairs(o):
    load(gbl, subs, fn, fv)

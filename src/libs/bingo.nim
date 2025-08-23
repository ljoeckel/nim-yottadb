import macros, streams, strutils, options, tables, sets
from typetraits import supportsCopyMem
import yottadb_api

type  SeqBasicTypes* = SomeInteger|SomeFloat|string|bool

proc isCustom*(t: typedesc[bool]): bool = false
proc isCustom*(t: typedesc[char]): bool = false
proc isCustom*[T: SomeNumber](t: typedesc[T]): bool = false
proc isCustom*[T: enum](t: typedesc[T]): bool = false
proc isCustom*[T](t: typedesc[set[T]]): bool = false
proc isCustom*(t: typedesc[string]): bool = true
proc isCustom*[S, T](t: typedesc[array[S, T]]): bool = true
proc isCustom*[T](t: typedesc[seq[T]]): bool = true
proc isCustom*[T](t: typedesc[SomeSet[T]]): bool = true
proc isCustom*[K, V](t: typedesc[(Table[K, V]|OrderedTable[K, V])]): bool = true
proc isCustom*[T](t: typedesc[ref T]): bool = true
proc isCustom*[T](t: typedesc[Option[T]]): bool = true
proc isCustom*[T: tuple](t: typedesc[T]): bool =
  result = false
  var o: T
  for v in fields(o):
    if isCustom(typeof(v)): return true
proc isCustom*[T: object](t: typedesc[T]): bool =
  result = false
  var o: T
  for v in fields(o):
    if isCustom(typeof(v)): return true


proc saveInYdb(global: string, subs: seq[string], key: string, value: string) =
  var subscpy = subs
  subscpy.add(key)
  #echo "saveInYdb global:", global," subs:", subs, " key:", key, " value:", value
  ydbSet(global, subscpy, value)

proc loadYdb(global: string, subs: seq[string], key: string): string =
  var subscpy = subs
  subscpy.add(key)
  result = ydbGet(global, subscpy)


# serialization
proc store(global: string, subs: seq[string], k: string; x: bool) =
  saveInYdb(global, subs, k, $x)
  
proc store(global: string, subs: seq[string], k: string; x: char) =
  let s:string  = $x
  saveInYdb(global, subs, k, $x)

proc store(global: string, subs: seq[string], k: string; x: string) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: SomeNumber](global: string, subs: seq[string], k: string; x: T) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: enum](global: string, subs: seq[string], k: string; x: T) =
  saveInYdb(global, subs, k, $ord(x))
  
proc store[T](global: string, subs: seq[string], k: string; x: set[T]) =
  var idx = 0
  var subscpy: seq[string]
  echo "61 store set[T]:",$T
  for elem in x.items():
    subscpy = subs
    subscpy.add(k)
    subscpy.add($idx)
    when T is enum:
      echo "65 enum ", elem, $ord(elem)
      ydbSet(global, subscpy, $ord(elem))
      #store(global, subscpy, $ord(elem))
    elif T is RootObj:
      echo "67 RootObj ",elem
      #var subscpy = subs
      #subscpy.add($idx)
      store(global, subscpy, elem)
    else:
      echo "76 else elem:", $elem
      # it's a seq[string],...
      #var subscpy = subs
      # subscpy = subs
      # subscpy.add(k)
      # subscpy.add($idx)
      ydbSet(global, subscpy, $elem)
    
    inc(idx)
  
proc store[S, T](global: string, subs: seq[string], k: string; x: array[S, T]) =
  for elem in items(x):
    store(global, subs, k, elem)

proc store[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] ) =
  var idx = 0
  for elem in x.items():
    # if its a Type
    when T is RootObj:
      var subscpy = subs
      subscpy.add($idx)
      echo "88 store seq[T] RootObj T:", typeof(elem), " subscpy:", subscpy, " global:", global
      store(subscpy, elem)
    else:
      echo "91 store seq[T] | SomeSet[T] k:", k, " subs:", subs, " T:", $T
      # it's a seq[string],...
      var subscpy = subs
      subscpy.add(k)
      subscpy.add($idx)
      ydbSet(global, subscpy, $elem)
    
    inc(idx)

# proc store[T](global: string, subs: seq[string], k: string; o: SomeSet[T]) =
#   echo "store SomeSet T:", o
#   for elem in items(o):
#     store(global, subs, k, elem)

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
proc store[T](global: string, subs: seq[string], k: string; o: T) =
  for k,v in fieldPairs(o):
    let gbl = "^" & $T
    store(gbl, subs, k, v)

proc store*[T: object](gbl: string, subs: seq[string]; o: T) =
  for k,v in fieldPairs(o):
    store(gbl, subs, k, v)

proc store*[T: object](subs: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  for k,v in fieldPairs(o):
    store(gbl, subs, k, v)


# Deserialisation
# BOOL
proc load(global: string, subs: seq[string], k: string; x: var bool) =
  let value = loadYdb(global, subs, k)
  if value == "true": x = true else: x = false

# CHAR
proc load(global: string, subs: seq[string], k: string; x: var char) =
  x = loadYdb(global, subs, k)[0]

# STRING
proc load(global: string, subs: seq[string], k: string; x: var string) =
  x = loadYdb(global, subs, k)

# SOME NUMBER
proc load[T: var SomeNumber](global: string, subs: seq[string], k: string; x: var T) =
  let s = loadYdb(global, subs, k)
  when T is SomeInteger:
    x = parseInt(s).T
  elif T is SomeFloat:
    x = parseFloat(s).T
  else:
    {.error: "Unsupported type".}

# ENUM
proc load[T: enum](global: string, subs: seq[string], k: string; x: var T) =
  #echo "enum global:",global, " subs:",subs, " k:", k
  let value = parseInt(loadYdb(global, subs, k))
  if value >= low(T).ord and value <= high(T).ord:
    x = T(value)
  else:
    raise newException(ValueError, "Invalid enum value: " & $value)

# SET 
proc load[T](global: string, subs: seq[string], k: string; x: var set[T]) =
  echo "169 load set[T] T:", $T
  var idx, rc = 0
  when T is RootObj:
    echo "171"
    var subscripts = subs
    subscripts.add("")
    let gbl = "^" & $T
    while(rc == YDB_OK):
      rc = ydb_subscript_next(gbl, subscripts)
      if rc == YDB_OK:
        var t:T = T()
        load(gbl, subscripts, t)
        x.add(t)
        inc(idx)
  else:
    echo "184"
    var subscripts = subs
    subscripts.add(@[k,""])
    while(rc == YDB_OK):
      rc = ydb_subscript_next(global, subscripts)
      if rc == YDB_OK:
        let value = parseInt(ydbGet(global, subscripts))
        echo "global:", global, " subscripts:", subscripts, " value:", value, " typeof(value):", typeof(value), " typeof(x):", typeof(x)
        x.incl(value.T)
    inc(idx)


proc load[S, T](global: string, subs: seq[string], k: string; x: var array[S, T]) =
  for elem in items(x):
    load(global, subs, k, elem)


proc load[T: var SomeSet](global: string, subs: seq[string], k: string; x: var SomeSet[T] ) =
  echo "194 load SomeSet"
  var idx = 0
  var subscripts = subs
  subscripts.add(k)
  subscripts.add("")
  var rc = 0
  var newseq: seq[T] = @[]
  while(rc == YDB_OK):
    rc = ydb_subscript_next(global, subscripts)
    if rc == YDB_OK:
      echo("TA: ", $T, " ******* rc=", $rc, " global:", global, " subs=", subscripts)
      #x.add(loadYdb(global, subs, k))
      when T is string:
        newseq.add(ydbGet(global, subscripts))      
  echo "***************** NEWSEQ : ", newseq
#   x = newseq


# seq[T] | seq[T of RootObj]
proc load[T](global: string, subs: seq[string], k: string; x: var seq[T] ) =
  echo "214 load seq[T] ",$T
  var idx, rc = 0
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
        inc(idx)
  else:
    var subscripts = subs
    subscripts.add(@[k,""])
    while(rc == YDB_OK):
      rc = ydb_subscript_next(global, subscripts)
      if rc == YDB_OK:
        x.add(ydbGet(global, subscripts))

proc load[K, V](global: string, subs: seq[string], kv: string; o: var (Table[K, V]|OrderedTable[K, V])) =
  for k, v in pairs(o):
    load(global, subs, kv, k)
    load(global, subs, kv, v)

proc load[T](global: string, subs: seq[string], k: string; o: ref var T) =
  let isSome = o != nil
  if isSome:
    load(global, subs, k, o[])

proc load[T](global: string, subs: seq[string], k: string; o: var Option[T]) =
  let isSome = isSome(o)
  if isSome:
    load(global, subs, k, get(o))

proc load[T: var tuple](global: string, subs: seq[string], k: string; o: var T) =
  for k,v in fieldPairs(o):
    load(global, subs, k, v)

proc load[T](global: string, subs: seq[string], k: string; o: var T) =
  for k,v in fieldPairs(o):
    let gbl = "^" & $T
    load(gbl, subs, k, v)

proc load*[T: var object](subs: seq[string]; o: var T) =
  let gbl = "^" & $typeof(o)
  load(gbl, subs, o)

proc load*[T: var object](gbl: string, subs: seq[string]; o: var T) =
  echo "LOAD gbl:",gbl, " subs:", subs, " o:",o
  for k,v in fieldPairs(o):
    load(gbl, subs, k, v)


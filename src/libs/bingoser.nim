import macros, strutils, options, tables, sets, json
import ydbapi

# Public API
proc saveObject*[T: object](subs: seq[string]; o: T);
proc loadObject*[T](subs: seq[string]): T;
proc deleteObject*[T](subs: seq[string]);

# Private API
proc store(global: string, subs: seq[string], k: string; x: bool);
proc store(global: string, subs: seq[string], k: string; x: char);
proc store(global: string, subs: seq[string], k: string; x: string);
proc store[T: SomeNumber](global: string, subs: seq[string], k: string; x: T);
proc store[T: enum](global: string, subs: seq[string], k: string; x: T);
proc store[S, T](global: string, subs: seq[string], k: string; x: array[S, T]);
proc store[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] | set[T]);
proc store[K, V](global: string, subs: seq[string], kv: string; o: (Table[K, V]|OrderedTable[K, V]));
proc store[T](global: string, subs: seq[string], k: string; o: Option[T]);
proc store[T: tuple](global: string, subs: seq[string], k: string; o: T);
proc store[T](global: string, subs: seq[string], k: string; o: T);
proc store[T: object](subs: seq[string]; o: T);

proc load(global: string, subs: seq[string], k: string; x: var bool);
proc load(global: string, subs: seq[string], k: string; x: var char);
proc load(global: string, subs: seq[string], k: string; x: var string);
proc load[T: var SomeNumber](global: string, subs: seq[string], k: string; x: var T);
proc load[T: enum](global: string, subs: seq[string], k: string; x: var T);
proc load[T](global: string, subs: seq[string], k: string; x: var set[T]);
proc load[S, T](global: string, subs: seq[string], k: string; x: var array[S, T]);
proc load[T: var SomeSet](global: string, subs: seq[string], k: string; x: var T );
proc load[T](global: string, subs: seq[string], k: string; x: var seq[T] );
proc load[K, V](global: string, subs: seq[string], kv: string; o: var (Table[K, V]|OrderedTable[K, V]));
proc load[T](global: string, subs: seq[string], k: string; o: var Option[T]);
proc load[T: var tuple](global: string, subs: seq[string], k: string; o: var T);
proc load[T](global: string, subs: seq[string], k: string; o: var T);
proc load[T: var object](gbl: string, subs: seq[string]; o: var T);

proc delete(global: string, subs: seq[string], k: string; x: bool);
proc delete(global: string, subs: seq[string], k: string; x: char);
proc delete(global: string, subs: seq[string], k: string; x: string);
proc delete[T: SomeNumber](global: string, subs: seq[string], k: string; x: T);
proc delete[T: enum](global: string, subs: seq[string], k: string; x: T);
proc delete[S, T](global: string, subs: seq[string], k: string; x: array[S, T]);
proc delete[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] | set[T]);
proc delete[K, V](global: string, subs: seq[string], kv: string; o: (Table[K, V]|OrderedTable[K, V]));
proc delete[T](global: string, subs: seq[string], k: string; o: Option[T]);
proc delete[T: tuple](global: string, subs: seq[string], k: string; o: T);
proc delete[T](global: string, subs: seq[string], k: string; o: T);
proc delete[T: object](subs: seq[string]; o: T);

#-----------------------------
# Index management
#-----------------------------

type
  UpdateMode = enum 
    Update
    Delete

type 
  FieldValue = object
    table: string
    fieldIndex: string
    value: string
    fieldId: string
    idValue: string

template INDEX*(id: string) {.pragma.}
#[ type
  Customer = object
    id: int
    name {.INDEXED: "id".}: string
    country {.INDEXED: "id".}: string
    age: int
 ]#

# Extract customePragmas
proc getIndexedFields[T](obj: T): Table[string, string] =
  result = initTable[string, string]()
  # Wir iterieren über alle Felder
  for name, value in fieldPairs(obj):
    # WICHTIG: Prüfung findet zur Compilezeit pro Feld statt
    when value.hasCustomPragma(INDEX):
      # Extrahiere den Wert des Pragmas (z.B. "id")
      const refKey = value.getCustomPragmaVal(INDEX)
      # Füge das Mapping hinzu: Feldname -> Referenzschlüssel
      result[name] = refKey
    else:
      # Felder ohne Pragma werden einfach ignoriert
      discard


proc updateIndex[T](o: T, updateMode: UpdateMode) =
  # Update INDEXED fields
  var fieldValues: seq[FieldValue]
  let idxtab = getIndexedFields(o)
  for k,v in idxtab.pairs():  # k:email, v:id
    var fieldvalue: FieldValue
    fieldValue.table = $T
    # search for indexed field
    for fn, fv in fieldPairs(o):
      if fn == k: 
        fieldvalue.fieldIndex = fn
        fieldvalue.value = $fv
        break
    # search for ID field
    for fn, fv in fieldPairs(o):
      if fn == v: 
        fieldvalue.fieldId = fn
        fieldvalue.idValue = $fv
        break
    fieldValues.add(fieldValue)

  # Update the DB
  for field in fieldValues:
    let gblname = "^" & field.table & toUpper(field.fieldIndex)
    if field.value.isEmptyOrWhitespace:
      if updateMode == Update:
        ydb_set(gblname, @["%", field.idValue], "") # prevent emptyindex error
      else:
        ydb_delete_node(gblname, @["%", field.idValue]) # prevent emptyindex error
    else:
      if updateMode == Update:
        ydb_set(gblname, @[field.value, field.idValue], "")
      else:
        ydb_delete_node(gblname, @[field.value, field.idValue])  

#----------------------------
# Field management
#----------------------------
macro fillFrom*(obj: var auto, data: JsonNode) =
  ## Iteriert über alle Felder des Objekts und sucht den passenden Key im JSON.
  let objType = obj.getTypeImpl()
  result = newStmtList()
  
  # Wir holen uns die Felder des Objekts (Typ-Definition)
  # Bei 'object of RootObj' liegen die Felder oft tiefer im AST
  let fields = if objType[2].kind == nnkRecList: objType[2] else: objType[2][1]

  for field in fields:
    let name = field[0].strVal
    let nameIdent = field[0]
    result.add quote do:
      if `data`.hasKey(`name`):
        when `obj`.`nameIdent` is int:
          `obj`.`nameIdent` = `data`[`name`].getInt()
        elif `obj`.`nameIdent` is string:
          `obj`.`nameIdent` = `data`[`name`].getStr()
        elif `obj`.`nameIdent` is bool:
          `obj`.`nameIdent` = `data`[`name`].getBool()


#-----------------------------
# DB write / read
#-----------------------------

proc saveInYdb(global: string, subs: seq[string], key: string, value: string) =
  var subscpy = subs
  subscpy.add(key)
  ydb_set(global, subscpy, value)


proc loadFromYdb(global: string, subs: seq[string], key: string): string =
  var subscpy = subs
  subscpy.add(key)
  result = ydb_get(global, subscpy)


#-----------------------------
# Object Serialization
#-----------------------------

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

proc store[T: object](subs: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  for fn, fv in fieldPairs(o):
    store(gbl, subs, fn, fv)

proc saveObject*[T: object](subs: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  let data = ydb_data(gbl, subs)
  if data > 0:
    var oldobj = loadObject[T](subs)
    updateIndex(oldobj, Delete)

  # Save the new/updated object
  for fn, fv in fieldPairs(o):
    store(gbl, subs, fn, fv)
  updateIndex(o, Update)


#-----------------------------
# Object Deserialisation
#-----------------------------

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
  let s = loadFromYdb(global, subs, k)
  when T is SomeInteger:
    x = parseInt(s).T
  else:
    x = parseFloat(s).T

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
  while true:
    let subkey = ydb_subscript_next(global, subscripts)
    if subkey.len == 0: break
    subscripts[^1] = subkey
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
  while true:
    let subkey = ydb_subscript_next(global, subscripts)
    if subkey.len == 0: break
    subscripts[^1] = subkey
    x.incl(ydb_get(global, subscripts))
    inc(idx)

# seq[T] | seq[T of object]
proc load[T](global: string, subs: seq[string], k: string; x: var seq[T] ) =
  when T is object:
    var subscripts = subs
    subscripts.add("")
    let gbl = "^" & $T
    while true:
      let subkey = ydb_subscript_next(gbl, subscripts)
      if subkey.len == 0: break
      subscripts[^1] = subkey
      var t:T = T()
      load(gbl, subscripts, t)
      x.add(t)
  else:
    var subscripts = subs
    subscripts.add(@[k,""])
    while true:
      let subkey = ydb_subscript_next(global, subscripts)
      if subkey.len == 0: break
      subscripts[^1] = subkey
      x.add(ydb_get(global, subscripts))

proc load[K, V](global: string, subs: seq[string], kv: string; o: var (Table[K, V]|OrderedTable[K, V])) =
  for fn, fv in pairs(o):
    load(global, subs, kv, fn)
    load(global, subs, kv, fv)

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
      load(gbl, subs, fn, fv)

proc load[T: var object](gbl: string, subs: seq[string]; o: var T) =
  for fn, fv in fieldPairs(o):
    load(gbl, subs, fn, fv)

proc loadObject*[T](subs: seq[string]): T =
  let gbl = "^" & $T
  load(gbl, subs, result)


#----------------------
# Delete Object
#----------------------

proc delete(global: string, subs: seq[string], k: string; x: bool) =
  echo "214"
proc delete(global: string, subs: seq[string], k: string; x: char) =
  echo "216"
proc delete(global: string, subs: seq[string], k: string; x: string) =
  echo "218"
proc delete[T: SomeNumber](global: string, subs: seq[string], k: string; x: T) =
  echo "220"
proc delete[T: enum](global: string, subs: seq[string], k: string; x: T) =
  echo "222"
proc delete[S, T](global: string, subs: seq[string], k: string; x: array[S, T]) =
  echo "224"
proc delete[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] | set[T]) =
  echo "226"
proc delete[K, V](global: string, subs: seq[string], kv: string; o: (Table[K, V]|OrderedTable[K, V])) =
  echo "228"
proc delete[T](global: string, subs: seq[string], k: string; o: Option[T]) =
  echo "230"
proc delete[T: tuple](global: string, subs: seq[string], k: string; o: T) = 
  echo "232"
proc delete[T](global: string, subs: seq[string], k: string; o: T) =
  echo "234"
proc delete[T: object](subs: seq[string]; o: T) =
  echo "236"


proc deleteObject*[T](subs: seq[string]) =
  let gbl = "^" & $T
  # load the record to update the indexes
  var obj:T
  load(gbl, subs, obj)
  updateIndex(obj, Delete)
  # Delete the basic object tree (TODO: recursive scan)
  ydb_delete_tree(gbl, subs)

import macros, streams, options, tables, sets
from typetraits import supportsCopyMem
import yottadb_api

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
  #echo "global: ", global, " subs:", subscpy, " value:", value
  ydbSet(global, subscpy, value)

# serialization
proc store(global: string, subs: seq[string], k: string; x: bool) =
  saveInYdb(global, subs, k, $x)
  
proc store(global: string, subs: seq[string], k: string; x: char) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: SomeNumber](global: string, subs: seq[string], k: string; x: T) =
  saveInYdb(global, subs, k, $x)
  
proc store[T: enum](global: string, subs: seq[string], k: string; x: T) =
  echo "store T:", x
  saveInYdb(global, subs, k, $x)
  
proc store[T](global: string, subs: seq[string], k: string; x: set[T]) =
#  saveInYdb(global, subs, k, $x)
  echo "store setT:", x
  var idx = 0
  for elem in x.items():
    # if its a Type
    when T is RootObj:
      var subscpy = subs
      subscpy.add($idx)
      store(global, subscpy, elem)
    else:
      # it's a seq[string],...
      var subscpy = subs
      subscpy.add(k)
      subscpy.add($idx)
      ydbSet(global, subscpy, $elem)
    
    inc(idx)
  
proc store(global: string, subs: seq[string], k: string; x: string) =
  saveInYdb(global, subs, k, $x)

proc store[S, T](global: string, subs: seq[string], k: string; x: array[S, T]) =
  echo "store array ST:", x
  for elem in items(x):
    store(global, subs, k, elem)

proc store[T](global: string, subs: seq[string], k: string; x: seq[T] | SomeSet[T] ) =
  echo "store seq ", x
  var idx = 0
  for elem in x.items():
    # if its a Type
    when T is RootObj:
      var subscpy = subs
      subscpy.add($idx)
      store(global, subscpy, elem)
    else:
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
  echo "store OrderedTable KV",o
  for k, v in pairs(o):
    store(global, subs, kv, k)
    store(global, subs, kv, v)

proc store[T](global: string, subs: seq[string], k: string; o: ref T) =
  echo "store ref T:", o
  let isSome = o != nil
  if isSome:
    store(global, subs, k, o[])

proc store[T](global: string, subs: seq[string], k: string; o: Option[T]) =
  echo "store Option T:", o
  let isSome = isSome(o)
  if isSome:
    store(global, subs, k, get(o))

proc store[T: tuple](global: string, subs: seq[string], k: string; o: T) =
  echo "store global/subs T:",o
  for k,v in fieldPairs(o):
    store(global, subs, k, v)

proc store*[T: object](subscripts: seq[string]; o: T) =
  echo "store T:",o
  let gbl = "^" & $typeof(o)
  for k,v in fieldPairs(o):
    store(gbl, subscripts, k, v)

proc store*[T: object](global: string, subscripts: seq[string]; o: T) =
  let gbl = "^" & $typeof(o)
  for k,v in fieldPairs(o):
    store(gbl, subscripts, k, v)


# deserialization
proc initFromBin*(dst: var bool; s: Stream) =
  read(s, dst)
proc initFromBin*(dst: var char; s: Stream) =
  read(s, dst)
proc initFromBin*[T: SomeNumber](dst: var T; s: Stream) =
  read(s, dst)
proc initFromBin*[T: enum](dst: var T; s: Stream) =
  read(s, dst)
proc initFromBin*[T](dst: var set[T]; s: Stream) =
  read(s, dst)

proc initFromBin*(dst: var string; s: Stream) =
  let len = s.readInt64().int
  dst.setLen(len)
  if readData(s, cstring(dst), len) != len:
    raise newException(IOError, "cannot read from stream")

proc initFromBin*[T](dst: var seq[T]; s: Stream) =
  let len = s.readInt64().int
  dst.setLen(len)
  when not isCustom(T) and supportsCopyMem(T):
    if len > 0:
      let bLen = len * sizeof(T)
      if readData(s, dst[0].addr, bLen) != bLen:
        raise newException(IOError, "cannot read from stream")
  else:
    for i in 0 ..< len:
      initFromBin(dst[i], s)

proc initFromBin*[S, T](dst: var array[S, T]; s: Stream) =
  when not isCustom(T) and supportsCopyMem(T):
    if readData(s, dst.addr, sizeof(dst)) != sizeof(dst):
      raise newException(IOError, "cannot read from stream")
  else:
    for i in low(dst) .. high(dst):
      initFromBin(dst[i], s)

proc initFromBin*[T](dst: var SomeSet[T]; s: Stream) =
  let len = s.readInt64().int
  for i in 0 ..< len:
    var tmp: T
    initFromBin(tmp, s)
    dst.incl(tmp)

proc initFromBin*[K, V](dst: var (Table[K, V]|OrderedTable[K, V]); s: Stream) =
  let len = s.readInt64().int
  for i in 0 ..< len:
    var key: K
    initFromBin(key, s)
    initFromBin(mgetOrPut(dst, key, default(V)), s)

proc initFromBin*[T](dst: var ref T; s: Stream) =
  let isSome = readBool(s)
  if isSome:
    new(dst)
    initFromBin(dst[], s)
  else:
    dst = nil

proc initFromBin*[T](dst: var Option[T]; s: Stream) =
  let isSome = readBool(s)
  if isSome:
    var tmp: T
    initFromBin(tmp, s)
    dst = some(tmp)
  else:
    dst = none[T]()

proc initFromBin*[T: tuple](dst: var T; s: Stream) =
  when not isCustom(T) and supportsCopyMem(T):
    read(s, dst)
  else:
    for v in fields(dst):
      initFromBin(v, s)

template getFieldValue(stream, tmpSym, fieldSym) =
  initFromBin(tmpSym.fieldSym, stream)

template getKindValue(stream, tmpSym, kindSym, kindType) =
  var kindTmp: kindType
  initFromBin(kindTmp, stream)
  tmpSym = (typeof tmpSym)(kindSym: kindTmp)

proc foldObjectBody(typeNode, tmpSym, stream: NimNode): NimNode =
  case typeNode.kind
  of nnkEmpty:
    result = newNimNode(nnkNone)
  of nnkRecList:
    result = newStmtList()
    for it in typeNode:
      let x = foldObjectBody(it, tmpSym, stream)
      if x.kind != nnkNone: result.add x
  of nnkIdentDefs:
    expectLen(typeNode, 3)
    let fieldSym = typeNode[0]
    result = getAst(getFieldValue(stream, tmpSym, fieldSym))
  of nnkRecCase:
    let kindSym = typeNode[0][0]
    let kindType = typeNode[0][1]
    result = getAst(getKindValue(stream, tmpSym, kindSym, kindType))
    let inner = nnkCaseStmt.newTree(nnkDotExpr.newTree(tmpSym, kindSym))
    for i in 1..<typeNode.len:
      let x = foldObjectBody(typeNode[i], tmpSym, stream)
      if x.kind != nnkNone: inner.add x
    result.add inner
  of nnkOfBranch, nnkElse:
    result = copyNimNode(typeNode)
    for i in 0..typeNode.len-2:
      result.add copyNimTree(typeNode[i])
    let inner = newNimNode(nnkStmtListExpr)
    let x = foldObjectBody(typeNode[^1], tmpSym, stream)
    if x.kind != nnkNone: inner.add x
    result.add inner
  of nnkObjectTy:
    expectKind(typeNode[0], nnkEmpty)
    expectKind(typeNode[1], {nnkEmpty, nnkOfInherit})
    result = newNimNode(nnkNone)
    if typeNode[1].kind == nnkOfInherit:
      let base = typeNode[1][0]
      var impl = getTypeImpl(base)
      while impl.kind in {nnkRefTy, nnkPtrTy}:
        impl = getTypeImpl(impl[0])
      result = foldObjectBody(impl, tmpSym, stream)
    let body = typeNode[2]
    let x = foldObjectBody(body, tmpSym, stream)
    if result.kind != nnkNone:
      if x.kind != nnkNone:
        for i in 0..<result.len: x.add(result[i])
        result = x
    else: result = x
  else:
    error("unhandled kind: " & $typeNode.kind, typeNode)

macro assignObjectImpl(dst: typed; s: Stream): untyped =
  let typeSym = getTypeInst(dst)
  result = newStmtList()
  let x = foldObjectBody(typeSym.getTypeImpl, dst, s)
  if x.kind != nnkNone: result.add x

proc initFromBin*[T: object](dst: var T; s: Stream) =
  when not isCustom(T) and supportsCopyMem(T):
    read(s, dst)
  else:
    assignObjectImpl(dst, s)

# proc binTo*[T](global: string, subs: seq[string], t: typedesc[T]): T =
#   ## Unmarshals the specified Stream into the type specified.
#   ##
#   ## Known limitations:
#   ##
#   ##   * Sets in object variants are not supported.
#   ##   * Not nil annotations are not supported.
#   ##
#   initFromBin(result, s)

# proc loadBin*[T](global: string, subs: seq[string], dst: var T) =
#   ## Unmarshals the specified Stream into the location specified.
#   initFromBin(dst, s)

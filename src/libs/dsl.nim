import macros
import std/strutils
import std/strformat
import std/[json]
import libs/ydbtypes
import libs/ydbimpl
import libs/parsers
import libs/libydb
import zippy
import lz4
import zstd/decompress

when compileOption("profiler"):
  import std/nimprof

const 
    PREFIX_CHARS = {'^', '+', '-', '$', '@'}
    INDIRECTION = "@"
    INDIRECTION_KEYS = "@["
    VALUEMARK = "!"
    TYPEDESC = "†"
    DATAVAL = "∂"
    FIELDMARK = "|"
    DEFAULT="default"
    BY = "by"
    TIMEOUT = "timeout"
    EMPTY_KEYS = @[]
    EMPTY_STRING = ""
    # Postfixes for Query/prevnode/.. iterators
    COUNT = "COUNT"
    KEY = "KEY"
    KEYS = "KEYS"
    KV = "KV"
    SV = "SV"
    REVERSE = "REVERSE"
    VAL = "VAL"
    # type postfix
    INT = "INT"
    INT8 = "INT8"
    INT16 = "INT16"
    INT32 = "INT32"
    INT64 = "INT64"
    UINT = "UINT"
    UINT8 = "UINT8"
    UINT16 = "UINT16"
    UINT32 = "UINT32"
    UINT64 = "UINT64"
    FLOAT = "FLOAT"
    FLOAT64 = "FLOAT64"
    BOOL = "BOOL"
    # for seq[str|int|float]bool]
    SEQSTRING = "SEQSTRING"
    SEQINT = "SEQINT"
    SEQFLOAT = "SEQFLOAT"
    SEQBOOL = "SEQBOOL"
    GZIP = "GZIP"
    ZLIB = "ZLIB"
    LZ4 = "LZ4"
    ZSTD = "ZSTD"
    BROTLI = "BROTLI"


const
  MAX_RESTARTS = 4

func fasttrim*(str: string): string {.inline.} =
  # remove surrounding whitespace and a pair of double quotes:
  #   ^GBL("os")  ->  os
  var first = 0
  var last = str.len - 1

  # Fast skip whitespace from start
  while first <= last and str[first] == ' ':  # in Whitespace:
    inc first

  # Fast skip whitespace from end
  while last >= first and str[last] == ' ':  # in Whitespace:
    dec last

  # Strip matching double quotes if they exist
  if first < last and str[first] == '"' and str[last] == '"':
    inc first
    dec last

  if first > last:
    return ""
    
  # str.substr(first, last) is cleaner and avoids the extra allocation overhead 
  # of the explicit slice `str[first .. last]` in older Nim versions.
  if first == 0 and last == str.len - 1:
    return str
  else:
    return str.substr(first, last)


func keysToString(global: string, subs: Subscripts): string {.inline.} =
  result = global
  result.add("(")
  result.add(subs.join(","))
  result.add(")")


func stringToSeq(s: string): Subscripts {.inline.} =
    # Convert ^Global(1,2,3) -> @["1", "2", "3"]
    # Pre-count subscripts so the result seq never needs to reallocate
    var cap = 1
    for c in s:
        if c == ',': inc cap
    result = newSeqOfCap[string](cap)

    var str: string = newString(s.len)
    var idx = 0
    for c in s:
        if c in {'@', '[', ']', '\\', ' ', '"'} :            
            continue
        elif c == ',':
            result.add(str[0..idx-1])
            idx = 0
        else:
            str[idx] = c
            inc idx

    if idx > 0:
        result.add(str[0..idx-1])


func expandSubsContains(subs: Subscripts): Subscripts =
  # Split every subscript that *contains* a sequence marker '@[..]'
  # (used by the single-variable macros: Get/Data/Increment/Query/Order).
  var needed = false
  for s in subs:
    if INDIRECTION_KEYS in s:
      needed = true
      break
  if not needed: return subs
  result = newSeqOfCap[string](subs.len)
  for s in subs:
    if INDIRECTION_KEYS in s:
      result.add(stringToSeq(s))
    else:
      result.add(s)


func expandSubsPrefix(subs: Subscripts): Subscripts =
  # Split every subscript that *starts* with a sequence marker '@[..]'
  # (used by the multi-variable macros: Set/Kill/Killnode/Delexcl/Lock).
  var needed = false
  for s in subs:
    if s.startsWith(INDIRECTION_KEYS):
      needed = true
      break
  if not needed: return subs
  result = newSeqOfCap[string](subs.len)
  for s in subs:
    if s.startsWith(INDIRECTION_KEYS):
      result.add(stringToSeq(s))
    else:
      result.add(s)


func resolveIndirectionSubs(name: string, rest: Subscripts): (string, Subscripts) =
  # Split an indirection name like "^gbl(1,2)" into ("^gbl", @["1","2", rest...]).
  # Mirrors the former single-variable parser (trim-based, with the historical
  # behavior of appending `rest` after every split part).
  let openPar = name.find('(')
  if openPar != -1:
    let closePar = name.rfind(')')
    var subs: Subscripts
    for idx in name[openPar + 1 ..< closePar].split(','):
      subs.add(fasttrim(idx))
      subs.add(rest)
    result = (name[0 ..< openPar], subs)
  else:
    result = (name, rest)


proc resolveVar(ydbvar: YdbVar): YdbVar =
  ## Single-variable normalization: split indirection names and expand '@[' subscripts.
  result = ydbvar
  if ydbvar.prefix == INDIRECTION:
    let (nm, subs) = resolveIndirectionSubs(ydbvar.name, ydbvar.subscripts)
    result.name = nm
    result.subscripts = subs
  result.subscripts = expandSubsContains(result.subscripts)


proc resolveVarPrefix(ydbvar: YdbVar): YdbVar =
  ## Multi-variable normalization: split indirection names and expand '@[' subscripts.
  result = ydbvar
  if ydbvar.prefix == INDIRECTION:
    let openPar = ydbvar.name.find('(')
    if openPar != -1:
      let closePar = ydbvar.name.rfind(')')
      result.name = ydbvar.name[0 ..< openPar]
      result.subscripts = stringToSeq(ydbvar.name[openPar + 1 ..< closePar]) & ydbvar.subscripts
  result.subscripts = expandSubsPrefix(result.subscripts)


func needsNormalization(v: YdbVar): bool {.inline.} =
  ## Whether `resolveVar` / `resolveVarPrefix` would change the variable.
  ## Only indirection names (`@gbl`, possibly with embedded subscripts) and
  ## subscripts containing the sequence marker `@[` need normalization; for
  ## everything else the `x` procs can work directly on the passed YdbVar and
  ## skip its copy.
  if v.prefix == INDIRECTION: return true
  for s in v.subscripts:
    if INDIRECTION_KEYS in s: return true
  false


proc getApiName(basename: string; args: var seq[NimNode]): (string, bool) =
  ## Compose the runtime proc name from the trailing `.postfix` pairs that
  ## `transform` appended as (`TYPEDESC`, `$postfix`), e.g. for
  ##   Get ^Seq(1).seqInt.gzip  ->  [.., "†", seqInt, "†", gzip]
  ## GZIP/ZLIB are collected into `secondArg` and appended last, so the
  ## compression postfix is position-independent (.seqInt.gzip == .gzip.seqInt).
  var reverse: bool
  var apiName = basename & "x"
  var secondArg: string

  # Scan from the end (outermost postfix first) and drop the consumed pairs with
  # a single `setLen`, instead of re-slicing the whole seq on every postfix.
  var i = args.high
  while i >= 2 and args[i-1].kind == nnkStrLit and args[i-1].strVal == TYPEDESC:
    let arg = args[i][1].strVal.toUpperAscii()
    case arg
    of INT, INT8, INT16, INT32, INT64,
       UINT, UINT8, UINT16, UINT32, UINT64,
       FLOAT, FLOAT64, BOOL,
       KEY, KEYS, KV, SV, COUNT, VAL,
       SEQSTRING, SEQINT, SEQFLOAT, SEQBOOL:
      apiName.add(arg)
    of REVERSE:
      reverse = true
    of GZIP, ZLIB, LZ4, ZSTD, BROTLI:
      secondArg = arg
    else:
      raise newException(YdbError, fmt"Unsupported postfix '{arg}'")
    dec i, 2

  args.setLen(i + 1)
  if secondArg.len > 0:
    apiName.add(secondArg)
  (apiName, reverse)

# ------------------
# Macro procs
# ------------------
# proc exploreNode(node: NimNode) =
#     for n in node:
#         echo "  ", repr(n), "' (", n.kind,")"
#         if n.len > 0:
#             for nn in n:
#                 echo "     ", repr(nn), "' (", nn.kind,")"

# ------------------
# Macro procs
# ------------------
template transformCallNode(node: NimNode) =
    case node.kind
    of nnkStrLit, nnkPrefix:  # "abc" / let id=4711; Get ^gbl($id)
        args.add(node)
    of nnkIdent, nnkInfix, nnkDotExpr, nnkIntLit, nnkFloatLit, nnkCharLit, nnkBracketExpr:
        args.add(newCall(ident"$", node))
    else:
        raise newException(Exception, "transformCallNode: node.kind:" & $node.kind & " not supported! node=" & repr(node))


func transform(node: NimNode, args: var seq[NimNode], attributes: seq[string] = @[]) =
    case node.kind
    of nnkTupleConstr:        
        for i in 0..<node.len:
            transform(node[i], args, attributes)
    of nnkCurly:
        for i in 0..<node.len:
            transform(node[i], args, attributes)
            args.add(newLit(FIELDMARK))
    of nnkPrefix:
        if node.len > 1 and node[1].kind == nnkBracket and node[0].strVal == INDIRECTION:
            # Ignore '@'  ^gbl(@["abc",4711])
            discard
        else:
          args.add(newLit(node[0].strVal))
        transform(node[1], args, attributes)
    of nnkIdent, nnkInfix:
        if args.len > 0 and (args[0].strVal == INDIRECTION or args[^1].strVal == INDIRECTION):
            args.add(node)
        else:
            args.add(newLit(node.strVal))
    of nnkCall:
        if node.len > 1 and node[0].kind == nnkPrefix and node[0][0].strVal == INDIRECTION: # Get @gbl("field") extend index
            for i in 0..<node.len:
                if node[i].kind == nnkPrefix:
                    if node[i][0].strVal == "$":
                        args.add(newCall(ident"$", node[i][1])) # add variable ($id)
                    else:
                        transform(node[i], args, attributes)    
                else:
                    transformCallNode(node[i])
        elif node.len > 1 and node[1].kind == nnkPrefix and node[1][0].strVal == INDIRECTION: # seq[]
            args.add(newLit(node[0].strVal)) # the variable name
            for i in 1..<node.len:
                transform(node[i], args, attributes)
        else:
            args.add(newLit(node[0].strVal)) # the variable name
            for i in 1..<node.len:
                transformCallNode(node[i])
    of nnkAsgn:
        transform(node[0], args, attributes) # resolve lhs
        args.add(newLit(VALUEMARK))
        args.add(newCall(ident"$", node[1])) # add value
    of nnkIntLit, nnkFloatLit, nnkCharLit:
        args.add(newCall(ident"$", node))
    of nnkStrLit:
        args.add(node)
    of nnkDiscardStmt:
      discard
    of nnkExprEqExpr:   # by=, timeout=, default=, ... handeled by findAttributes
      args.add(newLit(DATAVAL))
      args.add(newCall(ident"$", node[1]))
    of nnkDotExpr:
        transform(node[0], args, attributes)
        args.add(newLit(TYPEDESC))
        args.add(newCall(ident"$", node[1]))
    of nnkBracket:
        for i in 0..<node.len:
            case node[i].kind
            of nnkPrefix: # [$varname, "x", 4711
                args.add(newCall(ident"$", node[i][1]))
            of nnkIdent, nnkInfix:
                args.add(newCall(ident"$", node[i]))
            else:
                transform(node[i], args, attributes)
    else:
        raise newException(Exception, "Unsupported node.kind:" & $node.kind)


template processStmtList(body: NimNode) =
    if body.kind == nnkStmtList:
        for i in 0..<body.len:
            transform(body[i], args)
            if i < body.len-1: args.add(newLit(FIELDMARK))
    else:
        transform(body, args)

# ----------------------------
# proc related helper proc's
# ----------------------------

# ----------------------------
# Compile-time YdbVar builders
# ----------------------------
# The macros build YdbVar object literals directly instead of emitting a flat
# varargs string array that has to be parsed at runtime.  Structural tokens
# (prefix, name, markers, literal subscripts) are resolved here at compile time;
# runtime expressions (e.g. `$id`) are kept as-is.

proc concatStr(a, b: NimNode): NimNode =
  # Constant-fold `a & b` when both sides are string literals, otherwise emit `&`.
  if a.kind == nnkStrLit and b.kind == nnkStrLit:
    result = newLit(a.strVal & b.strVal)
  else:
    result = newCall(ident"&", a, b)


proc ydbVar*(prefix, name, value, typdesc: string, subscripts: Subscripts): YdbVar {.inline.} =
  # Runtime constructor emitted by the macros to build a YdbVar directly.
  result = YdbVar(prefix: prefix, name: name, value: value, typdesc: typdesc, subscripts: subscripts)


proc makeYdbVar(prefix, name, value, typdesc: NimNode, subscripts: seq[NimNode]): NimNode =
  # Emit an object constructor `YdbVar(...)` instead of a `ydbVar(...)` proc
  # call: the compiler moves the subscript seq into the object, while the proc
  # call would deep-copy it (one allocation per DSL statement).
  var arr = newTree(nnkBracket)
  for s in subscripts:
    arr.add(s)
  result = newTree(nnkObjConstr, bindSym"YdbVar")
  if prefix != nil:
    result.add(newTree(nnkExprColonExpr, ident"prefix", prefix))
  if name != nil:
    result.add(newTree(nnkExprColonExpr, ident"name", name))
  if value != nil:
    result.add(newTree(nnkExprColonExpr, ident"value", value))
  if typdesc != nil:
    result.add(newTree(nnkExprColonExpr, ident"typdesc", typdesc))
  result.add(newTree(nnkExprColonExpr, ident"subscripts",
                     newTree(nnkPrefix, ident"@", arr)))


proc buildYdbVar(args: seq[NimNode]): NimNode =
  ## Compile-time equivalent of the former `seqToYdbVar`.
  var
    prefix: NimNode
    name: NimNode
    value: NimNode
    typdesc: NimNode
    subscripts: seq[NimNode]

  if args.len == 1:
    let a = args[0]
    if a.kind == nnkStrLit:
      let openPar = a.strVal.find('(')
      if openPar != -1:
        let closePar = a.strVal.rfind(')')
        for idx in a.strVal[openPar + 1 ..< closePar].split(','):
          subscripts.add(newLit(fasttrim(idx)))
        name = newLit(a.strVal[0 ..< openPar])
      elif a.strVal.len > 0 and a.strVal[0] in PREFIX_CHARS:
        prefix = newLit($(a.strVal[0]))
        name = a
      else:
        name = a
    else:
      name = a

  elif args[0].kind == nnkStrLit and args[0].strVal.len > 0 and args[0].strVal[0] in PREFIX_CHARS:
    prefix = args[0]
    let arg = args[1]
    if prefix.strVal == INDIRECTION:
      # Indirection: the name (and possibly embedded subscripts) is resolved at runtime by `resolveVar`.
      name = arg
    else:
      let pfx = prefix.strVal
      if pfx.len > 0 and pfx[0] in {'+', '-'}:
        name = concatStr(newLit(pfx[1..^1]), arg)
      else:
        name = concatStr(prefix, arg)

    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
      typdesc = args[^1]
      if subscripts.len == 0: subscripts = args[2 .. ^3]
    elif args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == DATAVAL:
      value = args[^1]
      if subscripts.len == 0:
        subscripts = args[2 .. ^3]
      else:
        subscripts = subscripts[0 .. ^3]
    else:
      if subscripts.len == 0: subscripts = args[2 .. ^1]

  else:
    # local variable (no prefix)
    name = args[0]
    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == DATAVAL:
      value = args[^1]
      if subscripts.len == 0: subscripts = args[1 .. ^3]
    else:
      subscripts = args[1 .. ^1]

  makeYdbVar(prefix, name, value, typdesc, subscripts)


proc buildYdbVarList(args: seq[NimNode]): seq[NimNode] =
  ## Compile-time equivalent of the former `seqToYdbVars`.
  var vars: seq[NimNode]
  var
    prefix: NimNode
    name: NimNode
    value: NimNode
    subscripts: seq[NimNode]   # subscripts already attached to the variable
    subs: seq[NimNode]         # pending bare subscripts (merged on FIELDMARK/VALUEMARK)
    valueset: bool

  proc flush() =
    if subscripts.len == 0:
      subscripts = subs
    vars.add(makeYdbVar(prefix, name, value, nil, subscripts))
    prefix = nil
    name = nil
    value = nil
    subscripts = @[]
    subs = @[]
    valueset = false

  var i = 0
  while i < args.len:
    let arg = args[i]
    if arg.kind == nnkStrLit and arg.strVal == FIELDMARK:
      flush()
      inc i
      continue
    if arg.kind == nnkStrLit and arg.strVal == VALUEMARK:
      value = args[i + 1]
      valueset = true
      subscripts.add(subs)
      subs = @[]
      inc i
      continue

    # Set the prefix field (1..2 bytes)
    if name == nil and prefix == nil:
      if arg.kind == nnkStrLit and
          ((arg.strVal.len == 1 and arg.strVal[0] in PREFIX_CHARS) or
           (arg.strVal.len == 2 and arg.strVal[0] in PREFIX_CHARS and arg.strVal[1] in PREFIX_CHARS)):
        prefix = arg
        inc i
        continue

    # Name assignment
    if name == nil:
      if prefix != nil and prefix.strVal == INDIRECTION:
        # Indirection: resolved at runtime by `resolveVarPrefix`.
        name = arg
      else:
        if prefix != nil and prefix.strVal.len > 0 and prefix.strVal[0] in {'+', '-'}:
          name = concatStr(newLit(prefix.strVal[1..^1]), arg)
        elif prefix != nil:
          name = concatStr(prefix, arg)
        else:
          name = arg
      inc i
      continue

    # Subscript (after the name)
    if arg.kind == nnkStrLit and arg.strVal.startsWith(INDIRECTION_KEYS):
      for s in stringToSeq(arg.strVal):
        subs.add(newLit(s))
    else:
      if not valueset:
        subs.add(arg)
    inc i

  if name != nil:
    flush()

  result = vars


proc buildYdbVars(args: seq[NimNode]): NimNode =
  ## `YdbVar(...)` for a single variable (no seq needed) or
  ## `@[YdbVar(...), ...]` for several.
  let vars = buildYdbVarList(args)
  if vars.len == 1:
    return vars[0]
  var arr = newTree(nnkBracket)
  for v in vars:
    arr.add(v)
  newTree(nnkPrefix, ident"@", arr)


func getTimeout(arg: string): int =
    result = YDB_LOCK_TIMEOUT
    if arg.contains('.'):
      try: # float numeric timeout value?
        let f = parseFloat(arg)
        if f <= 2.147:
          result = (f * 1000000000).int
      except:
        discard
    else:
      try:  # int numeric timeout value?
        let i = parseFastInt(arg)
        if i <= YDB_LOCK_TIMEOUT:
          result = i
      except:
        discard
    if result == 0: result = YDB_LOCK_TIMEOUT

# ----------------------------------------
# YdbVar -> YdbKey bridge
# ----------------------------------------
# The DSL describes a variable as (name, subscripts) in a `YdbVar`, while the
# database API works on a reusable `YdbKey`. Point operations go through a
# per-thread scratch key, so a DSL statement does not allocate a key.

var dslKey {.threadvar.}: YdbKey

proc loadKey(k: var YdbKey, name: string, subs: openArray[string]) =
  ## Overwrite `k` with `name` + `subs`, reusing its buffers.
  k.setName(name)
  k.setSubsLen(0)
  for i in 0 ..< subs.len:
    k.setSub(i, subs[i])

proc keyOf(v: YdbVar): var YdbKey =
  ## Thread-local key for the variable `v`.
  ## The key is reused by the next `keyOf` call in this thread, so use it
  ## immediately; traversal code keeps its own key and is unaffected.
  loadKey(dslKey, v.name, v.subscripts)
  result = dslKey

proc keyOf(name: string, subs: openArray[string]): var YdbKey =
  ## Thread-local key for `name` + `subs` (same lifetime rules as `keyOf(YdbVar)`).
  loadKey(dslKey, name, subs)
  result = dslKey

# --------------------------------------
# macros call's one of this for each macro
# ----------------------------------------

#================
# Data
#================
proc datax*(ydbvar: YdbVar): int =
    if needsNormalization(ydbvar):
        let v = resolveVar(ydbvar)
        return ydb_data(keyOf(v))
    ydb_data(keyOf(ydbvar))

macro Data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    newCall(ident"datax", buildYdbVar(args))

#================
# Get
#================
proc getx*(ydbvar: YdbVar): string {.inline.} =
    if needsNormalization(ydbvar):
        let v = resolveVar(ydbvar)
        result = ydb_get(keyOf(v))
    else:
        result = ydb_get(keyOf(ydbvar))
    if result.len == 0 and ydbvar.value.len > 0:
        return ydbvar.value # return 'default value' if nothing found


func splitSeqValue(s: string): seq[string] =
    # Normalize the two storage formats of a comma-separated value into clean
    # tokens, deciding the format only once:
    #   A,B,C,D...          (saved via `join(seq, ",")`)    -> @["A","B","C",...]
    #   @["A", "B", "C", ...]  (saved via `Set: ^x(1) = seq`) -> @["A","B","C",...]
    if s.startsWith(INDIRECTION_KEYS):
        # strip the surrounding @[ ] and trim quotes/whitespace per element
        result = s[2 .. ^2].split(',')
        for i in 0 ..< result.len:
            result[i] = fasttrim(result[i])
    else:
        result = s.split(',')


proc parseSeq[T](algo: string, ydbvar: YdbVar, uncompress: bool = false): seq[T] =
    var dbdata: string
    if algo == "lz4":
        dbdata = if uncompress: lz4.uncompress(getx(ydbvar)) else: getx(ydbvar)
    elif algo == "zstd":
        if uncompress: 
            var dctx = new_decompress_context()
            let buf = decompress(dctx, getx(ydbvar))
            dbdata = newString(buf.len)
            copyMem(dbdata[0].addr, buf[0].unsafeAddr, buf.len)    
            discard free_context(dctx)
        else:
            dbdata = getx(ydbvar)
    else:
        dbdata = if uncompress: zippy.uncompress(getx(ydbvar)) else: getx(ydbvar)

    when T is string:
        result = splitSeqValue(dbdata)
    else:
        let tokens = splitSeqValue(dbdata)
        result = newSeq[T](tokens.len)
        try:
            for i in 0 ..< tokens.len:
                when T is int:
                    result[i] = parseFastInt(tokens[i])
                when T is float:
                    result[i] = parseFastFloat(tokens[i])
                when T is bool:
                    result[i] = parseFastBool(tokens[i])
        except:
            echo "ERROR: parseSeq: Could not parse seq to numbers"


# The second parameter is the short postfix token used in the macro name:
# .seqString -> getxSEQSTRING, .seqInt -> getxSEQINT, etc.
template defineGetSeq(typeName, alias: untyped) =
  proc `getxseq typename`*(ydbvar: YdbVar): seq[typeName] =
    parseSeq[typeName]("", ydbvar)
  # Postfix: .seqString.gzip / .seqInt.gzip / ...
  proc `getxseq typeName gzip`*(ydbvar: YdbVar): seq[typeName] =    
    parseSeq[typeName]("gzip", ydbvar, uncompress=true)
  # Postfix: .seqString.zlib / .seqInt.zlib / ...    
  proc `getxseq typeName zlib`*(ydbvar: YdbVar): seq[typeName] =    
    parseSeq[typeName]("zlib", ydbvar, uncompress=true)
  proc `getxseq typeName lz4`*(ydbvar: YdbVar): seq[typeName] =    
    parseSeq[typeName]("lz4", ydbvar, uncompress=true)
  proc `getxseq typeName zstd`*(ydbvar: YdbVar): seq[typeName] =    
    parseSeq[typeName]("zstd", ydbvar, uncompress=true)

defineGetSeq(string, str)
defineGetSeq(int, int)
defineGetSeq(float, float)
defineGetSeq(bool, bool)


proc getxgzip*(ydbvar: YdbVar): string =
    zippy.uncompress(getx(ydbvar))

proc getxzlib*(ydbvar: YdbVar): string =
    zippy.uncompress(getx(ydbvar))

proc getxlz4*(ydbvar: YdbVar): string =
    lz4.uncompress(getx(ydbvar))

proc getxzstd*(ydbvar: YdbVar): string =
    var dctx = new_decompress_context()
    let buf = decompress(dctx, getx(ydbvar))
    result = newString(buf.len)
    copyMem(result[0].addr, buf[0].unsafeAddr, buf.len)    
    discard free_context(dctx)

macro Get*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[DEFAULT])
    let (typename, _) = getApiName("get", args)
    newCall(ident(typename), buildYdbVar(args))


# -------------------------------------
# Int / Uint / Float / Bool conversions
# -------------------------------------
        
template defineGetX(typeName, parseFunc: untyped) =
  proc `getx typeName`*(ydbvar: YdbVar): typeName =
    let s = getx(ydbvar)
    if s.len == 0: return cast[typeName](0)
    let tmpvar = parseFunc(s)
    if tmpvar < low(typeName) or tmpvar > high(typeName):
      raise newException(RangeDefect, "Illegal number. Must be in range " & $low(typeName) & ".." & $high(typeName))
    else:
      result = cast[typeName](tmpvar)

defineGetX(int, parseFastInt)
defineGetX(int8, parseFastInt)
defineGetX(int16, parseFastInt)
defineGetX(int32, parseFastInt)
defineGetX(int64, parseFastInt)
defineGetX(uint, parseUInt)
defineGetX(uint8, parseUInt)
defineGetX(uint16, parseUInt)
defineGetX(uint32, parseUInt)
defineGetX(uint64, parseUInt)
defineGetX(float, parseFloat)
#defineGetX(float32, parseFloat) #TODO: cast gives strange results
defineGetX(float64, parseFloat)
defineGetX(bool, parseFastBool)


#================
# Killnode
#================
proc killnodex*(ydbvars: seq[YdbVar]) =
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            ydb_delete(keyOf(v), YDB_DEL_NODE)
        else:
            ydb_delete(keyOf(ydbvar), YDB_DEL_NODE)

proc killnodex*(ydbvar: YdbVar) =
    if needsNormalization(ydbvar):
        let v = resolveVarPrefix(ydbvar)
        ydb_delete(keyOf(v), YDB_DEL_NODE)
    else:
        ydb_delete(keyOf(ydbvar), YDB_DEL_NODE)

macro Killnode*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"killnodex", buildYdbVars(args))


#================
# Kill
#================
proc killx*(ydbvars: seq[YdbVar]) =
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            ydb_delete(keyOf(v), YDB_DEL_TREE)
        else:
            ydb_delete(keyOf(ydbvar), YDB_DEL_TREE)

proc killx*(ydbvar: YdbVar) =
    if needsNormalization(ydbvar):
        let v = resolveVarPrefix(ydbvar)
        ydb_delete(keyOf(v), YDB_DEL_TREE)
    else:
        ydb_delete(keyOf(ydbvar), YDB_DEL_TREE)

macro Kill*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"killx", buildYdbVars(args))


#================
# Delexcl
#================
proc delexclx*(ydbvars: seq[YdbVar]) =
    var names: seq[string]
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            names.add(resolveVarPrefix(ydbvar).name)
        else:
            names.add(ydbvar.name)
    ydb_delete_excl(names)

proc delexclx*(ydbvar: YdbVar) =
    var names: seq[string]
    if needsNormalization(ydbvar):
        names.add(resolveVarPrefix(ydbvar).name)
    else:
        names.add(ydbvar.name)
    ydb_delete_excl(names)

macro Delexcl*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"delexclx", buildYdbVars(args))


#================
# Increment
#================
proc incrementx*(ydbvar: YdbVar): int =
    let inc = if ydbvar.value.len == 0: 1 else: parseFastInt(ydbvar.value)
    if needsNormalization(ydbvar):
        let v = resolveVar(ydbvar)
        return ydb_increment(keyOf(v), inc)
    ydb_increment(keyOf(ydbvar), inc)

macro Increment*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[BY])
    newCall(ident"incrementx", buildYdbVar(args))


#================
# Lockdecr
#================
proc lockdecrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Decrement Lock count for variable
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            ydb_lock_decr(keyOf(v))
        else:
            ydb_lock_decr(keyOf(ydbvar))

proc lockincrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Increment Lock count for variable(s)
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            ydb_lock_incr(timeout, keyOf(v))
        else:
            ydb_lock_incr(timeout, keyOf(ydbvar))


#================
# Lock
#================
proc lockx*(initialTimeout: int, ydbvars: seq[YdbVar]) =
    var timeout = initialTimeout
    var vars: seq[Subscripts]
    var incvars: seq[YdbVar]
    var decvars: seq[YdbVar]

    template handleVar(v: YdbVar) =
        # timeout from Lock: ^GBL, timeout=12345
        if v.name == DATAVAL:
            discard
        elif v.name == TIMEOUT and v.value != "":
            timeout = getTimeout(v.value)
        elif v.prefix.len > 0 and v.prefix[0] in {'+', '-'}:
            if v.prefix[0] == '+': incvars.add(v)
            else: decvars.add(v)
        else:
            var subs: seq[string]
            subs.add(v.name)
            for sub in v.subscripts:
                subs.add(sub)
            if subs.len == 1: subs.add("") # Lock only on variable add empty subscripts
            vars.add(subs)

    # create seq of subscripts for each var
    # @[@["^XXX", ""], @["^GBL", "2"], @["^GBL", "2", "3"], @["^GBL", "2", "3", "abc"]]
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            handleVar(v)
        else:
            handleVar(ydbvar)

    # set locks, or release all
    if vars.len > 0 or (vars.len == 0 and incvars.len == 0 and decvars.len == 0):
        ydb_lock(timeout, vars)

    # Increment / Decrement locks?
    if incvars.len > 0:
        lockincrx(timeout, incvars)
    if decvars.len > 0:
        lockdecrx(timeout, decvars)

proc lockx*(initialTimeout: int, ydbvar: YdbVar) =
    # single variable: no seq of YdbVar is built for the common case
    lockx(initialTimeout, @[ydbvar])

macro Lock*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    # timeout is passed as a plain int argument (extracted from the DATAVAL marker)
    var timeoutArg: NimNode
    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == DATAVAL:
        timeoutArg = newCall(ident"getTimeout", args[^1])
    else:
        timeoutArg = newLit(YDB_LOCK_TIMEOUT)
    newCall(ident"lockx", timeoutArg, buildYdbVars(args))


#================
# Set:
#================
proc setx*(ydbvars: seq[YdbVar]) =
    for ydbvar in ydbvars:
        if needsNormalization(ydbvar):
            let v = resolveVarPrefix(ydbvar)
            ydb_set(keyOf(v), v.value)
        else:
            ydb_set(keyOf(ydbvar), ydbvar.value)

proc setx*(ydbvar: YdbVar) =
    if needsNormalization(ydbvar):
        let v = resolveVarPrefix(ydbvar)
        ydb_set(keyOf(v), v.value)
    else:
        ydb_set(keyOf(ydbvar), ydbvar.value)

macro Set*(body: untyped): untyped =
    # Set MUST be used in the form 'Set: <varname> = <value>'
    # The Nim compiler will not allow 'Set <varname> = <value>'
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"setx", buildYdbVars(args))

# --------------------
# Query Iterators
# --------------------
# `cur` is a reusable key cursor: `ydb_node_next` / `ydb_node_previous`
# advance it in place, so no key has to be rebuilt per node.
template walkNodes(reverse: static bool, ydbvar: YdbVar, body: untyped) =
  let v = resolveVar(ydbvar)
  let gblName {.inject.} = v.name
  var cur {.inject.} = initYdbKey(v.name, v.subscripts)
  var subs {.inject.}: seq[string]
  var rc {.inject.} = when reverse: ydb_node_previous(cur) else: ydb_node_next(cur)
  while rc == YDB_OK:
    subs = cur.subscripts()
    body
    rc = when reverse: ydb_node_previous(cur) else: ydb_node_next(cur)

# returns ^global(key,..)
iterator QueryItrx*(reverse: static bool, ydbvar: YdbVar): string =
  walkNodes(reverse, ydbvar):
    yield keysToString(gblName, subs)

# returns @["1"], @["2"], ...
iterator QueryItrxKEYS*(reverse: static bool, ydbvar: YdbVar): seq[string] =
  walkNodes(reverse, ydbvar):
    yield subs

iterator QueryItrxKV*(reverse: static bool, ydbvar: YdbVar): (string, string) =
  walkNodes(reverse, ydbvar):
    yield (keysToString(gblName, subs), ydb_get(cur))

iterator QueryItrxSV*(reverse: static bool, ydbvar: YdbVar): (seq[string], string) =
  walkNodes(reverse, ydbvar):
    yield (subs, ydb_get(cur))

iterator QueryItrxVAL*(reverse: static bool, ydbvar: YdbVar): string =
  walkNodes(reverse, ydbvar):
    yield ydb_get(cur)

iterator QueryItrxCOUNT*(reverse: static bool, ydbvar: YdbVar): int =
  var cnt = 0
  walkNodes(reverse, ydbvar):
    inc cnt
  yield cnt


# --------------------
# Order Iterators
# --------------------
template walkOrderNodes(reverse: static bool, ydbvar: YdbVar, body: untyped) =
  let v = resolveVar(ydbvar)
  let gblName {.inject.} = v.name
  var cur {.inject.} = initYdbKey(v.name, v.subscripts)
  var subs {.inject.} = v.subscripts
  var nextSub: string
  while true:
    let rc = when reverse: ydb_subscript_previous(cur, nextSub)
             else: ydb_subscript_next(cur, nextSub)
    if rc != YDB_OK: break
    if subs.len > 0: subs[^1] = nextSub
    else: subs.add(nextSub)
    let key {.inject.} = nextSub
    body

# returns ^global(key,..)
iterator OrderItrx*(reverse: static bool, ydbvar: YdbVar): string =
  walkOrderNodes(reverse, ydbvar):
    yield key

iterator OrderItrxKEYS*(reverse: static bool, ydbvar: YdbVar): seq[string] =
  walkOrderNodes(reverse, ydbvar):
    yield subs

iterator OrderItrxVAL*(reverse: static bool, ydbvar: YdbVar): string =
  walkOrderNodes(reverse, ydbvar):
    yield ydb_get(cur)

iterator OrderItrxKV*(reverse: static bool, ydbvar: YdbVar): (string, string) =
  walkOrderNodes(reverse, ydbvar):
    yield (key, ydb_get(cur))

iterator OrderItrxKEY*(reverse: static bool, ydbvar: YdbVar): string =
  walkOrderNodes(reverse, ydbvar):
    yield keysToString(gblName, subs)

iterator OrderItrxCOUNT*(reverse: static bool, ydbvar: YdbVar): int =
  var cnt = 0
  walkOrderNodes(reverse, ydbvar):
    inc cnt
  yield cnt


# ----------------------------------
# Query template and procs
# ---------------------------------- 
type QueryType = enum
    qtNext,
    qtCount,
    qtKey,
    qtKeys,
    qtKv,
    qtValue

template walkQ[T](qt: static QueryType, ydbvar: YdbVar, reverse: static bool): T =
    let v = resolveVar(ydbvar)
    let name = v.name
    var cur = initYdbKey(name, v.subscripts)
    template step(): int =
        when reverse: ydb_node_previous(cur)
        else: ydb_node_next(cur)
    when qt == qtnext:
        let rc = step()
        if rc == YDB_OK: keysToString(name, cur.subscripts())
        else: EMPTY_STRING
    elif qt  == qtCount:
        var cnt = 0
        while step() == YDB_OK:
            inc cnt
        cnt
    elif qt == qtKeys:
        let rc = step()
        if rc == YDB_OK: cur.subscripts()
        else: EMPTY_KEYS
    elif qt == qtKv:
        let rc = step()
        if rc == YDB_OK:
            let subs = cur.subscripts()
            (keysToString(name, subs), ydb_get(cur))
        else:
            (EMPTY_STRING, EMPTY_STRING)
    elif qt == qtValue:
        let rc = step()
        if rc == YDB_OK: ydb_get(cur)
        else: EMPTY_STRING
    else:
        default(T)


# ----------------------------------
# Order template and procs
# ---------------------------------- 
template walkO[T](qt: static QueryType, ydbvar: YdbVar, reverse: static bool): T =
    let v = resolveVar(ydbvar)
    let name = v.name
    var subs = v.subscripts
    var cur = initYdbKey(name, subs)
    var nextSub: string
    template step(): int =
        when reverse: ydb_subscript_previous(cur, nextSub)
        else: ydb_subscript_next(cur, nextSub)
    when qt == qtnext:
        let rc = step()
        if rc == YDB_OK: nextSub
        else: EMPTY_STRING
    elif qt == qtCount:
        while step() == YDB_OK:
          inc result
          if subs.len > 0: subs[^1] = nextSub
          else: subs.add(nextSub)
        result
    elif qt == qtKeys:
        let rc = step()
        if rc != YDB_OK: return @[]
        if subs.len > 0:
            subs[^1] = nextSub
        else:
            subs.add(nextSub)
        subs
    elif qt == qtKey:
        let rc = step()
        if rc == YDB_OK:
            if subs.len > 0:
              subs[^1] = nextSub
            else:
              subs.add(nextSub)
            keysToString(name, subs)
        else:
            EMPTY_STRING
    elif qt == qtKv:
        let rc = step()
        if rc != YDB_OK: return (EMPTY_STRING, EMPTY_STRING)
        if subs.len > 0:
            subs[^1] = nextSub
        else:
            subs.add(nextSub)
        (nextSub, ydb_get(cur))
    else:
        default(T)

#================
# Query:
#================
proc Queryx*(isReverse: static bool, ydbvar: YdbVar): string =
  walkQ[string](qtNext, ydbvar, isReverse)

proc QueryxKEYS*(isReverse: static bool, ydbvar: YdbVar): seq[string] =
  walkQ[seq[string]](qtKeys, ydbvar, isReverse)

proc QueryxKV*(isReverse: static bool, ydbvar: YdbVar): (string, string) =
  walkQ[(string, string)](qtKv, ydbvar, isReverse)

proc QueryxVAL*(isReverse: static bool, ydbvar: YdbVar): string =
  walkQ[string](qtValue, ydbvar, isReverse)

proc QueryxCOUNT*(isReverse: static bool, ydbvar: YdbVar): int =
  walkQ[int](qtCount, ydbvar, isReverse)

macro Query*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName("Query", args)
    newCall(ident(apiName), newLit(reverse), buildYdbVar(args))

macro QueryItr*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName("QueryItr", args)
    newCall(ident(apiName), newLit(reverse), buildYdbVar(args))


#================
# Order:
#================
proc Orderx*(isReverse: static bool, ydbvar: YdbVar): string =
  walkO[string](qtNext, ydbvar, isReverse)

proc OrderxKEY*(isReverse: static bool, ydbvar: YdbVar): string =
  walkO[string](qtKey, ydbvar, isReverse)

proc OrderxKEYS*(isReverse: static bool, ydbvar: YdbVar): seq[string] =
  walkO[seq[string]](qtKeys, ydbvar, isReverse)

proc OrderxKV*(isReverse: static bool, ydbvar: YdbVar): (string, string) =
  walkO[(string, string)](qtKv, ydbvar, isReverse)

proc OrderxVAL*(isReverse: static bool, ydbvar: YdbVar): string =
  walkO[string](qtValue, ydbvar, isReverse)

proc OrderxCOUNT*(isReverse: static bool, ydbvar: YdbVar): int =
  walkO[int](qtCount, ydbvar, isReverse)

macro Order*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName("Order", args)
    newCall(ident(apiName), newLit(reverse), buildYdbVar(args))

macro OrderItr*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName("OrderItr", args)
    newCall(ident(apiName), newLit(reverse), buildYdbVar(args))


#================
# CallM:
#================
proc setupCTX(node: JsonNode, level: var int, subs: var seq[string]) =
  case node.kind
  of JObject:
    for key, value in node.pairs:
      inc level
      if subs.len < level: subs.add(key)
      setupCTX(value, level, subs)
      dec level
      subs.delete(level)
  of JArray:
    for item in node.elems:
      setupCTX(item, level, subs)
  else:
    # (String, Int, etc.) einfach ausgeben
    var value: string
    if node.kind == JString:
        value = node.getStr()
    elif node.kind == JInt:
        value = $node.getInt()
    elif node.kind == JFloat:
        value = $node.getFloat()
    elif node.kind == JBool:
        value = $node.getBool()
    else:
        echo "Unknown datatype ", node.kind
        return
    ydb_set(keyOf("CTX", subs), value)

proc callmx*(args: varargs[string]): string =
    var ctxKey = initYdbKey("CTX")
    ydb_delete(ctxKey, YDB_DEL_NODE)

    if args.len == 2 and args[1][0] == '{' and args[1][^1] == '}': # Try to parse Json
        # JSON passed
        let data = parseJson(args[1])
        var indent : seq[string]
        var level = 0
        setupCTX(data, level, indent)
        # call the callin interface, The RESULT local variable can be readout with Get LOCAL(,,)
    elif args.len == 2:
        # Single argument
        ydb_set(ctxKey, args[1])
    else:
        # Multiple arguments
        for i in 1..<args.len:
            ctxKey.setSub(0, $i)
            ydb_set(ctxKey, args[i])

    ydb_ci(args[0])
    #result = Get RESULT
    var resultKey = initYdbKey("RESULT")
    result = ydb_get(resultKey)


macro CallM*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"callmx", args)


# --------------------------------
# Transaction Macros
# --------------------------------
proc forbidRedeclare(body: NimNode; names: openArray[string]) =
  for n in body:
    if n.kind in {nnkVarSection, nnkLetSection}:
      for def in n:
        let ident = $def[0]
        if ident in names:
          error("Illegal redeclaration of injected symbol '" & ident & "'", def)
    forbidRedeclare(n, names)

# ---------------------------------------------------------------------------------------------------

macro transactionImpl(param: untyped, body: untyped): untyped =
  let isMT = when compileOption("threads"): true else: false
  let fn = genSym(nskProc, "tx")
  let tpParam = genSym(nskVar, "tpParam")

  # Symbols visible inside body
  let forbidden =
    if isMT:
      @["tptoken", "param", "errstr"]
    else:
      @["param"]

  forbidRedeclare(body, forbidden)

  if isMT:
    result = quote do:
      proc `fn`(
        tptoken {.inject.}: uint64,
        errstr  {.inject.}: ptr struct_ydb_buffer_t,
        param   {.inject.}: pointer
      ): cint {.cdecl, gcsafe, raises: [].} =
        TPTOKEN = tptoken
        try:
            `body`
            TPTOKEN = 0
        except:
            if getCurrentException() of TpRestart:
                discard
            else: 
                echo "TPTOKEN=", TPTOKEN, " Exception in transaction:", getCurrentExceptionMsg()
            
            try:
                let restarted = block:
                    var restartKey = initYdbKey("$TRESTART")
                    parseFastInt(ydb_get(restartKey)) # How many times the proc was called from yottadb
                if restarted >= MAX_RESTARTS: 
                    echo "Too many transaction restarts, Rolling back.", getCurrentExceptionMsg()
                    return YDB_TP_ROLLBACK
            except:
                echo "Exception while getting $TRESTART", getCurrentExceptionMsg()
                TPTOKEN = 0
                return YDB_TP_ROLLBACK
            
            return YDB_TP_RESTART

      block:
        # Keep the parameter alive for the whole transaction. Strings, ints and
        # pointers keep their usual meaning; any other value (e.g. an object)
        # is passed by address, so the callback reads it via
        # `cast[ptr T](param)`.
        var `tpParam` = `param`
        when (`tpParam` is string) or (`tpParam` is int) or (`tpParam` is pointer):
          ydb_tp_mt(`fn`, `tpParam`)
        else:
          ydb_tp_mt(`fn`, cast[pointer](addr `tpParam`))
  else:
    result = quote do:
      proc `fn`(param {.inject.}: pointer): cint {.cdecl, raises: [].} =
        TPTOKEN = 0
        try:
            `body`
        except:
            if getCurrentException() of TpRestart: 
                discard
            else: 
                echo "Exception in transaction:", getCurrentExceptionMsg()
            
            try:
                let restarted = block:
                    var restartKey = initYdbKey("$TRESTART")
                    parseFastInt(ydb_get(restartKey)) # How many times the proc was called from yottadb
                if restarted >= MAX_RESTARTS: 
                    echo "Too many transaction restarts, Rolling back.", getCurrentExceptionMsg()
                    return YDB_TP_ROLLBACK
            except:
                echo "Exception while getting $TRESTART", getCurrentExceptionMsg()
                return YDB_TP_ROLLBACK
            return YDB_TP_RESTART

      block:
        # See the multi-threaded branch above: non-string/int/pointer values are
        # passed by address and stay alive for the duration of the call.
        var `tpParam` = `param`
        when (`tpParam` is string) or (`tpParam` is int) or (`tpParam` is pointer):
          ydb_tp(`fn`, `tpParam`)
        else:
          ydb_tp(`fn`, cast[pointer](addr `tpParam`))


template Transaction*(body: untyped): int =
  transactionImpl("", body)

template Transaction*(param: untyped, body: untyped): int =
  transactionImpl(param, body)


# --------------------------------
# Locks
# --------------------------------

template withlock*(body: untyped): untyped =
    ## Create a database Lock named ^LOCKS(int.high) while executing the body
    Lock: {+^LOCKS(int.high)}
    try:
        body
    except:
        echo "Exception while locking body: ", getCurrentExceptionMsg()
    Lock: {-^LOCKS(int.high)}

template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database Lock named ^LOCKS(lockid) while executing the body
    Lock: {+^LOCKS(lockid)}
    try:
        body
    except:
        echo "Exception while locking body: ", getCurrentExceptionMsg()
    Lock: {-^LOCKS(lockid)}

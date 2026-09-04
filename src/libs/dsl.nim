import macros
import std/strutils
import std/strformat
import std/[json]
import libs/ydbtypes
import libs/ydbimpl

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
    REVERSE = "REVERSE"
    VAL = "VAL"

const
  MAX_RESTARTS = 4


func trim(str: string): string {.inline.} =
    # remove surrounding whitespace and a pair of double quotes:
    #   ^GBL("os")  ->  os
    var first = 0
    var last = str.len - 1
    while first <= last and str[first] in Whitespace:
        inc first
    while last >= first and str[last] in Whitespace:
        dec last
    if first <= last and str[first] == '"' and str[last] == '"':
        inc first
        dec last
    if first > last:
        return ""
    if first == 0 and last == str.len - 1:
        str                     # unchanged -> return the original string, no copy
    else:
        str[first .. last]


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
      subs.add(trim(idx))
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


proc ydbVar*(prefix, name, value, typdesc: string, subscripts: Subscripts): YdbVar =
  # Runtime constructor emitted by the macros to build a YdbVar directly.
  result = YdbVar(prefix: prefix, name: name, value: value, typdesc: typdesc, subscripts: subscripts)


proc makeYdbVar(prefix, name, value, typdesc: NimNode, subscripts: seq[NimNode]): NimNode =
  # ydbVar(prefix, name, value, typdesc, @[...])
  var arr = newTree(nnkBracket)
  for s in subscripts:
    arr.add(s)
  result = newCall(ident"ydbVar",
    (if prefix.isNil: newLit("") else: prefix),
    (if name.isNil: newLit("") else: name),
    (if value.isNil: newLit("") else: value),
    (if typdesc.isNil: newLit("") else: typdesc),
    newTree(nnkPrefix, ident"@", arr))


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
          subscripts.add(newLit(trim(idx)))
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
      # Indirection: the name (and possibly embedded subscripts) is resolved at
      # runtime by `resolveVar`.
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


proc buildYdbVars(args: seq[NimNode]): NimNode =
  ## Compile-time equivalent of the former `seqToYdbVars`; returns `@[YdbVar(...), ...]`.
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
        let i = parseInt(arg)
        if i <= YDB_LOCK_TIMEOUT:
          result = i
      except:
        discard
    if result == 0: result = YDB_LOCK_TIMEOUT

# ----------------------------------------
# macros call's one of this for each macro
# ----------------------------------------

#================
# Data
#================
proc datax*(ydbvar: YdbVar): int =
    let v = resolveVar(ydbvar)
    ydb_data(v.name, v.subscripts)

macro Data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    newCall(ident"datax", buildYdbVar(args))

#================
# Get
#================
proc getx*(ydbvar: YdbVar): string =
    let v = resolveVar(ydbvar)
    result = ydb_get(v.name, v.subscripts)
    if result.len == 0 and ydbvar.value.len > 0:
        return ydbvar.value # return 'default value' if nothing found


proc parseSeq[T](ydbvar: YdbVar): seq[T] =
    var mustTrim: bool
    # Creates a seq[T] from a string in the forms
    #    A,B,C,D,E...  # craeted with Set: ^x(1) = join(seqData, ",")
    # or @["A", "B", "C", "D", "E",...]  # created with Set: ^x(1) = seqData
    var s = getx(ydbvar)

    if s.startsWith(INDIRECTION_KEYS):
        # @["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]  # Saved as Set: ^x(1) = someSeqStr, better Set: ^x(1) = join(someSeqStr,",")
        s = s[2..^2] # remove @[ ]
        mustTrim = true
        # "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"

    let str = s.split(',')
    result = newSeq[T](str.len)

    try:
        if mustTrim:
            for i in 0..<str.len:
                when T is string:
                    result[i] = trim(str[i])
                when T is int:
                    result[i] = parseInt(trim(str[i]))
                when T is float:
                    result[i] = parseFloat(trim(str[i]))
                when T is bool:
                    let sup = toUpper(trim(str[i]))
                    result[i] = if sup == "1" or sup == "T" or sup == "TRUE": true else: false
        else:
            for i in 0..<str.len:
                when T is string:
                    result[i] = str[i]
                when T is int:
                    result[i] = parseInt(str[i])
                when T is float:
                    result[i] = parseFloat(str[i])
                when T is bool:
                    let sup = toUpper(str[i])
                    result[i] = if sup == "1" or sup == "T" or sup == "TRUE": true else: false
    except:
        echo "ERROR: Could not parse seq to numbers: ", str


proc getxseqStr*(ydbvar: YdbVar): seq[string] =
    # Postfix: .seqStr
    parseSeq[string](ydbvar)

proc getxseqInt*(ydbvar: YdbVar): seq[int] =
    # Postfix: .seqInt
    parseSeq[int](ydbvar)

proc getxseqFloat*(ydbvar: YdbVar): seq[float] =
    # Postfix: .seqFloat
    parseSeq[float](ydbvar)

proc getxseqBool*(ydbvar: YdbVar): seq[bool] =
    # Postfix: .seqBool
    parseSeq[bool](ydbvar)


macro Get*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[DEFAULT])
    # check for type conversion
    var typename = "getx"
    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
        typename.add(args[^1][1].strVal)
        args = args[0..^3] # remove TD,int
    newCall(ident(typename), buildYdbVar(args))


# -------------------------------------
# Int / Uint / Float / Bool conversions
# -------------------------------------
proc parseBool(value: string): bool =
    var b = toUpper(value)
    if b == "TRUE" or b == "T" or b == "1":
        result = true
        
template defineGetX(typeName, parseFunc: untyped) =
  proc `getx typeName`*(ydbvar: YdbVar): typeName =
    let s = getx(ydbvar)
    if s.len == 0: return cast[typeName](0)
    let tmpvar = parseFunc(s)
    if tmpvar < low(typeName) or tmpvar > high(typeName):
      raise newException(RangeDefect, "Illegal number. Must be in range " & $low(typeName) & ".." & $high(typeName))
    else:
      result = cast[typeName](tmpvar)

defineGetX(int, parseInt)
defineGetX(int8, parseInt)
defineGetX(int16, parseInt)
defineGetX(int32, parseInt)
defineGetX(int64, parseInt)
defineGetX(uint, parseUInt)
defineGetX(uint8, parseUInt)
defineGetX(uint16, parseUInt)
defineGetX(uint32, parseUInt)
defineGetX(uint64, parseUInt)
defineGetX(float, parseFloat)
#defineGetX(float32, parseFloat) #TODO: cast gives strange results
defineGetX(float64, parseFloat)
defineGetX(bool, parseBool)


#================
# Killnode
#================
proc killnodex*(ydbvars: seq[YdbVar]) =
    for ydbvar in ydbvars:
        let v = resolveVarPrefix(ydbvar)
        ydb_delete_node(v.name, v.subscripts)

macro Killnode*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"killnodex", buildYdbVars(args))


#================
# Kill
#================
proc killx*(ydbvars: seq[YdbVar]) =
    for ydbvar in ydbvars:
        let v = resolveVarPrefix(ydbvar)
        ydb_delete_tree(v.name, v.subscripts)

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
        names.add(resolveVarPrefix(ydbvar).name)
    ydb_delete_excl(names)

macro Delexcl*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"delexclx", buildYdbVars(args))


#================
# Increment
#================
proc incrementx*(ydbvar: YdbVar): int =
    let v = resolveVar(ydbvar)
    if ydbvar.value.len == 0:
        ydb_increment(v.name, v.subscripts, 1)
    else:
        ydb_increment(v.name, v.subscripts, parseInt(ydbvar.value))

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
        let v = resolveVarPrefix(ydbvar)
        ydb_lock_decr(v.name, v.subscripts)

proc lockincrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Increment Lock count for variable(s)
    for ydbvar in ydbvars:
        let v = resolveVarPrefix(ydbvar)
        ydb_lock_incr(timeout, v.name, v.subscripts)


#================
# Lock
#================
proc lockx*(initialTimeout: int, ydbvars: seq[YdbVar]) =
    var timeout = initialTimeout
    var vars: seq[Subscripts]
    var incvars: seq[YdbVar]
    var decvars: seq[YdbVar]
    # create seq of subscripts for each var
    # @[@["^XXX", ""], @["^GBL", "2"], @["^GBL", "2", "3"], @["^GBL", "2", "3", "abc"]]
    for ydbvar in ydbvars:
        let v = resolveVarPrefix(ydbvar)
        # timeout from Lock: ^GBL, timeout=12345
        if v.name == DATAVAL: continue
        if v.name == TIMEOUT and v.value != "":
            timeout = getTimeout(v.value)
            continue
        if v.prefix.len > 0:
            if v.prefix[0] == '+':
                incvars.add(v)
                continue
            elif v.prefix[0] == '-':
                decvars.add(v)
                continue

        var subs: seq[string]
        subs.add(v.name)
        for sub in v.subscripts:
            subs.add(sub)
        if subs.len == 1: subs.add("") # Lock only on variable add empty subscripts
        vars.add(subs)

    # set locks, or release all
    if vars.len > 0 or (vars.len == 0 and incvars.len == 0 and decvars.len == 0):
        ydb_lock(timeout, vars)

    # Increment / Decrement locks?
    if incvars.len > 0:
        lockincrx(timeout, incvars)
    if decvars.len > 0:
        lockdecrx(timeout, decvars)

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
        let v = resolveVarPrefix(ydbvar)
        ydb_set(v.name, v.subscripts, v.value)

macro Set*(body: untyped): untyped =
    # Set MUST be used in the form 'Set: <varname> = <value>'
    # The Nim compiler will not allow 'Set <varname> = <value>'
    var args: seq[NimNode]
    processStmtList(body)
    newCall(ident"setx", buildYdbVars(args))

# --------------------
# Query Iterators
# --------------------
template walkNodes(nextProc: untyped, ydbvar: YdbVar, body: untyped) =
  let v = resolveVar(ydbvar)
  let name {.inject.} = v.name
  var rc {.inject.}: int
  var subs {.inject.}: seq[string]
  (rc, subs) = nextProc(name, v.subscripts)
  while rc == YDB_OK:
    body
    (rc, subs) = nextProc(name, subs)

# returns ^global(key,..)
iterator QueryItrx*(reverse: bool, ydbvar: YdbVar): string =
  let procedure = if reverse: ydb_node_previous else: ydb_node_next
  walkNodes(procedure, ydbvar):
    yield keysToString(name, subs)

# returns @["1"], @["2"], ...
iterator QueryItrxKEYS*(reverse: bool, ydbvar: YdbVar): seq[string] =
  let procedure = if reverse: ydb_node_previous else: ydb_node_next
  walkNodes(procedure, ydbvar):
    yield subs

iterator QueryItrxKV*(reverse: bool, ydbvar: YdbVar): (string, string) =
  let procedure = if reverse: ydb_node_previous else: ydb_node_next
  walkNodes(procedure, ydbvar):
    yield (keysToString(name, subs), ydb_get(name, subs))

iterator QueryItrxVAL*(reverse: bool, ydbvar: YdbVar): string =
  let procedure = if reverse: ydb_node_previous else: ydb_node_next
  walkNodes(procedure, ydbvar):
    yield ydb_get(name, subs)

iterator QueryItrxCOUNT*(reverse: bool, ydbvar: YdbVar): int =
  let procedure = if reverse: ydb_node_previous else: ydb_node_next
  var cnt = 0
  walkNodes(procedure, ydbvar):
    inc cnt
  yield cnt


# --------------------
# Order Iterators
# --------------------
template walkOrderNodes(nextProc: untyped, ydbvar: YdbVar, body: untyped) =
  let v = resolveVar(ydbvar)
  let name {.inject.} = v.name
  var subs {.inject.} = v.subscripts
  var key {.inject.} = nextProc(name, v.subscripts)
  while key.len > 0:
    if subs.len > 0: subs[^1] = key
    else: subs.add(key)
    body
    key = nextProc(name, subs)

# returns ^global(key,..)
iterator OrderItrx*(reverse: bool, ydbvar: YdbVar): string =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  walkOrderNodes(procedure, ydbvar):
    yield key

iterator OrderItrxKEYS*(reverse: bool, ydbvar: YdbVar): seq[string] =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  walkOrderNodes(procedure, ydbvar):
    yield subs

iterator OrderItrxVAL*(reverse: bool, ydbvar: YdbVar): string =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  walkOrderNodes(procedure, ydbvar):
    yield ydb_get(name, subs)

iterator OrderItrxKV*(reverse: bool, ydbvar: YdbVar): (string, string) =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  walkOrderNodes(procedure, ydbvar):
    yield (key, ydb_get(name, subs))

iterator OrderItrxKEY*(reverse: bool, ydbvar: YdbVar): string =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  walkOrderNodes(procedure, ydbvar):
    yield keysToString(name, subs)

iterator OrderItrxCOUNT*(reverse: bool, ydbvar: YdbVar): int =
  let procedure = if reverse: ydb_subscript_previous else: ydb_subscript_next
  var cnt = 0
  walkOrderNodes(procedure, ydbvar):
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

template walkQ[T](qt: static QueryType, ydbvar: YdbVar, nodeProc: untyped): T =
    let v = resolveVar(ydbvar)
    let name = v.name
    let base = v.subscripts
    when qt == qtnext:
        let (rc, subs) = nodeProc(name, base)
        if rc == YDB_OK: keysToString(name, subs)
        else: EMPTY_STRING
    elif qt  == qtCount:
        var cnt = 0
        var (rc, subs) = nodeProc(name, base)
        while rc == YDB_OK:
            inc cnt
            (rc, subs) = nodeProc(name, subs)
        cnt
    elif qt == qtKeys:
        let (rc, subs) = nodeProc(name, base)
        if rc == YDB_OK: subs
        else: EMPTY_KEYS
    elif qt == qtKv:
        let (rc, subs) = nodeProc(name, base)
        if rc == YDB_OK:
            let value = ydb_get(name, subs)
            (keysToString(name, subs), value)
        else:
            (EMPTY_STRING, EMPTY_STRING)
    elif qt == qtValue:
        let (rc, subs) = nodeProc(name, base)
        if rc == YDB_OK: ydb_get(name, subs)
        else: EMPTY_STRING
    else:
        default(T)


# ----------------------------------
# Order template and procs
# ---------------------------------- 
template walkO[T](qt: static QueryType, ydbvar: YdbVar, nodeProc: untyped): T =
    let v = resolveVar(ydbvar)
    let name = v.name
    var subs = v.subscripts
    when qt == qtnext:
        nodeProc(name, subs)
    elif qt == qtCount:
        var key = nodeProc(name, subs)
        while key.len > 0:
          inc result
          if subs.len > 0: subs[^1] = key
          else: subs.add(key)
          key = ydb_subscript_next(name, subs)
        result
    elif qt == qtKeys:
        let key = nodeProc(name, subs)
        if key.len == 0: return @[]
        if subs.len > 0:
            subs[^1] = key
        else:
            subs.add(key)
        subs
    elif qt == qtKey:
        let key = nodeProc(name, subs)
        if key.len > 0:
            if subs.len > 0:
              subs[^1] = key
            else:
              subs.add(key)
            keysToString(name, subs)
        else:
            EMPTY_STRING
    elif qt == qtKv:
        let key = nodeProc(name, subs)
        if subs.len > 0:
            subs[^1] = key
        else:
            subs.add(key)
        let value = ydb_get(name, subs)
        (key, value)
    else:
        default(T)

proc getApiName(basename: string, args: var seq[NimNode]): (string, bool) =
  var reverse: bool
  var apiName = basename & "x"
  while args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
    let arg = args[^1][1].strVal.toUpper()
    case  arg
    of REVERSE: reverse = true
    of KEY, KEYS, KV, COUNT, VAL: apiName.add(arg)
    else: raise newException(YdbError, fmt"Unsupported postfix '{arg}'")
    args = args[0..^3]
   
  return (apiName, reverse)

#================
# Query:
#================
proc Queryx*(isReverse: bool, ydbvar: YdbVar): string =
    let procedure = if isReverse: ydb_node_previous else: ydb_node_next
    walkQ[string](qtNext, ydbvar, procedure)

proc QueryxKEYS*(isReverse: bool, ydbvar: YdbVar): seq[string] =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[seq[string]](qtKeys, ydbvar, procedure)

proc QueryxKV*(isReverse: bool, ydbvar: YdbVar): (string, string) =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[(string, string)](qtKv, ydbvar, procedure)

proc QueryxVAL*(isReverse: bool, ydbvar: YdbVar): string =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[string](qtValue, ydbvar, procedure)

proc QueryxCOUNT*(isReverse: bool, ydbvar: YdbVar): int =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[int](qtCount, ydbvar, procedure)

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
proc Orderx*(isReverse: bool, ydbvar: YdbVar): string =
    let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
    walkO[string](qtNext, ydbvar, procedure)

proc OrderxKEY*(isReverse: bool, ydbvar: YdbVar): string =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[string](qtKey, ydbvar, procedure)

proc OrderxKEYS*(isReverse: bool, ydbvar: YdbVar): seq[string] =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[seq[string]](qtKeys, ydbvar, procedure)

proc OrderxKV*(isReverse: bool, ydbvar: YdbVar): (string, string) =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[(string, string)](qtKv, ydbvar, procedure)

proc OrderxVAL*(isReverse: bool, ydbvar: YdbVar): string =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[string](qtValue, ydbvar, procedure)

proc OrderxCOUNT*(isReverse: bool, ydbvar: YdbVar): int =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[int](qtCount, ydbvar, procedure)

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
    if node.kind == JString:
        ydb_set("CTX", subs, node.getStr())
    elif node.kind == JInt:
        ydb_set("CTX", subs, $node.getInt())
    elif node.kind == JFloat:
        ydb_set("CTX", subs, $node.getFloat())
    elif node.kind == JBool:
        ydb_set("CTX", subs, $node.getBool())
    else:
        echo "Unknown datatype ", node.kind

proc callmx*(args: varargs[string]): string =
    ydb_delete_node("CTX", @[])

    if args.len == 2 and args[1][0] == '{' and args[1][^1] == '}': # Try to parse Json
        # JSON passed
        let data = parseJson(args[1])
        var indent : seq[string]
        var level = 0
        setupCTX(data, level, indent)
        # call the callin interface, The RESULT local variable can be readout with Get LOCAL(,,)
    elif args.len == 2:
        # Single argument
        ydb_set("CTX", @[], args[1])
    else:
        # Multiple arguments
        for i in 1..<args.len:
            ydb_set("CTX", @[$i], args[i])

    ydb_ci(args[0])
    #result = Get RESULT
    result = ydb_get("RESULT", @[])


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
                let restarted = parseInt(ydb_get("$TRESTART", @[])) # How many times the proc was called from yottadb
                if restarted >= MAX_RESTARTS: 
                    echo "Too many transaction restarts, Rolling back.", getCurrentExceptionMsg()
                    return YDB_TP_ROLLBACK
            except:
                echo "Exception while getting $TRESTART", getCurrentExceptionMsg()
                TPTOKEN = 0
                return YDB_TP_ROLLBACK
            
            return YDB_TP_RESTART

      ydb_tp_mt(`fn`, `param`)
  else:
    result = quote do:
      proc `fn`(param {.inject.}: pointer): cint {.cdecl, gcsafe, raises: [].} =
        TPTOKEN = 0
        try:
            `body`
        except:
            if getCurrentException() of TpRestart: 
                discard
            else: 
                echo "Exception in transaction:", getCurrentExceptionMsg()
            
            try:
                let restarted = parseInt(ydb_get("$TRESTART", @[])) # How many times the proc was called from yottadb
                if restarted >= MAX_RESTARTS: 
                    echo "Too many transaction restarts, Rolling back.", getCurrentExceptionMsg()
                    return YDB_TP_ROLLBACK
            except:
                echo "Exception while getting $TRESTART", getCurrentExceptionMsg()
                return YDB_TP_ROLLBACK
            return YDB_TP_RESTART

      ydb_tp(`fn`, `param`)


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
    body
    Lock: {-^LOCKS(int.high)}

template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database Lock named ^LOCKS(lockid) while executing the body
    Lock: {+^LOCKS(lockid)}
    body
    Lock: {-^LOCKS(lockid)}

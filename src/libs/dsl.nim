import macros
import std/strutils
import std/strformat
import std/sets
import libs/ydbtypes
import libs/ydbapi
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
    COUNT = "count"
    KEY = "key"
    KEYS = "keys"
    KV = "kv"
    REVERSE = "reverse"
    VALUE = "val"

const
  MAX_RESTARTS = 4


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
    of nnkIdent, nnkInfix:
        args.add(newCall(ident"$", node))
    of nnkStrLit, nnkPrefix:  # "abc" / let id=4711; Get ^gbl($id)
        args.add(node)
    of nnkIntLit, nnkFloatLit, nnkCharLit:
        args.add(newCall(ident"$", node))
    else:
        raise newException(Exception, "transformCallNode: node.kind:" & $node.kind & " not supported! node=" & repr(node))


func transform(node: NimNode, args: var seq[NimNode], attributes: seq[string] = @[]) =
    case node.kind
    of nnkStmtList, nnkTupleConstr:
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
        args.add(newCall(ident"$", node[1])) # add value
        args.add(newLit(VALUEMARK))
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
    for i in 0..<body.len:
        transform(body[i], args)
        if i < body.len-1: args.add(newLit(FIELDMARK))


func getApiName(basename: string, args: var seq[NimNode]): string =
  var keys, key, kv, count, reverse, value: bool
  while args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
    case  args[^1][1].strVal
    of KEY:
      key = true
      args = args[0..^3]
    of KEYS:
      keys = true
      args = args[0..^3]
    of KV:
      kv = true
      args = args[0..^3]
    of REVERSE:
      reverse = true
      args = args[0..^3]
    of COUNT:
      count = true
      args = args[0..^3]
    of VALUE:
      value = true
      args = args[0..^3]
    else:
      raise newException(YdbError, "Unsupported postfix '" & args[^1][1].strVal & "'")

  if (kv and keys) or (kv and value) or (keys and value):
      raise newException(YdbError, "Either 'keys' or 'kv' or 'value'")
  if count and (kv or keys or value):
      raise newException(YdbError, "No 'kv', 'keys' or 'value' when 'count'")

  if key:     result = basename & "xKey"
  elif keys:  result = basename & "xKeys"
  elif kv:    result = basename & "xKv"
  elif count: result = basename & "xCount"
  elif value: result = basename & "xValue"
  else:       result = basename & "x"
  if reverse: result.add("Reverse")

# ------------------
# Macros
# ------------------
macro Get*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[DEFAULT])
    # check for type conversion
    var typename = "getx"
    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
        typename.add(args[^1][1].strVal)
        args = args[0..^3] # remove TD,int
    return newCall(ident(typename), args)

macro Data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    newCall(ident"datax", args)    

macro Killnode*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"killnodex", args)

macro Kill*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"killx", args)

macro Delexcl*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"delexclx", args)

macro Increment*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[BY])
    return newCall(ident"incrementx", args)

macro Lock*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"lockx", args)

macro Query*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let apiName = getApiName("Query", args)
    return newCall(ident(apiName), args)
        
macro QueryItr*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let apiName = getApiName("QueryItr", args)
    return newCall(ident(apiName), args)

macro OrderItr*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let apiName = getApiName("OrderItr", args)
    return newCall(ident(apiName), args)

macro Order*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let apiName = getApiName("Order", args)
    return newCall(ident(apiName), args)

macro Set*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"setx", args)

# ----------------------------
# proc related helper proc's
# ----------------------------

func seqToYdbVars(args: varargs[string]): seq[YdbVar] =
  var
    ydbvar: YdbVar
    subs: Subscripts

  var lastArg: string
  for arg in args:
    case arg 
    of FIELDMARK:
      # End of one YdbVar group
      if ydbvar.name.len > 0:
        if ydbvar.subscripts.len == 0:
          ydbvar.subscripts = subs
        result.add(ydbvar)
      # Reset for next
      ydbvar = YdbVar()
      subs = @[]
      continue
    of VALUEMARK:
      # End of value-based YdbVar
      ydbvar.value = lastArg
      ydbvar.subscripts.add(subs[0..^2])
      result.add(ydbvar)
      ydbvar = YdbVar()
      subs = @[]
      continue

    # Set the prefix field (1..2 bytes)
    if ydbvar.name.len == 0 and ydbvar.prefix.len == 0: # single @,$,.
      if arg.len == 1 and arg[0] in PREFIX_CHARS:
        ydbvar.prefix = arg
        continue
      elif arg.len == 2 and arg[0] in PREFIX_CHARS and arg[1] in PREFIX_CHARS: # +@
        ydbvar.prefix = arg
        continue

    # Name assignment
    if ydbvar.name.len == 0:
      if ydbvar.prefix == INDIRECTION:
        let openPar = arg.find('(')
        if openPar != -1:
          let closePar = arg.find(')', openPar)
          let subsStr = arg[openPar + 1 ..< closePar]
          ydbvar.subscripts.add(stringToSeq(subsStr))
          ydbvar.name = arg[0..<openPar]
        else:
          ydbvar.name = arg
      else:
        if ydbvar.prefix.len > 0 and ydbvar.prefix[0] in {'+', '-'}:
          ydbvar.name = ydbvar.prefix[1..^1] & arg
        else:
          ydbvar.name = ydbvar.prefix & arg
    else:
      if arg.startsWith(INDIRECTION_KEYS):
          subs.add(stringToSeq(arg))
      else:
        subs.add(arg)
      lastArg = arg

  # Final flush if any
  if ydbvar.name.len > 0:
    if ydbvar.subscripts.len == 0:
      ydbvar.subscripts = subs
    result.add(ydbvar)

func resolveSubscripts(arg: string): (string, seq[string]) =
  var subs: seq[string]
  var name: string
  let openPar = arg.find('(') # handle subscripts
  if openPar != -1:
      let closePar = arg.find(')', openPar)
      let index = arg[openPar + 1 ..< closePar]
      for idx in split(index, ','):
          var s = idx.strip()
          if s.len > 0:
              if s[0] == '\"' and s[^1] == '\"': # remove \" (let gbl = "^GBL(\"os\")"
                  s = s[1..^2]
          subs.add(s)
      name = arg[0..<openPar]
  else:
      name = arg
  return (name, subs)


func seqToYdbVar(args: varargs[string]): YdbVar =
    if args.len == 1: # "^gbl", "var", ^gbl(2,"x",.) given as string
      let (name, subs) = resolveSubscripts(args[0]) 
      if subs.len > 0: # subscript given?
        result.subscripts = subs
        result.name = name
      elif args[0][0] in PREFIX_CHARS:
        result.prefix = $(args[0][0])
        result.name = args[0]
      else:
        result.name = args[0]
    elif args[0].len > 0 and args[0][0] in PREFIX_CHARS:
        result.prefix = args[0]
        let arg = args[1] # subscripted? (,,)
        # Handle indirection
        if result.prefix == INDIRECTION:
            let openPar = arg.find('(') # handle subscripts
            if openPar != -1:
                let closePar = arg.find(')', openPar)
                let index = arg[openPar + 1 ..< closePar]
                for idx in split(index, ','):
                    var s = idx.strip()
                    if s.len > 0:
                        if s[0] == '\"' and s[^1] == '\"': # remove \" (let gbl = "^GBL(\"os\")"
                            s = s[1..^2]
                    result.subscripts.add(s)
                    result.subscripts.add(args[2..^1]) # add the restly keyparts if any (Get @gbl(1,2,3))
                result.name = arg[0..<openPar]
            else:
                result.name = arg
        else:
            result.name = result.prefix & arg

        # handle typedesc "int16", ...
        if args.len > 2 and args[^2] == TYPEDESC:
            result.typdesc = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[2..^3]
        # handle attribute values (by=20, timeout=1111,)
        elif args.len > 2 and args[^2] == DATAVAL:
            result.value = args[^1]
            if result.subscripts.len == 0:
                result.subscripts = args[2..^3]
            else:
                result.subscripts = result.subscripts[0..^3]
        else:
            if result.subscripts.len == 0: result.subscripts = args[2..^1]
    elif args.len >= 2 and args[0] == INDIRECTION:
        if args[1].len > 0 and args[1][^1] == ')':            
            var subs: Subscripts
            let open = args[1].find("(")
            if open > 0:
                subs.add(args[0])
                subs.add(args[1][0..open-1]) # the varname 
                subs.add(args[1][open+1..^2]) # the idx part(s)
                subs.add(args[2..^1]) # the restly key parts
    else: # no prefix
        result.name = args[0] # local var
        if args.len > 2 and args[^2] == DATAVAL:
            result.value = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[1..^3]
        else:
            result.subscripts = args[1..^1]

    if result.subscripts.len > 0 and result.subscripts[0].len > 1 and result.subscripts[0][0..1] == INDIRECTION_KEYS:
        result.subscripts = stringToSeq(result.subscripts)

# "^global(1,2,..)" -> ydbvar
func stringToYdbVar(name: string): YdbVar =
  let openPar = name.find('(') # handle subscripts
  if openPar != -1:
      let closePar = name.find(')', openPar)
      let index = name[openPar + 1 ..< closePar]
      for idx in split(index, ','):
          var s = idx.strip()
          if s.len > 0:
              if s[0] == '\"' and s[^1] == '\"': # remove \" (let gbl = "^GBL(\"os\")"
                  s = s[1..^2]
          result.subscripts.add(s)
      result.name = name[0..<openPar]
  else: # no index (1,..)
    result.name = name

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

proc datax*(args: varargs[string]): int =
    let ydbvar = seqToYdbVar(args)
    ydb_data(ydbvar.name, ydbvar.subscripts)

proc killnodex*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_node(ydbvar.name, ydbvar.subscripts)

proc delexclx*(args: varargs[string]) =
    var names: seq[string]
    for ydbvar in seqToYdbVars(args):
        names.add(ydbvar.name)
    ydb_delete_excl(names)

proc killx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_tree(ydbvar.name, ydbvar.subscripts)

proc getx*(args: varargs[string]): string =
  var ydbvar: YdbVar
  if args.len == 1:  # "^gbl(1,2,..), Localname, "
    ydbvar = stringToYdbVar(args[0])
  else:
    ydbvar = seqToYdbVar(args)
  result = ydb_get(ydbvar.name, ydbvar.subscripts)
  if result.len == 0 and ydbvar.value.len > 0:
      return ydbvar.value

proc getxbinary*(args: varargs[string]): string =
    let ydbvar = seqToYdbVar(args)
    ydb_getbinary(ydbvar.name, ydbvar.subscripts)

# -------------------------------
# Int / Uint / Float conversions
# -------------------------------
template defineGetX(typeName, parseFunc: untyped) =
  proc `getx typeName`*(args: varargs[string]): typeName =
    let s = getx(args)
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

proc getxOrderedSet*(args: varargs[string]): OrderedSet[int] =
    let str = getx(args)
    result = initOrderedSet[int]()
    if str[0] == '{' and str[^1] == '}':
        for s in split(str[1 .. ^2], ","):
            result.incl(parseInt(strip(s)))
    else:
        for s in split(str, ","):
            result.incl(parseInt(strip(s)))

proc incrementx*(args: varargs[string]): int =
    let ydbvar = seqToYdbVar(args)
    if ydbvar.value.len == 0:
        ydb_increment(ydbvar.name, ydbvar.subscripts, 1)
    else:
        ydb_increment(ydbvar.name, ydbvar.subscripts, parseInt(ydbvar.value))

proc lockdecrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Decrement Lock count for variable
    for ydbvar in ydbvars:
        ydb_lock_decr(ydbvar.name, ydbvar.subscripts)

proc lockincrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Increment Lock count for variable(s)
    for ydbvar in ydbvars:
        ydb_lock_incr(timeout, ydbvar.name, ydbvar.subscripts)

proc lockx*(args: varargs[string]) =
    # timeout from Lock: { ^GBL, timeout=12345 }
    var timeout = YDB_LOCK_TIMEOUT
    if args.len > 2 and args[^2] == DATAVAL:
        timeout = getTimeout(args[^1])

    let ydbvars = seqToYdbVars(args)
    var vars: seq[Subscripts]
    var incvars: seq[YdbVar]
    var decvars: seq[YdbVar]
    # create seq of subscripts for each var
    # @[@["^XXX", ""], @["^GBL", "2"], @["^GBL", "2", "3"], @["^GBL", "2", "3", "abc"]]
    for ydbvar in ydbvars:
        # timeout from Lock: ^GBL, timeout=12345
        if ydbvar.name == DATAVAL: continue
        if ydbvar.name == TIMEOUT and ydbvar.value != "":
            timeout = getTimeout(ydbvar.value)
            continue
        if ydbvar.prefix.len > 0:
            if ydbvar.prefix[0] == '+':
                incvars.add(ydbvar)
                continue
            elif ydbvar.prefix[0] == '-':
                decvars.add(ydbvar)
                continue

        var subs: seq[string]
        subs.add(ydbvar.name)
        for sub in ydbvar.subscripts:
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


proc setx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value)


# --------------------
# Query Iterators
# --------------------
template walkNodes(nextProc: untyped, body: untyped) =
  let ydbvar {.inject.} = seqToYdbVar(args)
  var rc {.inject.}: int
  var subs {.inject.}: seq[string]
  (rc, subs) = nextProc(ydbvar.name, ydbvar.subscripts)
  while rc == YDB_OK:
    body
    (rc, subs) = nextProc(ydbvar.name, subs)

# returns ^global(key,..)
iterator QueryItrx*(args: varargs[string]): string =
  walkNodes(ydb_node_next):
    yield keysToString(ydbvar.name, subs)

iterator QueryItrxReverse*(args: varargs[string]): string =
  walkNodes(ydb_node_previous):
    yield keysToString(ydbvar.name, subs)

# returns @["1"], @["2"], ...
iterator QueryItrxKeys*(args: varargs[string]): seq[string] =
  walkNodes(ydb_node_next):
    yield subs

iterator QueryItrxKeysReverse*(args: varargs[string]): seq[string] =
  walkNodes(ydb_node_previous):
    yield subs

iterator QueryItrxKv*(args: varargs[string]): (string, string) =
  walkNodes(ydb_node_next):
    yield (keysToString(ydbvar.name, subs), ydb_get(ydbvar.name, subs))

iterator QueryItrxKvReverse*(args: varargs[string]): (string, string) =
  walkNodes(ydb_node_previous):
    yield (keysToString(ydbvar.name, subs), ydb_get(ydbvar.name, subs))

iterator QueryItrxValue*(args: varargs[string]): string =
  walkNodes(ydb_node_next):
    yield ydb_get(ydbvar.name, subs)

iterator QueryItrxValueReverse*(args: varargs[string]): string =
  walkNodes(ydb_node_previous):
    yield ydb_get(ydbvar.name, subs)

iterator QueryItrxCount*(args: varargs[string]): int =
  var cnt = 0
  walkNodes(ydb_node_next):
    inc cnt
  yield cnt

iterator QueryItrxCountReverse*(args: varargs[string]): int =
  var cnt = 0
  walkNodes(ydb_node_previous):
    inc cnt
  yield cnt


# --------------------
# Order Iterators
# --------------------
template walkOrderNodes(nextProc: untyped, body: untyped) =
  let ydbvar {.inject.} = seqToYdbVar(args)
  var subs {.inject.} = ydbvar.subscripts
  var key {.inject.} = nextProc(ydbvar.name, ydbvar.subscripts)
  while key.len > 0:
    if subs.len > 0: subs[^1] = key
    else: subs.add(key)
    body
    key = nextProc(ydbvar.name, subs)

# returns ^global(key,..)
iterator OrderItrx*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_next):
    yield key

iterator OrderItrxReverse*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield key

iterator OrderItrxKeys*(args: varargs[string]): seq[string] =
  walkOrderNodes(ydb_subscript_next):
    yield subs

iterator OrderItrxKeysReverse*(args: varargs[string]): seq[string] =
  walkOrderNodes(ydb_subscript_previous):
    yield subs

iterator OrderItrxValue*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_next):
    yield ydb_get(ydbvar.name, subs)

iterator OrderItrxValueReverse*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield ydb_get(ydbvar.name, subs)

iterator OrderItrxKv*(args: varargs[string]): (string, string) =
  walkOrderNodes(ydb_subscript_next):
    yield (key, ydb_get(ydbvar.name, subs))

iterator OrderItrxKvReverse*(args: varargs[string]): (string, string) =
  walkOrderNodes(ydb_subscript_previous):
    yield (key, ydb_get(ydbvar.name, subs))

iterator OrderItrxKey*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_next):
    yield keysToString(ydbvar.name, subs)

iterator OrderItrxKeyReverse*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield keysToString(ydbvar.name, subs)

iterator OrderItrxCount*(args: varargs[string]): int =
  var cnt = 0
  walkOrderNodes(ydb_subscript_next):
    inc cnt
  yield cnt

iterator OrderItrxCountReverse*(args: varargs[string]): int =
  var cnt = 0
  walkOrderNodes(ydb_subscript_previous):
    inc cnt
  yield cnt


# ----------------------------------
# Query template and procs
# ---------------------------------- 
type QueryType = enum
    qtNext,
    qtPrevious,
    qtCount,
    qtCountReverse,
    qtKey,
    qtKeyReverse,
    qtKeys,
    qtKeysReverse
    qtKv,
    qtKvReverse
    qtValue,
    qtValueReverse

template walkQ[T](qt: static QueryType, args: varargs[string], nodeProc: untyped): T =
    let ydbvar = seqToYdbVar(args)
    when qt in {qtnext, qtPrevious}:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts)
        if rc == YDB_OK: keysToString(ydbvar.name, subs)
        else: EMPTY_STRING
    elif qt in {qtCount, qtCountReverse}:
        var cnt = 0
        var (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts)
        while rc == YDB_OK:
            inc cnt
            (rc, subs) = nodeProc(ydbvar.name, subs)
        cnt
    elif qt in {qtKeys, qtKeysReverse}:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts)
        if rc == YDB_OK: subs
        else: EMPTY_KEYS
    elif qt in {qtKv, qtKvReverse}:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts)
        if rc == YDB_OK:
            let value = ydb_get(ydbvar.name, subs)
            (keysToString(ydbvar.name, subs), value)
        else:
            (EMPTY_STRING, EMPTY_STRING)
    elif qt in {qtValue, qtValueReverse}:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts)
        if rc == YDB_OK: ydb_get(ydbvar.name, subs)
        else: EMPTY_STRING
    else:
        default(T)

proc Queryx*(args: varargs[string]): string =
    walkQ[string](qtNext, args, ydb_node_next)

proc QueryxReverse*(args: varargs[string]): string =
    walkQ[string](qtPrevious, args, ydb_node_previous)

proc QueryxCount*(args: varargs[string]): int =
    walkQ[int](qtCount, args, ydb_node_next)

proc QueryxCountReverse*(args: varargs[string]): int =
    walkQ[int](qtCount, args, ydb_node_previous)

proc QueryxKeys*(args: varargs[string]): seq[string] =
    walkQ[seq[string]](qtKeys, args, ydb_node_next)

proc QueryxKeysReverse*(args: varargs[string]): seq[string] =
    walkQ[seq[string]](qtKeysReverse, args, ydb_node_previous)

proc QueryxValue*(args: varargs[string]): string =
    walkQ[string](qtValue, args, ydb_node_next)

proc QueryxValueReverse*(args: varargs[string]): string =
    walkQ[string](qtValueReverse, args, ydb_node_previous)

proc QueryxKv*(args: varargs[string]): (string, string) =
    walkQ[(string, string)](qtKv, args, ydb_node_next)

proc QueryxKvReverse*(args: varargs[string]): (string, string) =
    walkQ[(string, string)](qtKvReverse, args, ydb_node_previous)


# ----------------------------------
# Order template and procs
# ---------------------------------- 
template walkO[T](qt: static QueryType, args: varargs[string], nodeProc: untyped): T =
    var ydbvar = seqToYdbVar(args)
    when qt in {qtnext, qtPrevious}:
        nodeProc(ydbvar.name, ydbvar.subscripts)
    elif qt in {qtCount, qtCountReverse}:
        var subs = ydbvar.subscripts
        var key = nodeProc(ydbvar.name, subs)
        while key.len > 0:
          inc result
          if subs.len > 0: subs[^1] = key
          else: subs.add(key)
          key = ydb_subscript_next(ydbvar.name, subs)
        result
    elif qt in {qtKeys, qtKeysReverse}:
        let key = nodeProc(ydbvar.name, ydbvar.subscripts)
        if key.len == 0: return @[]
        if ydbvar.subscripts.len > 0:
            ydbvar.subscripts[^1] = key
        else:
            ydbvar.subscripts.add(key)
        ydbvar.subscripts
    elif qt in {qtKey, qtKeyReverse}:
        let key = nodeProc(ydbvar.name, ydbvar.subscripts)
        if key.len > 0:
            if ydbvar.subscripts.len > 0:
              ydbvar.subscripts[^1] = key
            else:
              ydbvar.subscripts.add(key)
            keysToString(ydbvar.name, ydbvar.subscripts)
        else:
            EMPTY_STRING
    elif qt in {qtKv, qtKvReverse}:
            let key = nodeProc(ydbvar.name, ydbvar.subscripts)
            if ydbvar.subscripts.len > 0:
                ydbvar.subscripts[^1] = key
            else:
                ydbvar.subscripts.add(key)
            let value = ydb_get(ydbvar.name, ydbvar.subscripts)
            (key, value)
    else:
        default(T)

proc Orderx*(args: varargs[string]): string =
    walkO[string](qtNext, args, ydb_subscript_next)

proc OrderxReverse*(args: varargs[string]): string =
    walkO[string](qtPrevious, args, ydb_subscript_previous)

proc OrderxCount*(args: varargs[string]): int =
    walkO[int](qtCount, args, ydb_subscript_next)

proc OrderxCountReverse*(args: varargs[string]): int =
    walkO[int](qtCount, args, ydb_subscript_previous)

proc OrderxKeys*(args: varargs[string]): seq[string] =
    walkO[seq[string]](qtKeys, args, ydb_subscript_next)

proc OrderxKeysReverse*(args: varargs[string]): seq[string] =
    walkO[seq[string]](qtKeys, args, ydb_subscript_previous)

proc OrderxKey*(args: varargs[string]): string =
    walkO[string](qtKey, args, ydb_subscript_next)

proc OrderxKeyReverse*(args: varargs[string]): string =
    walkO[string](qtKeyReverse, args, ydb_subscript_previous)

proc OrderxKv*(args: varargs[string]): (string, string) =
    walkO[(string,string)](qtKv, args, ydb_subscript_next)

proc OrderxKvReverse*(args: varargs[string]): (string, string) =
    walkO[(string,string)](qtKvReverse, args, ydb_subscript_previous)


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


macro transactionImpl(param: untyped, body: untyped): untyped =
  var isMT:bool
  when compileOption("threads"): isMT = true

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
        try:
            `body`
        except:
            if getCurrentException() of TpRestart: discard
            else: echo "Exception in transaction:", getCurrentExceptionMsg()
            
            try:
                let restarted = parseInt(ydb_get("$TRESTART", tptoken=tptoken)) # How many times the proc was called from yottadb
                if restarted >= MAX_RESTARTS: 
                    echo "Too many transaction restarts, Rolling back.", getCurrentExceptionMsg()
                    return YDB_TP_ROLLBACK
            except:
                echo "Exception while getting $TRESTART", getCurrentExceptionMsg()
                return YDB_TP_ROLLBACK
            return YDB_TP_RESTART

      ydb_tp_mt(`fn`, `param`)
    
  else:

    result = quote do:
      proc `fn`(param {.inject.}: pointer): cint {.cdecl, gcsafe, raises: [].} =
        try:
            `body`
        except:
            if getCurrentException() of TpRestart: discard
            else: echo "Exception in transaction:", getCurrentExceptionMsg()
            
            try:
                let restarted = parseInt(ydb_get("$TRESTART")) # How many times the proc was called from yottadb
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

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
    COUNT = "COUNT"
    KEY = "KEY"
    KEYS = "KEYS"
    KV = "KV"
    REVERSE = "REVERSE"
    VAL = "VAL"

const
  MAX_RESTARTS = 2


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


proc transform(node: NimNode, args: var seq[NimNode], attributes: seq[string] = @[]) =
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
  var reverse: bool
  result = basename & "x"
  while args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
    let arg = args[^1][1].strVal.toUpper()
    case  arg
    of REVERSE: reverse = true
    of KEY, KEYS, KV, COUNT, VAL: result.add(arg)
    else: raise newException(YdbError, fmt"Unsupported postfix '{arg}'")
    args = args[0..^3]
   
  if reverse: result.add(REVERSE)

proc getApiName2(basename: string, args: var seq[NimNode]): (string, bool) =
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


# ------------------
# Macros
# ------------------
# macro Get*(body: untyped): untyped =
#     var args: seq[NimNode]
#     transform(body, args, @[DEFAULT])
#     # check for type conversion
#     var typename = "getx"
#     if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
#         typename.add(args[^1][1].strVal)
#         args = args[0..^3] # remove TD,int
#     return newCall(ident(typename), args)

        
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

#================
# Data
#================
when compileOption("threads"):
    proc datax*(token: uint64, args: varargs[string]): int =
        let ydbvar = seqToYdbVar(args)
        ydb_data(ydbvar.name, ydbvar.subscripts, tptoken=token)

    macro dataxPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        transform(body, args)
        result = newCall(ident("datax"), token)
        for arg in args: result.add arg

proc datax*(args: varargs[string]): int =
    let ydbvar = seqToYdbVar(args)
    ydb_data(ydbvar.name, ydbvar.subscripts)

macro Data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    newCall(ident"datax", args)    

#================
# Get
#================
when compileOption("threads"):
    proc getx*(token: uint64, args: varargs[string]): string =
        var ydbvar: YdbVar
        if args.len == 1:  # "^gbl(1,2,..), Localname, "
            ydbvar = stringToYdbVar(args[0])
        else:
            ydbvar = seqToYdbVar(args)
        result = ydb_get(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if result.len == 0 and ydbvar.value.len > 0:
            return ydbvar.value

    macro getxPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        transform(body, args)
        result = newCall(ident("getx"), token)
        for arg in args: result.add arg

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

macro Get*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[DEFAULT])
    # check for type conversion
    var typename = "getx"
    if args.len > 2 and args[^2].kind == nnkStrLit and args[^2].strVal == TYPEDESC:
        typename.add(args[^1][1].strVal)
        args = args[0..^3] # remove TD,int
    return newCall(ident(typename), args)


#================
# Killnode
#================
when compileOption("threads"):
    proc killnodex*(token: uint64, args: varargs[string]) =
        for ydbvar in seqToYdbVars(args):
            ydb_delete_node(ydbvar.name, ydbvar.subscripts, tptoken=token)

    macro killnodexPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        processStmtList(body) 
        result = newCall(ident("killnodex"), token)
        for arg in args: result.add arg

proc killnodex*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_node(ydbvar.name, ydbvar.subscripts)

macro Killnode*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"killnodex", args)


#================
# Kill
#================
when compileOption("threads"):
    proc killx*(token: uint64, args: varargs[string]) =
        for ydbvar in seqToYdbVars(args):
            ydb_delete_tree(ydbvar.name, ydbvar.subscripts, tptoken=token)

    macro killxPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        processStmtList(body) 
        result = newCall(ident("killx"), token)
        for arg in args: result.add arg

proc killx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_tree(ydbvar.name, ydbvar.subscripts)

macro Kill*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"killx", args)


#================
# Delexcl
#================
proc delexclx*(args: varargs[string]) =
    var names: seq[string]
    for ydbvar in seqToYdbVars(args):
        names.add(ydbvar.name)
    ydb_delete_excl(names)

macro Delexcl*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"delexclx", args)


# #================
# # Get
# #================
# proc getx*(args: varargs[string]): string =
#   var ydbvar: YdbVar
#   if args.len == 1:  # "^gbl(1,2,..), Localname, "
#     ydbvar = stringToYdbVar(args[0])
#   else:
#     ydbvar = seqToYdbVar(args)
#   result = ydb_get(ydbvar.name, ydbvar.subscripts)
#   if result.len == 0 and ydbvar.value.len > 0:
#       return ydbvar.value

# proc getxbinary*(args: varargs[string]): string =
#     let ydbvar = seqToYdbVar(args)
#     ydb_getbinary(ydbvar.name, ydbvar.subscripts)

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


#================
# Increment
#================
when compileOption("threads"):
    proc incrementx*(token: uint64, args: varargs[string]): int =
        let ydbvar = seqToYdbVar(args)
        if ydbvar.value.len == 0:
            ydb_increment(ydbvar.name, ydbvar.subscripts, 1, tptoken=token)
        else:
            ydb_increment(ydbvar.name, ydbvar.subscripts, parseInt(ydbvar.value), tptoken=token)

    macro incrementxPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        transform(body, args, @[BY])
        result = newCall(ident("incrementx"), token)
        for arg in args: result.add arg

proc incrementx*(args: varargs[string]): int =
    let ydbvar = seqToYdbVar(args)
    if ydbvar.value.len == 0:
        ydb_increment(ydbvar.name, ydbvar.subscripts, 1)
    else:
        ydb_increment(ydbvar.name, ydbvar.subscripts, parseInt(ydbvar.value))

macro Increment*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args, @[BY])
    return newCall(ident"incrementx", args)


#================
# Lockdecr
#================
proc lockdecrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Decrement Lock count for variable
    for ydbvar in ydbvars:
        ydb_lock_decr(ydbvar.name, ydbvar.subscripts)

proc lockincrx(timeout: int, ydbvars: seq[YdbVar]) =
    # Increment Lock count for variable(s)
    for ydbvar in ydbvars:
        ydb_lock_incr(timeout, ydbvar.name, ydbvar.subscripts)


#================
# Lock
#================
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

macro Lock*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"lockx", args)


#================
# Set:
#================
when compileOption("threads"):
    proc setx*(token: uint64, args: varargs[string]) =
        for ydbvar in seqToYdbVars(args):
            ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value, tptoken=token)

    macro setxPrepare*(token: uint64, body: untyped): untyped =
        var args: seq[NimNode] 
        processStmtList(body) 
        result = newCall(ident("setx"), token)
        for arg in args: result.add arg

proc setx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value)

macro Set*(body: untyped): untyped =
    var args: seq[NimNode]
    processStmtList(body)
    return newCall(ident"setx", args)


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

iterator QueryItrxREVERSE*(args: varargs[string]): string =
  walkNodes(ydb_node_previous):
    yield keysToString(ydbvar.name, subs)

# returns @["1"], @["2"], ...
iterator QueryItrxKEYS*(args: varargs[string]): seq[string] =
  walkNodes(ydb_node_next):
    yield subs

iterator QueryItrxKEYSREVERSE*(args: varargs[string]): seq[string] =
  walkNodes(ydb_node_previous):
    yield subs

iterator QueryItrxKV*(args: varargs[string]): (string, string) =
  walkNodes(ydb_node_next):
    yield (keysToString(ydbvar.name, subs), ydb_get(ydbvar.name, subs))

iterator QueryItrxKVREVERSE*(args: varargs[string]): (string, string) =
  walkNodes(ydb_node_previous):
    yield (keysToString(ydbvar.name, subs), ydb_get(ydbvar.name, subs))

iterator QueryItrxVAL*(args: varargs[string]): string =
  walkNodes(ydb_node_next):
    yield ydb_get(ydbvar.name, subs)

iterator QueryItrxVALREVERSE*(args: varargs[string]): string =
  walkNodes(ydb_node_previous):
    yield ydb_get(ydbvar.name, subs)

iterator QueryItrxCOUNT*(args: varargs[string]): int =
  var cnt = 0
  walkNodes(ydb_node_next):
    inc cnt
  yield cnt

iterator QueryItrxCOUNTREVERSE*(args: varargs[string]): int =
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

iterator OrderItrxREVERSE*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield key

iterator OrderItrxKEYS*(args: varargs[string]): seq[string] =
  walkOrderNodes(ydb_subscript_next):
    yield subs

iterator OrderItrxKEYSREVERSE*(args: varargs[string]): seq[string] =
  walkOrderNodes(ydb_subscript_previous):
    yield subs

iterator OrderItrxVAL*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_next):
    yield ydb_get(ydbvar.name, subs)

iterator OrderItrxVALREVERSE*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield ydb_get(ydbvar.name, subs)

iterator OrderItrxKV*(args: varargs[string]): (string, string) =
  walkOrderNodes(ydb_subscript_next):
    yield (key, ydb_get(ydbvar.name, subs))

iterator OrderItrxKVREVERSE*(args: varargs[string]): (string, string) =
  walkOrderNodes(ydb_subscript_previous):
    yield (key, ydb_get(ydbvar.name, subs))

iterator OrderItrxKEY*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_next):
    yield keysToString(ydbvar.name, subs)

iterator OrderItrxKEYREVERSE*(args: varargs[string]): string =
  walkOrderNodes(ydb_subscript_previous):
    yield keysToString(ydbvar.name, subs)

iterator OrderItrxCOUNT*(args: varargs[string]): int =
  var cnt = 0
  walkOrderNodes(ydb_subscript_next):
    inc cnt
  yield cnt

iterator OrderItrxCOUNTREVERSE*(args: varargs[string]): int =
  var cnt = 0
  walkOrderNodes(ydb_subscript_previous):
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

template walkQ[T](token: uint64, qt: static QueryType, args: varargs[string], nodeProc: untyped): T =
    let ydbvar = seqToYdbVar(args)
    when qt == qtnext:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if rc == YDB_OK: keysToString(ydbvar.name, subs)
        else: EMPTY_STRING
    elif qt  == qtCount:
        var cnt = 0
        var (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        while rc == YDB_OK:
            inc cnt
            (rc, subs) = nodeProc(ydbvar.name, subs, tptoken=token)
        cnt
    elif qt == qtKeys:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if rc == YDB_OK: subs
        else: EMPTY_KEYS
    elif qt == qtKv:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if rc == YDB_OK:
            let value = ydb_get(ydbvar.name, subs, tptoken=token)
            (keysToString(ydbvar.name, subs), value)
        else:
            (EMPTY_STRING, EMPTY_STRING)
    elif qt == qtValue:
        let (rc, subs) = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if rc == YDB_OK: ydb_get(ydbvar.name, subs, tptoken=token)
        else: EMPTY_STRING
    else:
        default(T)


# ----------------------------------
# Order template and procs
# ---------------------------------- 
template walkO[T](token: uint64, qt: static QueryType, args: varargs[string], nodeProc: untyped): T =
    var ydbvar = seqToYdbVar(args)
    when qt == qtnext:
        nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
    elif qt == qtCount:
        var subs = ydbvar.subscripts
        var key = nodeProc(ydbvar.name, subs, tptoken=token)
        while key.len > 0:
          inc result
          if subs.len > 0: subs[^1] = key
          else: subs.add(key)
          key = ydb_subscript_next(ydbvar.name, subs, tptoken=token)
        result
    elif qt == qtKeys:
        let key = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if key.len == 0: return @[]
        if ydbvar.subscripts.len > 0:
            ydbvar.subscripts[^1] = key
        else:
            ydbvar.subscripts.add(key)
        ydbvar.subscripts
    elif qt == qtKey:
        let key = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
        if key.len > 0:
            if ydbvar.subscripts.len > 0:
              ydbvar.subscripts[^1] = key
            else:
              ydbvar.subscripts.add(key)
            keysToString(ydbvar.name, ydbvar.subscripts)
        else:
            EMPTY_STRING
    elif qt == qtKv:
            let key = nodeProc(ydbvar.name, ydbvar.subscripts, tptoken=token)
            if ydbvar.subscripts.len > 0:
                ydbvar.subscripts[^1] = key
            else:
                ydbvar.subscripts.add(key)
            let value = ydb_get(ydbvar.name, ydbvar.subscripts, tptoken=token)
            (key, value)
    else:
        default(T)


#================
# Query:
#================
proc Queryx*(token: uint64, isReverse: bool, args: varargs[string]): string =
    let procedure = if isReverse: ydb_node_previous else: ydb_node_next
    walkQ[string](token, qtNext, args, procedure)

proc Queryx*(isReverse: bool, args: varargs[string]): string =
    Queryx(0, isReverse, args)

proc QueryxKEYS*(token: uint64, isReverse: bool, args: varargs[string]): seq[string] =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[seq[string]](token, qtKeys, args, procedure)

proc QueryxKEYS*(isReverse: bool, args: varargs[string]): seq[string] =
    QueryxKEYS(0, isReverse, args)

proc QueryxKV*(token: uint64, isReverse: bool, args: varargs[string]): (string, string) =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[(string, string)](token, qtKv, args, procedure)

proc QueryxKV*(isReverse: bool, args: varargs[string]): (string, string) =
    QueryxKV(0, isReverse, args)

proc QueryxVAL*(token: uint64, isReverse: bool, args: varargs[string]): string =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[string](token, qtValue, args, procedure)

proc QueryxVAL*(isReverse: bool, args: varargs[string]): string =
    QueryxVAL(0, isReverse, args)

proc QueryxCOUNT*(token: uint64, isReverse: bool, args: varargs[string]): int =
  let procedure = if isReverse: ydb_node_previous else: ydb_node_next
  walkQ[int](token, qtCount, args, procedure)

proc QueryxCOUNT*(isReverse: bool, args: varargs[string]): int =
    QueryxCOUNT(0, isReverse, args)

macro QueryxPrepare*(token: uint64, body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName2("Query", args)
    result = newCall(ident(apiName), token, newLit(reverse))
    for arg in args: result.add arg

macro Query*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName2("Query", args)
    result = newCall(ident(apiName), newLit(reverse))
    for arg in args: result.add arg


#================
# Order:
#================
proc Orderx*(token: uint64, isReverse: bool, args: varargs[string]): string =
    let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
    walkO[string](token, qtNext, args, procedure)

proc Orderx*(isReverse: bool, args: varargs[string]): string =
    Orderx(0, isReverse, args)

proc OrderxKEY*(token: uint64, isReverse: bool, args: varargs[string]): string =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[string](token, qtKey, args, procedure)

proc OrderxKEY*(isReverse: bool, args: varargs[string]): string =
    OrderxKEY(0, isReverse, args)

proc OrderxKEYS*(token: uint64, isReverse: bool, args: varargs[string]): seq[string] =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[seq[string]](token, qtKeys, args, procedure)

proc OrderxKEYS*(isReverse: bool, args: varargs[string]): seq[string] =
    OrderxKEYS(0, isReverse, args)

proc OrderxKV*(token: uint64, isReverse: bool, args: varargs[string]): (string, string) =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[(string, string)](token, qtKv, args, procedure)

proc OrderxKV*(isReverse: bool, args: varargs[string]): (string, string) =
    OrderxKV(0, isReverse, args)

proc OrderxVAL*(token: uint64, isReverse: bool, args: varargs[string]): string =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[string](token, qtValue, args, procedure)

proc OrderxVAL*(isReverse: bool, args: varargs[string]): string =
    OrderxVAL(0, isReverse, args)

proc OrderxCOUNT*(token: uint64, isReverse: bool, args: varargs[string]): int =
  let procedure = if isReverse: ydb_subscript_previous else: ydb_subscript_next
  walkO[int](token, qtCount, args, procedure)

proc OrderxCOUNT*(isReverse: bool, args: varargs[string]): int =
    OrderxCOUNT(0, isReverse, args)

macro OrderxPrepare*(token: uint64, body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName2("Order", args)
    result = newCall(ident(apiName), token, newLit(reverse))
    for arg in args: result.add arg

macro Order*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    let (apiName, reverse) = getApiName2("Order", args)
    result = newCall(ident(apiName), newLit(reverse))
    for arg in args: result.add arg



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


proc injectToken(node: NimNode, tokenIdent: NimNode): NimNode =
  var prepare: string
  if (node.kind in {nnkCall, nnkCommand}):
    let n = node[0]
    if n.eqIdent("Set"): prepare = "setx" # -> Set -> setxPrepare
    if n.eqIdent("Get"): prepare = "getx" # -> Set -> setxPrepare
    elif n.eqIdent("Data"): prepare = "datax"
    elif n.eqIdent("Increment"): prepare = "incrementx"
    elif n.eqIdent("Kill"): prepare = "killx"
    elif n.eqIdent("Killnode"): prepare = "killnodex"
    elif n.eqIdent("Query"): prepare = "Queryx"
    elif n.eqIdent("Order"): prepare = "Orderx"
        
    if prepare.len > 0:
        result = newCall(ident(prepare & "Prepare"), tokenIdent)
        for i in 1 ..< node.len: result.add node[i]
    else:
        # other items from body where nothing must be replaced
        result = node.copyNimNode()
        for child in node: result.add injectToken(child, tokenIdent)

  else:
    # other items from body where nothing must be replaced
    result = node.copyNimNode()
    for child in node: result.add injectToken(child, tokenIdent)

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
    let tptokenIdent = ident("tptoken") # Referenz für den Transformer
    let rewrittenBody = injectToken(body, tptokenIdent)

    result = quote do:
      proc `fn`(
        tptoken {.inject.}: uint64,
        errstr  {.inject.}: ptr struct_ydb_buffer_t,
        param   {.inject.}: pointer
      ): cint {.cdecl, gcsafe, raises: [].} =
        try:
            `rewrittenBody`
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

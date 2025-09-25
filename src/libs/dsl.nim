import macros
import ydbapi
import ydbtypes
import std/strutils

proc stringToSeq(s: string): Subscripts =
  if s.startsWith("@["):
    for arg in s.split(","):
      var ss = arg
      ss = replace(ss, "@")
      ss = replace(ss, "[")
      ss = replace(ss, "]")
      ss = replace(ss, "\"")
      result.add(ss.strip())
  else:
      result.add(s)


# TODO: Consolidate and refactor transformation logic for DSL macros

type
  TransformKind = enum
    tkDefault,    # Default transformation
    tkNext,       # Next node transformation 
    tkGet,        # Get transformation
    tkData,
    tkDelExcl    # del exclude

template transformBodyStmt(body: untyped): untyped =
  ## For macros that transform *statements*
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)

template transformBodyExpr(body: untyped): untyped =
  ## For macros that must yield a single *expression*
  ## If the macro was invoked with a statement-list containing exactly one item,
  ## unwrap to that item; otherwise just transform the node.
  if body.kind == nnkStmtList and body.len == 1:
    result = transform(body[0])
  else:
    result = transform(body)


proc transformCallNodeBase(node: NimNode, kind: TransformKind = tkDefault, procPrefix: string = ""): NimNode =
  var prefix: string = ""
  var rhs: NimNode
  if node.kind == nnkCall:
      rhs = node     # set: VARNAME(xxx)=yyy
  elif node.kind == nnkPrefix:
    prefix = node[0].strVal  # set: ^VARNAME(xxxx)=yyyy, $VARNAME()=yyyy
    rhs = node[1]
  elif node.kind == nnkIdent:  # z.B. { IDENT01 }
    rhs = node
  elif node.kind == nnkDotExpr:
    # top-level dot expression: e.g. gbl(1).int or (^gbl(1)).int
    rhs = node
  else:
    echo "Node kind not supported! ", node.kind

  # Helper to build basic args
  proc makeBaseArgs(callPart: NimNode): seq[NimNode] =
    let tableIdent = callPart[0]
    result = @[newLit(prefix & tableIdent.strVal)]
    for i in 1 ..< callPart.len:
      let arg = callPart[i]
      result.add newCall(ident"$", arg)

  # Helper to build basic args
  proc makeBaseArgsNext(callPart: NimNode): seq[NimNode] =
    let tableIdent = callPart[0]
    result = @[newLit(prefix & tableIdent.strVal)]
    for i in 1 ..< callPart.len:
      let arg = callPart[i]
      # Handle literals vs other expressions differently for Next transformation
      case arg.kind
      of nnkStrLit, nnkRStrLit, nnkIntLit, nnkFloatLit:
        result.add newCall(ident"$", arg)
      else:
        result.add arg

  case kind
  of tkDelExcl:
    # Handle transformation for delexcl:
    if rhs.kind == nnkCall:
      var args = makeBaseArgs(rhs)
      return newStmtList(args)

  of tkDefault:
    # Handle basic transformation
    if rhs.kind == nnkCall:
      var args = makeBaseArgs(rhs)
      return newStmtList(args)
    elif rhs.kind == nnkIdent:
      var args:seq[NimNode] = @[newLit(rhs.strVal)]
      return newStmtList(args)

  of tkNext:
    # Handle next node transformation
    if rhs.kind == nnkCall:
      let args = makeBaseArgsNext(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      # for @["x"] but also for ^gbl(id) (a single variable)
      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        let p = procPrefix & "yyy1"
        return newCall(ident(p), globalArg, transformedArgs[0])
      else:
        let p = procPrefix & "yyy"
        result = newCall(ident(p), globalArg)
        for a in transformedArgs:
          result.add a

  of tkGet:
    # Handle get transformation with type conversion
    if rhs.kind == nnkCall:
      let args = makeBaseArgs(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        return newCall(ident"getstring1", globalArg, transformedArgs[0])
      else:
        result = newCall(ident"getstring", globalArg)
        for a in transformedArgs:
          result.add newCall(ident"$", a)

    elif rhs.kind == nnkDotExpr:
      var callPart = rhs[0]   # left side of the dot
      # if left is prefixed (^gbl(1)) extract prefix and unwrap to the inner call/ident
      if callPart.kind == nnkPrefix:
        prefix = callPart[0].strVal
        callPart = callPart[1]

      var args: seq[NimNode]
      if callPart.kind == nnkCall:
        args = makeBaseArgs(callPart)
      elif callPart.kind == nnkIdent:
        args = @[newLit(prefix & callPart.strVal)]
      else:
        error("Unsupported dot-expression base: " & $callPart.kind)

      let globalArg = args[0]
      let transformedArgs = if args.len > 1: args[1..^1] else: @[]

      let fieldPart = rhs[1]
      let suffix = fieldPart.strVal
      let procName = case suffix
        of "float": "getfloat"
        of "float32": "getfloat32"
        of "float64": "getfloat"
        of "int": "getint"
        of "int8": "getint8"
        of "int16": "getint16"
        of "int32": "getint32"
        of "int64": "getint"
        of "uint": "getuint"
        of "uint8": "getuint8"
        of "uint16": "getuint16"
        of "uint32": "getuint32"
        of "uint64": "getuint"
        else: error("Unsupported suffix: " & suffix)

      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit, nnkFloatLit}:
        return newCall(ident(procName), globalArg, transformedArgs[0])
      else:
        result = newCall(ident(procName), globalArg)
        for a in transformedArgs:
          result.add newCall(ident"$", a)

    elif rhs.kind == nnkIdent:
      return newCall(ident"getstring", @[newLit(prefix & rhs.strVal)])

  of tkData:
    # Handle get transformation with type conversion
    if rhs.kind == nnkCall:
      let args = makeBaseArgs(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        return newCall(ident"dataxxx1", globalArg, transformedArgs[0])
      else:
        result = newCall(ident"dataxxx", globalArg)
        for a in transformedArgs:
          result.add newCall(ident"$", a)
    elif rhs.kind == nnkIdent:
      return newCall(ident"dataxxx", @[newLit(prefix & rhs.strVal)])


# Update existing transform procs to use the base version
proc transformCallNode(node: NimNode): seq[NimNode] =
  let transformed = transformCallNodeBase(node, tkDefault, "")
  if transformed.kind == nnkStmtList:
    for stmt in transformed: result.add stmt

proc transformCallNodeNext(node: NimNode, procPrefix:string = ""): NimNode =
  transformCallNodeBase(node, tkNext, procPrefix)

proc transformCallNodeGET(node: NimNode, procPrefix:string = ""): NimNode = 
  transformCallNodeBase(node, tkGet, procPrefix)

proc transformCallNodeDATA(node: NimNode, procPrefix:string = ""): NimNode = 
  transformCallNodeBase(node, tkData, procPrefix)


# ------------------- Statement-context DSL macros -------------------
macro set*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix or lhs.kind == nnkCall:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs)
        return newCall(ident"setxxx", args)
    else:
      return node
  transformBodyStmt body


macro incr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:  # ^CNT("AUTO")=<increment>
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs)
        return newCall(ident"incrxxx", args)
    elif node.kind == nnkPrefix:  # ^CNT("AUTO").
      var args = transformCallNode(node)
      return newCall(ident"incr1xxx", args)
    else:
      return node
  transformBodyStmt body


macro delnode*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"delnodexxx", args)
    else:
      return node
  transformBodyStmt body


macro deltree*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"deltreexxx", args)
    else:
      return node
  transformBodyStmt body

macro delexcl*(body: untyped): untyped =
  var args: seq[NimNode] = @[]
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkCurly:
      for n in 0..<node.len:
        args.add(transformCallNode(node[n]))
      return newCall(ident"delexclxxx", args)
    else:
      return node
  transformBodyStmt body

macro lock*(body: untyped): untyped =
  var args: seq[NimNode] = @[]
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      args.add(transformCallNode(node))
      return newCall(ident"lockxxx", args)
    elif node.kind == nnkCurly:
      for n in 0..<node.len:
        let prefixNode = node[n]
        args.add(transformCallNode(prefixNode))
      return newCall(ident"lockxxx", args)
    else:
      return node
  transformBodyStmt body

macro lockincr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"lockincrxxx", args)
    else:
      return node
  transformBodyStmt body

macro lockdecr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"lockdecrxxx", args)
    else:
      return node
  transformBodyStmt body


# ------------------- Expression-context macros -------------------

macro get*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind in {nnkPrefix, nnkCall, nnkDotExpr, nnkIdent}:
      return transformCallNodeGET(node)
    else:
      return node

  # unwrap stmtlist if present
  if body.kind == nnkStmtList:
    if body.len != 1:
      error("get: expects exactly one expression", body)
    result = transform(body[0])
  else:
    result = transform(body)



macro nextnode*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      return transformCallNodeNext(node, "nextnode")
    else:
      return node
  transformBodyExpr body

macro prevnode*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      return transformCallNodeNext(node, "prevnode")
    else:
      return node
  transformBodyExpr body

macro nextsubscript*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      return transformCallNodeNext(node, "nextsub")
    else:
      return node
  transformBodyExpr body

macro prevsubscript*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      return transformCallNodeNext(node, "prevsub")
    else:
      return node
  transformBodyExpr body


macro data*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix or node.kind == nnkCall:
      return transformCallNodeDATA(node)
    else:
      return node

  # unwrap stmtlist if present
  if body.kind == nnkStmtList:
    if body.len != 1:
      error("get: expects exactly one expression", body)
    result = transform(body[0])
  else:
    result = transform(body)



# Proc^s that implement the ydb call's

# -------------------
# get* procs
# -------------------
proc getstring*(args: varargs[string]): string =
  ydb_get(args[0], args[1..^1])

proc getstring1*(global: string, args: seq[string]): string =
  ydb_get(global, args[0..^1])

proc getstring1*(global: string, s: string): string =
  if s.startsWith("@["):
    ydb_get(global, stringToSeq(s))
  else:
    ydb_get(global, @[s])

proc getnumber(global:string, args: varargs[string]): string =
  var subs:Subscripts
  for arg in args:
    if arg.startsWith("@["):
      subs.add(stringToSeq(arg))
    else:
      subs.add(arg)
  ydb_get(global, subs)

proc getint*(global:string, args: varargs[string]): int =
  parseInt(getnumber(global, args)).int
proc getint8*(global:string, args: varargs[string]): int8 =
  let value = parseInt(getnumber(global, args)).int
  if value > int8.high or value < int8.low:
    raise newException(ValueError, "Not in " & $int8.low & " .. " & $int8.high)
  else:
    return value.int8
proc getint16*(global:string, args: varargs[string]): int16 =
  let value = parseInt(getnumber(global, args)).int
  if value > int16.high or value < int16.low:
    raise newException(ValueError, "Not in " & $int16.low & " .. " & $int16.high)
  else:
    return value.int16
proc getint32*(global:string, args: varargs[string]): int32 =
  let value = parseInt(getnumber(global, args)).int
  if value > int32.high or value < int32.low:
    raise newException(ValueError, "Not in " & $int32.low & " .. " & $int32.high)
  else:
    return value.int32

proc getuint*(global:string, args: varargs[string]): uint =
  parseUInt(getnumber(global, args)).uint
proc getuint8*(global:string, args: varargs[string]): uint8 =
  let value = parseUInt(getnumber(global, args)).uint
  if value > uint8.high or value < 0:
    raise newException(ValueError, "Not in " & $uint8.low & " .. " & $uint8.high)
  else:
    return value.uint8
proc getuint16*(global:string, args: varargs[string]): uint16 =
  let value = parseUInt(getnumber(global, args)).uint
  if value > uint16.high or value < 0:
    raise newException(ValueError, "Not in " & $uint16.low & " .. " & $uint16.high)
  else:
    return value.uint16
proc getuint32*(global:string, args: varargs[string]): uint32 =
  let value = parseUInt(getnumber(global, args)).uint
  if value > uint32.high or value < 0:
    raise newException(ValueError, "Not in " & $uint32.low & " .. " & $uint32.high)
  else:
    return value.uint32

proc getfloat*(global:string, args: varargs[string]): float =
  parseFloat(getnumber(global, args)).float
proc getfloat32*(global:string, args: varargs[string]): float32 =
  parseFloat(getnumber(global, args)).float32


# -------------------
# nextnode procs
# -------------------
proc nextnodeyyy*(args: varargs[string]): (int, Subscripts) =
  var subscripts = args[1..^1]
  ydb_node_next(args[0], subscripts)

proc nextnodeyyy1*(global: string, subscripts: seq[string]): (int, Subscripts) =
  ydb_node_next(global, subscripts)

proc nextnodeyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_node_next(global, subscripts)


# -------------------
# nextsubscript procs
# -------------------
proc nextsubyyy*(args: varargs[string]): (int, Subscripts) =
  var subscripts = args[1..^1]
  ydb_subscript_next(args[0], subscripts)

proc nextsubyyy1*(global: string, subscripts: var seq[string]): (int, Subscripts) =
  ydb_subscript_next(global, subscripts)

proc nextsubyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_subscript_next(global, subscripts)

proc nextsubyyy1*(global: string, sub: Subscripts): (int, Subscripts) =
  var subscripts:seq[string] = sub
  ydb_subscript_next(global, subscripts)


# -------------------
# prevsubscript procs
# -------------------
proc prevsubyyy*(args: varargs[string]): (int, Subscripts) =
  var subscripts = args[1..^1]
  ydb_subscript_previous(args[0], subscripts)

proc prevsubyyy1*(global: string, subscripts: var seq[string]): (int, Subscripts) =
  ydb_subscript_previous(global, subscripts)

proc prevsubyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_subscript_previous(global, subscripts)


# -------------------
# prevnode procs
# -------------------
proc prevnodeyyy*(args: varargs[string]): (int, Subscripts) =
  var subscripts = args[1..^1]
  ydb_node_previous(args[0], subscripts)

proc prevnodeyyy1*(global: string, subscripts: seq[string]): (int, Subscripts) =
  ydb_node_previous(global, subscripts)

proc prevnodeyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_node_previous(global, subscripts)


# ---------------------
# set proc
# ---------------------
proc setxxx*(args: varargs[string]) =
  if args.len == 3 and args[1].startsWith("@["):
    ydb_set(args[0], stringToSeq(args[1]), args[^1])
  else:
    ydb_set(args[0], args[1..^2], args[^1])


# ----------------------
# incr (increment) procs
# ----------------------
proc incr1xxx*(args: varargs[string]): int =
  ydb_increment(args[0], args[1..^1])

proc incrxxx*(args: varargs[string]): int =
  ydb_increment(args[0], args[1..^2], parseInt(args[^1]))


# -------------------
# data proc
# -------------------
proc dataxxx*(args: varargs[string]): int =
  ydb_data(args[0], args[1..^1])

proc dataxxx1*(global: string, args: seq[string]): int =
  ydb_data(global, args[0..^1])

proc dataxxx1*(global: string, s: string): int =
  if s.startsWith("@["):
    ydb_data(global, stringToSeq(s))
  else:
    ydb_data(global, @[s])



# -------------------
# del Node/Tree procs
# -------------------
proc delnodexxx*(args: varargs[string]) =
  var subs: Subscripts
  for arg in args[1..^1]:
    if arg.startsWith("@["):
      subs.add(stringToSeq(arg))
    else:
      subs.add(arg)
  ydb_delete_node(args[0], subs)


proc deltreexxx*(args: varargs[string]) =
  ydb_delete_tree(args[0], args[1..^1])


# -------------------
# delexcl procs
# -------------------
proc delexclxxx*(args: varargs[string]) =
  ydb_delete_excl(args[0..^1])


# ---------------------
# lock proc
# ---------------------
proc lockxxx*(args: varargs[string]) =
  # Convert 
  # args=["^LL", "HAUS", "11", "^LL", "HAUS", "12"] ->
  # subs:@[@["^LL", "HAUS", "11"], @["^LL", "HAUS", "12"]]
  var subs:seq[seq[string]] = @[]
  var tmp:seq[string] = @[]
  for arg in args:
    if arg[0] == '^':
        if tmp.len > 0:
          subs.add(tmp)
          tmp = @[]
    tmp.add(arg)
  if tmp.len > 0:
    subs.add(tmp)
  try:
    ydb_lock(100000, subs)
  except:
    echo getCurrentExceptionMsg()


# ----------------------
# lockincr / decr proc's
# ----------------------
proc lockincrxxx*(args: varargs[string]) =
  # Increment lock count for variable
  # TODO: make timeout readable from DSL macro ^LL("HAUS"),100000 o.ä.
  ydb_lock_incr(100000.culonglong, args[0], args[1..^1])

proc lockdecrxxx*(args: varargs[string]) =
  # Decrement lock count for variable
  ydb_lock_decr(args[0], args[1..^1])

import macros
import yottadb_api
import yottadb_types
import std/strutils

# Consolidated transformation logic for DSL macros

template transformBody(body: untyped): untyped =
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)


type
  TransformKind = enum
    tkDefault,    # Default transformation
    tkNext,       # Next node transformation 
    tkGet        # Get transformation

proc transformCallNodeBase(node: NimNode, kind: TransformKind = tkDefault): NimNode =
  ## Consolidated transform procedure that handles all cases
  if node.kind != nnkPrefix:
    error "unsupported node kind: " & $node.kind
    return node

  let prefix = node[0].strVal   # get ^, $, or ''
  let rhs = node[1]

  # Helper to build basic args
  proc makeBaseArgs(callPart: NimNode): seq[NimNode] =
    let tableIdent = callPart[0]
    result = @[newLit(prefix & tableIdent.strVal)]
    for i in 1 ..< callPart.len:
      let arg = callPart[i]
      # Handle literals vs other expressions differently for Next transformation
      if kind == tkNext or kind == tkGet:
        case arg.kind
        of nnkStrLit, nnkRStrLit, nnkIntLit:
          result.add newCall(ident"$", arg)
        else:
          #result.add arg
          result.add newCall(ident"$", arg)
      else:
        result.add newCall(ident"$", arg)

  # Helper to build basic args
  proc makeBaseArgsNext(callPart: NimNode): seq[NimNode] =
    let tableIdent = callPart[0]
    result = @[newLit(prefix & tableIdent.strVal)]
    for i in 1 ..< callPart.len:
      let arg = callPart[i]
      # Handle literals vs other expressions differently for Next transformation
      if kind == tkNext or kind == tkGet:
        case arg.kind
        of nnkStrLit, nnkRStrLit, nnkIntLit:
          result.add newCall(ident"$", arg)
        else:
          result.add arg
      else:
        result.add newCall(ident"$", arg)

  case kind
  of tkDefault:
    # Handle basic transformation
    if rhs.kind == nnkCall:
      var args = makeBaseArgs(rhs)
      return newStmtList(args)

  of tkNext:
    # Handle next node transformation
    if rhs.kind == nnkCall:
      let args = makeBaseArgsNext(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      
      if transformedArgs.len == 1 and 
         transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        return newCall(ident"nextnodeyyy1", globalArg, transformedArgs[0])
      else:
        result = newCall(ident"nextnodeyyy", globalArg)
        for a in transformedArgs:
          result.add a

  of tkGet:
    # Handle get transformation with type conversion
    if rhs.kind == nnkCall:
      #return newCall(ident"getstring", makeBaseArgs(rhs))
      let args = makeBaseArgsNext(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        return newCall(ident"getstring1", globalArg, transformedArgs[0])
      else:
        result = newCall(ident"getstring", globalArg)
        for a in transformedArgs:
          #result.add a
          result.add newCall(ident"$", a)

    elif rhs.kind == nnkDotExpr:
      let callPart = rhs[0]
      let fieldPart = rhs[1]
      
      if callPart.kind != nnkCall:
        error("Expected a call on left side of dotExpr")
        return node

      let args = makeBaseArgs(callPart)
      let suffix = fieldPart.strVal
      let procName = case suffix
        of "float": "getfloat"
        of "int": "getint"
        of "string": "getstring"
        else: error("Unsupported suffix: " & suffix)
                   
      return newCall(ident(procName), args)
    elif rhs.kind == nnkIdent:
      return newCall(ident"getstring", @[newLit(prefix & rhs.strVal)])

# Update existing transform procs to use the base version
proc transformCallNode(node: NimNode): seq[NimNode] =
  let transformed = transformCallNodeBase(node, tkDefault)
  if transformed.kind == nnkStmtList:
    for stmt in transformed: result.add stmt

proc transformCallNodeNext(node: NimNode): NimNode =
  transformCallNodeBase(node, tkNext)

proc transformCallNodeGET(node: NimNode): NimNode = 
  transformCallNodeBase(node, tkGet)

# ------------------- DSL macros -------------------

macro set*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs)
        return newCall(ident"setxxx", args)
    else:
      return node

  transformBody body


macro incr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:  # assignment ^CNT("AUTO")=<increment>
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs) # the value to assign
        return newCall(ident"incrxxx", args)
    elif node.kind == nnkPrefix:  # ^CNT("AUTO"). (Increment defaults to 1)
      var args = transformCallNode(node)
      return newCall(ident"incr1xxx", args)
    else:
      return node
  
  transformBody body


macro get*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      return transformCallNodeGET(node)
    elif node.kind == nnkStmtList:
      result = newStmtList()
      for ch in node:
        result.add transform(ch)
    else:
      return node

  transformBody body

macro nextn*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNodeNext(node)
      return args
    else:
      return node

  transformBody body

macro data*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"dataxxx", args)
    else:
      return node

  transformBody body


macro delnode*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"delnodexxx", args)
    else:
      return node

  transformBody body


macro deltree*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"deltreexxx", args)
    else:
      return node

  transformBody body


macro lock*(body: untyped): untyped =
  var args:seq[NimNode] = @[]
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

  transformBody body


# Proc^s that implement the ydb call's

# -------------------
# get* procs
# -------------------
proc getstring*(args: varargs[string]): string =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbGet(global, subscripts)  
proc getstring1*(global: string, args: seq[string]): string =
  let subscripts = args[0..^1]
  result = ydbGet(global, subscripts)
proc getstring1*(global: string, args: string): string =
  let subscripts: seq[string] = @[args]
  result = ydbGet(global, subscripts)

proc getfloat*(args: varargs[string]): float =
  let global = args[0]
  let subscripts = args[1..^1]
  result = parseFloat(ydbGet(global, subscripts))

proc getint*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  result = parseInt(ydbGet(global, subscripts))

# -------------------
# nextnode procs
# -------------------
proc nextnodeyyy*(args: varargs[string]): Subscripts =
  let global = args[0]
  var subscripts = args[1..^1]
  result = nextNode(global, subscripts)
proc nextnodeyyy1*(global: string, subscripts: var seq[string]): Subscripts =
  result = nextNode(global, subscripts)
proc nextnodeyyy1*(global: string, sub: string): Subscripts =
  var subscripts:seq[string] = @[sub]
  result = nextNode(global, subscripts)


# ---------------------
# set proc
# ---------------------
proc setxxx*(args: varargs[string]) =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = args[^1]
  ydbSet(global, subscripts, value)


# ----------------------
# incr (increment) procs
# ----------------------
proc incr1xxx*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  return ydbIncrement(global, subscripts)

proc incrxxx*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = parseInt(args[^1])
  return ydbIncrement(global, subscripts, value)


# -------------------
# data proc
# -------------------
proc dataxxx*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbData(global, subscripts)


# -------------------
# del Node/Tree procs
# -------------------
proc delnodexxx*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbDeleteNode(global, subscripts)

proc deltreexxx*(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbDeleteTree(global, subscripts)


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
    ydbLock(100000, subs)
  except:
    echo getCurrentExceptionMsg()

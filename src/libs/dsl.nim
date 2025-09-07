import macros
import yottadb_api
import yottadb_types
import std/strutils
import std/times


template transformBody(body: untyped): untyped =
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)

proc transformCallNode(node: NimNode): seq[NimNode] = 
  ## tablePrefix '^' for yottadb global variables, '$' for Special variables, '' empty for variables
  if node.kind == nnkPrefix:
    let prefix = node[0].strVal # get ^, $, or ''
    let callNode = node[1]
    if callNode.kind == nnkCall:
      let tableIdent = callNode[0]
      result.add newLit(prefix & $tableIdent)      # turn Ident into string "CUSTOMER"
      for i in 1 ..< callNode.len:
        result.add newCall(ident"$", callNode[i])
  else:
    echo "unsupported node node.kind=", node.kind


proc transformCallNodeNext(node: NimNode): NimNode =
  ## Special version for nextnode macro
  echo "transformCallNode in dls_test"
  if node.kind == nnkPrefix:
    let prefix = node[0].strVal
    let callNode = node[1]
    if callNode.kind == nnkCall:
      let tableIdent = callNode[0]
      let globalArg = newLit(prefix & $tableIdent)

      var transformedArgs: seq[NimNode] = @[]
      for i in 1 ..< callNode.len:
        let arg = callNode[i]
        case arg.kind
        of nnkStrLit, nnkRStrLit, nnkIntLit:
          # literals → wrap with `$`
          transformedArgs.add newCall(ident"$", arg)
        else:
          # identifiers, symbols, exprs → pass directly
          transformedArgs.add(arg)

      if transformedArgs.len == 1 and
         transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        # one non-literal arg → call overload (string, seq[string])
        result = newCall(ident"nextnodeyyy1", globalArg, transformedArgs[0])
      else:
        # multiple args (or literals) → call overload (varargs[string])
        result = newCall(ident"nextnodeyyy", globalArg)
        for a in transformedArgs:
          result.add a
    else:
      error "unsupported callNode kind: " & $callNode.kind
  else:
    error "unsupported node kind: " & $node.kind


proc transformCallNodeGET(node: NimNode): NimNode =
  ## Special version for Get with .int, .float conversion
  ## Handles ^, $ and '' prefixes
  doAssert node.kind == nnkPrefix
  let prefix = node[0].strVal   # "^", "$", or ""
  let rhs = node[1]

  # helper to build args
  proc makeArgs(callPart: NimNode): seq[NimNode] =
    let tableIdent = callPart[0]
    result = @[ newLit(prefix & tableIdent.strVal) ]
    for i in 1 ..< callPart.len:
      result.add newCall(ident"$", callPart[i])

  if rhs.kind == nnkCall:
    # ^CUST(id,1) or $USER(id)
    return newCall(ident"getstring", makeArgs(rhs))

  elif rhs.kind == nnkDotExpr:
    # ^CUST(id,1).float or $USER(id).int
    let callPart = rhs[0]
    let fieldPart = rhs[1]

    if callPart.kind != nnkCall:
      error("Expected a call on left side of dotExpr")

    let args = makeArgs(callPart)
    let suffix = fieldPart.strVal
    let procName =
      case suffix
      of "float": "getfloat"
      of "int": "getint"
      of "string": "getstring"
      else: error("Unsupported suffix: " & suffix)

    return newCall(ident(procName), args)

  elif rhs.kind == nnkIdent:
    # plain ^NAME or $NAME
    return newCall(ident"getstring", @[newLit(prefix & rhs.strVal)])

  else:
    error("Unsupported rhs of prefix: " & $rhs.kind)


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


macro nextn*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNodeNext(node)
      return args
    else:
      return node

  transformBody body


# Proc^s that implement the ydb call's
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
# get* procs
# -------------------
proc getstring*(args: varargs[string]): string =
  let global = args[0]
  let subscripts = args[1..^1]
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

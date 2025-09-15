import macros
import yottadb_api
import yottadb_types
import std/strutils

# TODO: Consolidate and refactor transformation logic for DSL macros

type
  TransformKind = enum
    tkDefault,    # Default transformation
    tkNext,       # Next node transformation 
    tkGet        # Get transformation
    tkDelExcl    # del exclude


template transformBody(body: untyped): untyped =
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
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
  else:
    echo "Node kind not supported! ", node.kind

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
      
      if transformedArgs.len == 1 and 
         transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
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
      let args = makeBaseArgsNext(rhs)
      let globalArg = args[0]
      let transformedArgs = args[1..^1]
      if transformedArgs.len == 1 and transformedArgs[0].kind notin {nnkStrLit, nnkRStrLit, nnkIntLit}:
        return newCall(ident"getstring1", globalArg, transformedArgs[0])
      else:
        result = newCall(ident"getstring", globalArg)
        for a in transformedArgs:
          result.add newCall(ident"$", a)

    elif rhs.kind == nnkDotExpr:
      let callPart = rhs[0]
      let fieldPart = rhs[1]
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
  let transformed = transformCallNodeBase(node, tkDefault, "")
  if transformed.kind == nnkStmtList:
    for stmt in transformed: result.add stmt

proc transformCallNodeNext(node: NimNode, procPrefix:string = ""): NimNode =
  transformCallNodeBase(node, tkNext, procPrefix)

proc transformCallNodeGET(node: NimNode): NimNode = 
  transformCallNodeBase(node, tkGet)


# ------------------- DSL macros -------------------

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
    if node.kind == nnkPrefix or node.kind == nnkCall:
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
      var args = transformCallNodeNext(node, "nextnode")
      return args
    else:
      return node
  transformBody body


macro prevn*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNodeNext(node, "prevnode")
      return args
    else:
      return node
  transformBody body


macro nextsub*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNodeNext(node, "nextsub")
      return args
    else:
      return node
  transformBody body


macro prevsub*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNodeNext(node, "prevsub")
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


macro delexcl*(body: untyped): untyped =
  var args:seq[NimNode] = @[]
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkCurly:
      for n in 0..<node.len:
        args.add(transformCallNode(node[n]))
      return newCall(ident"delexclxxx", args)
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


macro lockincr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"lockincrxxx", args)
    else:
      return node
  transformBody body


macro lockdecr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"lockdecrxxx", args)
    else:
      return node
  transformBody body


# Proc^s that implement the ydb call's

# -------------------
# get* procs
# -------------------
proc getstring*(args: varargs[string]): string =
  ydb_get(args[0], args[1..^1])

proc getstring1*(global: string, args: seq[string]): string =
  ydb_get(global, args[0..^1])

proc getstring1*(global: string, args: string): string =
  ydb_get(global, @[args])

proc getfloat*(args: varargs[string]): float =
  parseFloat(ydb_get(args[0], args[1..^1]))

proc getint*(args: varargs[string]): int =
  parseInt(ydb_get(args[0], args[1..^1]))


# -------------------
# nextnode procs
# -------------------
proc nextnodeyyy*(args: varargs[string]): (int, Subscripts) =
  var subscripts = args[1..^1]
  ydb_node_next(args[0], subscripts)

proc nextnodeyyy1*(global: string, subscripts: var seq[string]): (int, Subscripts) =
  ydb_node_next(global, subscripts)

proc nextnodeyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_node_next(global, subscripts)


# -------------------
# nextsub procs
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
# prevsub procs
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

proc prevnodeyyy1*(global: string, subscripts: var seq[string]): (int, Subscripts) =
  ydb_node_previous(global, subscripts)

proc prevnodeyyy1*(global: string, sub: string): (int, Subscripts) =
  var subscripts:seq[string] = @[sub]
  ydb_node_previous(global, subscripts)


# ---------------------
# set proc
# ---------------------
proc setxxx*(args: varargs[string]) =
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
  result = ydb_data(args[0], args[1..^1])


# -------------------
# del Node/Tree procs
# -------------------
proc delnodexxx*(args: varargs[string]) =
  ydb_delete_node(args[0], args[1..^1])

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
  let global = args[0]
  let timeout:culonglong = 100000  #TODO make readable from DSL macro ^LL("HAUS"),100000 o.ä.
  let subscripts = args[1..^1]
  ydb_lock_incr(timeout, global, subscripts)

proc lockdecrxxx*(args: varargs[string]) =
  # Decrement lock count for variable
  let global = args[0]
  let subscripts = args[1..^1]
  ydb_lock_decr(global, subscripts)

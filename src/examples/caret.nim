import macros
import ../yottadb
import std/strformat
import std/strutils
import utils

macro set(body: untyped): untyped =
  ## Rewrites:
  ##   ^TABLE(args...) = value   → setxxx("TABLE", $args..., $value)
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:                # assignment
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix and lhs[0].eqIdent("^"):
        let callNode = lhs[1]
        if callNode.kind == nnkCall:
          let tableIdent = callNode[0]
          var args: seq[NimNode] = @[]
          args.add newLit("^" & $tableIdent)      # turn Ident into string "CUSTOMER"
          for i in 1 ..< callNode.len:
            args.add newCall(ident"$", callNode[i])
          args.add newCall(ident"$", rhs)
          return newCall(ident"setxxx", args)

    # fallback: return node unchanged
    return node

  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)


macro get(body: untyped): untyped =
  ## Rewrites:
  ##   ^TABLE(args...)           → getxxx("TABLE", $args...)
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix and node[0].eqIdent("^"):  # bare ^TABLE(...)
      let callNode = node[1]
      if callNode.kind == nnkCall:
        let tableIdent = callNode[0]
        var args: seq[NimNode] = @[]
        args.add newLit("^" & $tableIdent)
        for i in 1 ..< callNode.len:
          args.add newCall(ident"$", callNode[i])
        return newCall(ident"getxxx", args)

    # fallback: return node unchanged
    return node

  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)


proc setxxx(args: varargs[string]) =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = args[^1]
  ydbSet(global, subscripts, value)

proc getxxx(args: varargs[string]): string =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbGet(global, subscripts)

proc main(): int =
    for id in 0..<1000000:
        #set:
        #    ^CUST(id, 1, id) = 3.1414

        let val = get:
            ^CUST(id, 1, id)
        echo "id:", id, " val:", val
        var fval = parseFloat(val)
        fval += 1.234567
        set: ^CUST(id, 1, id) = fval
 
    return 0


echo main()

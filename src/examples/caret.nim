import macros
import ../yottadb

proc nodesToStrings(nodes: seq[NimNode]): seq[string] =
  result = @[]
  for n in nodes:
    case n.kind
    of nnkStrLit..nnkTripleStrLit:
      result.add(n.strVal)
    of nnkIntLit..nnkUInt64Lit:
      result.add($n.intVal)
    of nnkIdent:
      result.add($n)        # identifier name as string
    of nnkSym:
      result.add($n)        # symbol name
    else:
      echo "fallback n.repr=", n.repr
      result.add(n.repr)    # fallback: dump source form

proc stringsToNodes(xs: seq[string]): seq[NimNode] =
  result = @[]
  for x in xs:
    result.add newLit(x)

macro caretAssign(body: untyped): untyped =
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      var transformed = false
      if stmt.kind == nnkAsgn:
        let lhs = stmt[0]
        let rhs = stmt[1]

        if lhs.kind == nnkPrefix and lhs[0].eqIdent("^"):
          let callNode = lhs[1]
          if callNode.kind == nnkCall:
            let tableIdent = callNode[0]              # e.g. CUSTOMER
            var args: seq[NimNode] = @[]
            for i in 1 ..< callNode.len:
              # wrap each arg as `$expr`
              args.add newCall(ident"$", callNode[i])
            # append RHS as string too
            args.add newCall(ident"$", rhs)
            let newName = ident("set" & $tableIdent)
            result.add newCall(newName, args)
            transformed = true

      if not transformed:
        result.add stmt
  else:
    result = body

proc toSeq[T](a: varargs[T]): seq[T] =
  result = @[]
  for x in a:
    result.add x

proc setCUSTOMER(args: varargs[string]) =
  echo "setCUSTOMER called with ", args.len, " arguments:"
  for a in args:
    echo "  - ", a, " type:"
  ydbSet("^CUSTOMER", @["1", "3.14", "42"],"lothar")


let id = 1
let someOtherVar = 42
let f = 3.14
caretAssign:
    ^CUSTOMER(id, "Name", f, someOtherVar) = "lothar"
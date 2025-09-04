import macros
import ../yottadb

macro set(body: untyped): untyped =
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
            var args: seq[NimNode] = @[]
            let tableIdent = callNode[0]
            args.add newLit("^" & $tableIdent)  # turn Ident "CUSTOMER" into string "^CUSTOMER"
            for i in 1 ..< callNode.len:
              args.add newCall(ident"$", callNode[i])
            args.add newCall(ident"$", rhs)
            let newName = ident("setydb")
            result.add newCall(newName, args)
            transformed = true

      if not transformed:
        result.add stmt
  else:
    result = body

proc setydb(args: varargs[string]) =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = args[^1]
  ydbSet(global, subscripts, value)
  
let value = "Hello World"
for id in 0..<1:
    set: ^CUSTOMER(id) = value

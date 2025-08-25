import ../yottadb

proc listGlobal(global: string, start: Subscripts = @[""]) =
  var subs = start
  for subs in nextNode(global, subs):
    echo subscriptsToString(global, subs)


when isMainModule:
    let globals = getGlobals()
    for global in globals:
        listGlobal(global)
        echo ""

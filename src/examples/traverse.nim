import ../yottadb

# Demo program to traverse through all global variables

proc listGlobal(global: string, start: Subscripts = @[""]) =
  var subs = start
  for subs in nextNode(global, subs):
    echo subscriptsToValue(global, subs)


when isMainModule:
    for global in getGlobals():
        listGlobal(global)
        echo ""

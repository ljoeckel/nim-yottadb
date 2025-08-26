import ../yottadb
import std/[cpuinfo, parseutils]

when compileOption("threads"):
  import os, ../tui_widget, strutils, marshal, strformat, times

#   proc createList(): seq[ListRow] =
#     result = newSeq[ListRow]()
#     for global in getGlobals():
#       #var lr = newListRow(0, global, "$$d", bgColor=bgCyan)
#       var lr = newListRow(0, global, global, bgColor=bgCyan)
#       result.add(lr)
          
#   var rows = createList()
#   var contentDisplay = newDisplay(31, 1, consoleWidth(), consoleHeight(), title = "Content")
#   var dirView = newListView(1, 1, 30, consoleHeight(), title="", rows = rows, bgColor = bgBlue, selectionStyle=Highlight)

#   dirView.onEnter = proc (lv: ListView, args: varargs[string]) =
#     let global = args[0]
#     contentDisplay.text = global
#     contentDisplay.show(resetCursor=true)

#     var subs:Subscripts = @[""]
#     var content = ""
#     var cnt = 0
#     for subs in nextNode(global, subs):
#       let value = subscriptsToValue(global, subs)
#       content = content & subscriptsToValue(global, subs) & "\n"
#       inc(cnt)
#       if cnt > 10: break
#     contentDisplay.text = content
#     contentDisplay.show(resetCursor=true)

when isMainModule:

  when compileOption("threads"):
    echo "✅ Compiled with threading support for ", countProcessors(), " CPU threads." 


  proc listGlobal(global: string, start: Subscripts = @[""]) =
    var subs = start
    for subs in nextNode(global, subs):
      echo subscriptsToValue(global, subs)

  var cnt = 0
  for global in getGlobals():
     echo "global:", global
     listGlobal(global)
     inc(cnt)
     if cnt > 10: break

  # var subscript = @["CNT"]
  # let global = "^CNT"
  # for i in 0..1000:
  #   let value = ydbIncrement(global, subscript)
  #   echo value
  #   assert value == parseInt(ydbGet(global, subscript))
  #   subscript.add($value)
  #   ydbSet(global, subscript, $value)
  #   discard subscript.pop()

    
  # var tuiapp = newTerminalApp(title = "Globals", border=false, rpms=20)
  # tuiapp.addWidget(dirView)
  # tuiapp.addWidget(contentDisplay)
  # tuiapp.run(nonBlocking=true)


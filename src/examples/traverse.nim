import ../yottadb
import ../tui_widget

proc createList(): seq[ListRow] =
  result = newSeq[ListRow]()
  for global in getGlobals():
    var lr = newListRow(0, global, global, bgColor=bgCyan)
    result.add(lr)
        
var rows = createList()
var contentDisplay = newDisplay(31, 1, consoleWidth(), consoleHeight(), title = "")
var dirView = newListView(1, 1, 30, consoleHeight(), title="", rows = rows, bgColor = bgBlue, selectionStyle=Highlight)

dirView.onEnter = proc (lv: ListView, args: varargs[string]) =
  let global = args[0]
  contentDisplay.title = " " & global & " " 
  contentDisplay.show(resetCursor=true)

  var subs:Subscripts = @[""]
  var content = ""
  for subs in nextNodeIter(global, subs):
    let value = subscriptsToValue(global, subs)
    content = content & value & "\n"
  contentDisplay.text = content
  contentDisplay.show(resetCursor=true)

var tuiapp = newTerminalApp(title = "Globals", border=false, rpms=20)
tuiapp.addWidget(dirView)
tuiapp.addWidget(contentDisplay)
tuiapp.run(nonBlocking=true)


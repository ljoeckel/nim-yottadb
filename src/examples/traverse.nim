import ../yottadb
import tui_widget

const header = @["Key","Value"]

proc getGlobalRows(): seq[ListRow] =
  result = newSeq[ListRow]()
  for global in getGlobals():
    var lr = newListRow(0, global, global, bgColor=bgCyan)
    result.add(lr)

var globalRows = getGlobalRows()

var globalsView = newListView(1, 1, 30, consoleHeight(), title="", rows = globalRows, bgColor = bgBlue, selectionStyle=Highlight, statusBar=false)
var dataView = newTable(31, 1, consoleWidth(), consoleHeight(), title="", selectionStyle=Highlight, enableHelp=true)
dataView.headerFromArray(header)

globalsView.onEnter = proc (lv: ListView, args: varargs[string]) =
  let global = args[0]  
  dataView.title = " " & global & " " 
  dataView.clearRows()
  
  var tableRows = newSeq[newSeq[string]()]()
  var subs:Subscripts = @[""]
  for subs in ydb_node_next_iter(global, subs):
    let value = ydb_get(global, subs)
    tableRows.add(@[keysToString(subs), value])

  dataView.loadFromSeq(tableRows)
  dataView.show(resetCursor=true)

proc main() =
  var tuiapp = newTerminalApp(title = "Globals", border=false, rpms=100)
  tuiapp.addWidget(globalsView)
  tuiapp.addWidget(dataView)
  tuiapp.run(nonBlocking=true)

when isMainModule:
  main()

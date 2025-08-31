import std/[strutils, os, osproc, streams]
import yottadb_types
import yottadb_impl

proc ydbMessage*(status: cint): string =
  return ydbMessage_db(status)

proc ydbSet*(name: string, keys: Subscripts = @[]; value: string = "") =
  ydb_set_db(name, keys, value)

proc ydbGet*(name: string, keys: Subscripts = @[]): string =
  return ydb_get_db(name, keys)

proc ydbData*(name: string, keys: Subscripts): int =
  return ydb_data_db(name, keys)

proc ydbDeleteNode*(name: string, keys: Subscripts): int =
  return ydb_delete_node_db(name, keys)

proc ydbDeleteTree*(name: string, keys: Subscripts): int =
  return ydb_delete_tree_db(name, keys)

proc ydbIncrement*(name: string, keys: Subscripts, increment: int = 1): int =
  let s = ydb_increment_db(name, keys, increment)
  try:
    result = parseInt(s)
  except:
    raise newException(YottaDbError, "Illegal Number. Tried to parseInt(" & s & ")")

when compileOption("threads"):
  proc ydbTxRun*[T: YDB_tp2fnptr_t](myTxnProc: T, param: auto, transid: string = ""): int =
    result = ydb_tp2_start(myTxnProc, param, transid)
else:
  proc ydbTxRun*(myTxnProc: ydb_tpfnptr_t, param: string, transid:string = ""): int =
    result = ydb_tp_start(myTxnProc, param, transid)

# ------------------ Iterators for Next/Previous Node -----------------
proc nextNode*(global: string, subscripts: var Subscripts): Subscripts =
  result = ydb_node_next_db(global, subscripts)
  

iterator nextNodeIter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    subscripts = ydb_node_next_db(global, subscripts)
    if len(subscripts) == 0: break
    yield subscripts

iterator previousNodeIter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    subscripts = ydb_node_previous_db(global, subscripts)
    if len(subscripts) == 0: break
    yield subscripts

# ------------------ Next/Previous subscripts -----------------
proc ydb_subscript_next*(name: string, keys: var Subscripts): int =
  result = ydb_subscript_next_db(name, keys)

proc ydb_subscript_previous*(name: string, keys: var Subscripts): int =
  result = ydb_subscript_previous_db(name, keys)

# ------------------ Iterators for Next/Previous Subscript-------------
iterator nextSubscriptNode*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    let rc = ydb_subscript_next(global, subscripts)
    if rc != 0 or len(subscripts) == 0: break
    yield subscripts

iterator previousSubscriptNode*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    let rc = ydb_subscript_previous(global, subscripts)
    if rc != 0 or len(subscripts) == 0: break
    yield subscripts

# ------------------ Locks -----------------
# Max of 35 variable names in one call
proc ydbLock*(timeout_nsec: culonglong, keys: seq[Subscripts] = @[]): int =
  return ydb_lock_db(timeout_nsec, keys)

# ------------------ YdbVar ----------------
proc newYdbVar*(global: string, subscripts: Subscripts, value: string = ""): YdbVar =
  if global.isEmptyOrWhitespace: raise newException(YottaDbError, "Empty 'global' param")

  result.global = global
  result.subscripts = subscripts
  result.value = value
  # Read from / or write to DB
  if value.isEmptyOrWhitespace:
    result.value = ydbGet(result.global, result.subscripts)
  else:
    ydbSet(result.global, result.subscripts, result.value)    

proc `$`*(v: YdbVar): string =
  ydbGet(v.global, v.subscripts)

proc `[]=`*(v: var YdbVar; val: string) =
  ydbSet(v.global, v.subscripts, val)
  v.value = val


# ------- Helpers
func keysToString*(subscript: Subscripts): string =
  for i, idx in subscript:
    try:
      let nmbr = parseInt(idx)
      result.add($nmbr)
    except ValueError:
      result.add("\"" & idx & "\"")
    if i < subscript.len - 1:
      result.add(",")

func keysToString*(global: string, subscript: Subscripts): string =
  result = global & "("
  result.add(keysToString(subscript))
  result.add(")")

proc subscriptsToValue*(global: string, subscript: Subscripts): string =
  var value: string
  try:
    value = ydbGet(global, subscript)
  except:
    discard
  if value.isEmptyOrWhitespace:
    result = keysToString(global, subscript)
  else:
    result = keysToString(global, subscript) & "=" & value


# Get the global variables from the ydb ^%GD utility
proc getGlobals*(): seq[string] =
    result = @[]
    var lines: seq[string]

    # Start a process with stdin/stdout redirection
    let ydb = findExe("ydb")
    let p = startProcess(
        ydb,
        args = @["-run ^%GD"],
        options = {poUsePath, poEchoCmd, poInteractive}
    )

    p.inputStream.write("\n") # Send "Enter" (newline) to the process
    p.inputStream.flush()

    var line = ""
    while p.outputStream.readLine(line):
        if line.startsWith("^"):
            lines.add(line)
    for line in lines:
        let names = line.split('^')
        for name in names:
            let s = name.strip()
            if not s.isEmptyOrWhitespace:
                result.add("^" & s)

    discard waitForExit(p)  # Wait until process finishes


proc getLockCountFromYottaDb*(): int =
  # Show real locks on db with 'lke show'
  var lockcnt = 0
  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if line.contains("Owned by"):
      inc(lockcnt)
  return lockcnt

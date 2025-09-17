import std/[strutils, os, osproc, streams]
import ydbtypes
import ydbimpl
import libydb

proc ydbMessage*(status: cint): string =
  ydbMessage_db(status)

proc ydb_set*(name: string, keys: Subscripts = @[]; value: string = "", tptoken:uint64 = 0) =
  ydb_set_db(name, keys, value, tptoken)

proc ydb_get*(name: string, keys: Subscripts = @[], tptoken:uint64 = 0): string =
  ydb_get_db(name, keys, tptoken)

proc ydb_data*(name: string, keys: Subscripts, tptoken:uint64 = 0): int =
  ydb_data_db(name, keys, tptoken)

proc ydb_delete_node*(name: string, keys: Subscripts, tptoken:uint64 = 0) =
  ydb_delete_node_db(name, keys, tptoken)

proc ydb_delete_tree*(name: string, keys: Subscripts, tptoken:uint64 = 0) =
  ydb_delete_tree_db(name, keys, tptoken)

proc ydb_delete_excl*(names: seq[string] = @[], tptoken:uint64 = 0) =
  # Default names to empty -> clear all local variables
  ydb_delete_excl_db(names, tptoken)

proc ydb_increment*(name: string, keys: Subscripts, increment: int = 1, tptoken:uint64 = 0): int =
  ydb_increment_db(name, keys, increment, tptoken)

proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string, transid: string = ""): int =
  result = ydb_tp2_start(myTxnProc, param, transid)

proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: string, transid:string = ""): int =
  result = ydb_tp_start(myTxnProc, param, transid)

# ------------------ Next/Previous Node -----------------
proc ydb_node_next*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): (int, Subscripts) =
  ydb_node_next_db(global, subscripts, tptoken)
  
proc ydb_node_previous*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): (int, Subscripts) =
  ydb_node_previous_db(global, subscripts, tptoken)

# ------------------ Iterators for Next/Previous Node -----------------
iterator ydb_node_next_iter*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): Subscripts =
  var i = -1
  var rc:int
  while i < len(subscripts):
    (rc, subscripts) = ydb_node_next_db(global, subscripts, tptoken)
    if rc != YDB_OK: break
    yield subscripts

iterator ydb_node_previous_iter*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): Subscripts =
  var i = -1
  var rc:int
  while i < len(subscripts):
    (rc, subscripts) = ydb_node_previous_db(global, subscripts, tptoken)
    if rc != YDB_OK: break
    yield subscripts

# ------------------ Next/Previous subscripts -----------------
proc ydb_subscript_next*(name: string, subs: var Subscripts): (int, Subscripts) =
  ydb_subscript_next_db(name, subs)

proc ydb_subscript_previous*(name: string, subs: var Subscripts): (int, Subscripts) =
  ydb_subscript_previous_db(name, subs)

# ------------------ Iterators for Next/Previous Subscript-------------
iterator ydb_subscript_next_iter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  var rc = 0
  while i < len(subscripts):
    (rc, subscripts) = ydb_subscript_next(global, subscripts)
    if rc != YDB_OK: break
    yield subscripts

iterator ydb_subscript_previous_iter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  var rc: int
  while i < len(subscripts):
    (rc, subscripts) = ydb_subscript_previous(global, subscripts)
    if rc != YDB_OK: break
    yield subscripts

# ------------------ Locks -----------------
# Max of 35 variable names in one call
proc ydb_lock*(timeout_nsec: culonglong, keys: seq[Subscripts]) =
  ydb_lock_db(timeout_nsec, keys)

# Only one variable name in one call
proc ydb_lock_incr*(timeout_nsec: culonglong, name: string, keys: Subscripts) =
  ydb_lock_incr_db(timeout_nsec, name, keys)

# Only one variable name in one call
proc ydb_lock_decr*(name: string, keys: Subscripts) =
  ydb_lock_decr_db(name, keys)

# ------------------ YdbVar ----------------
proc newYdbVar*(global: string="", subscripts: Subscripts, value: string = ""): YdbVar =
  if global.isEmptyOrWhitespace: raise newException(YdbDbError, "Empty 'global' param")

  result.global = global
  result.subscripts = subscripts
  result.value = value
  # Read from / or write to DB
  if value.isEmptyOrWhitespace:
    result.value = ydb_get(result.global, result.subscripts)
  else:
    ydb_set(result.global, result.subscripts, result.value)    

proc `$`*(v: YdbVar): string =
  ydb_get(v.global, v.subscripts)

proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.global, v.subscripts, val)
  v.value = val

# Call-In Interface
proc ydb_ci*(name: string) =
  ydb_ci_db(name)

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

func keysToString*(global: string, subscript: Subscripts, value:string): string =
  result = global & "("
  result.add(keysToString(subscript))
  result.add(")")
  if not value.isEmptyOrWhitespace:
    result.add("=" & value)

proc subscriptsToValue*(global: string, subscript: Subscripts): string =
  var value: string
  try:
    value = ydb_get(global, subscript)
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
        options = {poUsePath, poStdErrToStdOut, poInteractive}
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


proc getLocksFromYottaDb*(): seq[string] =
  # Show real locks on db with 'lke show'
  result = @[]

  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if line.contains("Owned by"):
      result.add(line)    

proc getLockCountFromYottaDb*(): int =
  getLocksFromYottaDb().len

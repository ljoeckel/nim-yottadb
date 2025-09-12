import std/[strutils, strformat, os, osproc, streams]
import yottadb_types
import yottadb_impl

proc ydbMessage*(status: cint): string =
  return ydbMessage_db(status)

proc ydbSet*(name: string, keys: Subscripts = @[]; value: string = "", tptoken:uint64 = 0) =
  if keys.len > 31:
    raise newException(YdbDbError, "Too many subscript levels. Valid [0..31])")
  else:
    ydb_set_db(name, keys, value, tptoken)

proc ydbGet*(name: string, keys: Subscripts = @[], tptoken:uint64 = 0): string =
  return ydb_get_db(name, keys, tptoken)

proc ydbData*(name: string, keys: Subscripts, tptoken:uint64 = 0): int =
  return ydb_data_db(name, keys, tptoken)

proc ydbDeleteNode*(name: string, keys: Subscripts, tptoken:uint64 = 0) =
  ydb_delete_node_db(name, keys, tptoken)

proc ydbDeleteTree*(name: string, keys: Subscripts, tptoken:uint64 = 0) =
  ydb_delete_tree_db(name, keys, tptoken)

proc ydbDeleteExcl*(names: seq[string] = @[], tptoken:uint64 = 0) =
  if names.len > 35: raise newException(YdbDbError, fmt"Too many names. Only {YDB_MAX_NAMES} are allowed")
  # Default names to empty -> clear all local variables
  ydb_delete_excl_db(names, tptoken)


proc ydbIncrement*(name: string, keys: Subscripts, increment: int = 1, tptoken:uint64 = 0): int =
  let s = ydb_increment_db(name, keys, increment, tptoken)
  try:
    result = parseInt(s)
  except:
    raise newException(YdbDbError, "Illegal Number. Tried to parseInt(" & s & ")")

proc ydbTxRunMT*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string, transid: string = ""): int =
  result = ydb_tp2_start(myTxnProc, param, transid)

proc ydbTxRun*(myTxnProc: ydb_tpfnptr_t, param: string, transid:string = ""): int =
  result = ydb_tp_start(myTxnProc, param, transid)

# ------------------ Next/Previous Node -----------------
proc nextNode*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): (int, Subscripts) =
  return ydb_node_next_db(global, subscripts, tptoken)
  
proc prevNode*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): (int, Subscripts) =
  return ydb_node_previous_db(global, subscripts, tptoken)

# ------------------ Iterators for Next/Previous Node -----------------
iterator nextNodeIter*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): Subscripts =
  var i = -1
  var rc:int
  while i < len(subscripts):
    (rc, subscripts) = ydb_node_next_db(global, subscripts, tptoken)
    if rc != YDB_OK: break
    yield subscripts

iterator previousNodeIter*(global: string, subscripts: var Subscripts, tptoken:uint64 = 0): Subscripts =
  var i = -1
  var rc:int
  while i < len(subscripts):
    (rc, subscripts) = ydb_node_previous_db(global, subscripts, tptoken)
    if rc != YDB_OK: break
    yield subscripts

# ------------------ Next/Previous subscripts -----------------
proc ydb_subscript_next*(name: string, subs: var Subscripts): (int, Subscripts) =
  return ydb_subscript_next_db(name, subs)

proc ydb_subscript_previous*(name: string, subs: var Subscripts): (int, Subscripts) =
  return ydb_subscript_previous_db(name, subs)

# ------------------ Iterators for Next/Previous Subscript-------------
iterator nextSubscriptIter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  var rc = 0
  while i < len(subscripts):
    (rc, subscripts) = ydb_subscript_next(global, subscripts)
    if rc != YDB_OK: break
    yield subscripts

iterator previousSubscriptIter*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  var rc: int
  while i < len(subscripts):
    (rc, subscripts) = ydb_subscript_previous(global, subscripts)
    if rc != YDB_OK: break
    yield subscripts

# ------------------ Locks -----------------
# Max of 35 variable names in one call
proc ydbLock*(timeout_nsec: culonglong, keys: seq[Subscripts] = @[]) =
  ydb_lock_db(timeout_nsec, keys)

# Only one variable name in one call
proc ydbLockIncrement*(timeout_nsec: culonglong, name: string, keys: Subscripts): int =
  return ydb_lock_incr_db(timeout_nsec, name, keys)

# Only one variable name in one call
proc ydbLockDecrement*(name: string, keys: Subscripts): int =
  return ydb_lock_decr_db(name, keys)

# ------------------ YdbVar ----------------
proc newYdbVar*(global: string, subscripts: Subscripts, value: string = ""): YdbVar =
  if global.isEmptyOrWhitespace: raise newException(YdbDbError, "Empty 'global' param")

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

# Call-In Interface
proc ydbCI*(name: string) =
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


proc getLocksFromYottaDb*(): seq[string] =
  # Show real locks on db with 'lke show'
  result = @[]

  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if line.contains("Owned by"):
      result.add(line)    

proc getLockCountFromYottaDb*(): int =
  return getLocksFromYottaDb().len

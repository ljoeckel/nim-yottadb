import std/[strutils, os, osproc, streams]
import pegs
import ydbtypes
import ydbimpl
import libydb
import bingo

type ValueType = enum 
  UNKNOWN,
  ALPHA,
  INTEGER,
  FLOAT

proc ydbMessage*(status: cint): string =
  ydbMessage_db(status)


proc ydb_set*(name: string, keys: Subscripts = @[]; value: string = "", tptoken: uint64 = 0) =
  ydb_set_db(name, keys, value, tptoken)


proc ydb_get*(name: string, keys: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_get_db(name, keys, tptoken)

proc ydb_getblob*(name: string, keys: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_getblob_db(name, keys, tptoken)


proc ydb_data*(name: string, keys: Subscripts, tptoken: uint64 = 0): int =
  ydb_data_db(name, keys, tptoken)


proc ydb_delete_node*(name: string, keys: Subscripts, tptoken: uint64 = 0) =
  ydb_delete_node_db(name, keys, tptoken)


proc ydb_delete_tree*(name: string, keys: Subscripts, tptoken: uint64 = 0) =
  ydb_delete_tree_db(name, keys, tptoken)


proc ydb_delete_excl*(names: seq[string] = @[], tptoken: uint64 = 0) =
  # Default names to empty -> clear all local variables
  ydb_delete_excl_db(names, tptoken)


proc ydb_increment*(name: string, keys: Subscripts, increment: int = 1, tptoken: uint64 = 0): int =
  ydb_increment_db(name, keys, increment, tptoken)


proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string, transid: string = ""): int =
  result = ydb_tp2_start(myTxnProc, param, transid)


proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: string, transid:string = ""): int =
  result = ydb_tp_start(myTxnProc, param, transid)


# ------------------ Next/Previous Node -----------------

proc ydb_node_next*(global: string, subscripts: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_node_next_db(global, subscripts, tptoken)
  
proc ydb_node_previous*(global: string, subscripts: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_node_previous_db(global, subscripts, tptoken)

# ------------------ Next/Previous subscripts -----------------

proc ydb_subscript_next*(name: string, subs: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_subscript_next_db(name, subs, tptoken)

proc ydb_subscript_previous*(name: string, subs: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_subscript_previous_db(name, subs, tptoken)

# ------------------ Iterators for Next/Previous Node -----------------

iterator ydb_node_next_iter*(global: string, start: Subscripts = @[], tptoken: uint64 = 0): Subscripts =
  var (rc, subs) = ydb_node_next_db(global, start, tptoken)
  while rc == YDB_OK:
    yield subs
    (rc, subs) = ydb_node_next_db(global, subs, tptoken)

iterator ydb_node_previous_iter*(global: string, start: Subscripts = @[], tptoken: uint64 = 0): Subscripts =
  var (rc, subs) = ydb_node_previous_db(global, start, tptoken)
  while rc == YDB_OK:
    yield subs
    (rc, subs) = ydb_node_previous_db(global, subs, tptoken)

# ------------------ Iterators for Next/Previous Subscript-------------

iterator ydb_subscript_next_iter*(global: string, start: Subscripts = @[], tptoken: uint64 = 0): Subscripts =
  var (rc, subs) = ydb_subscript_next(global, start, tptoken)
  while rc == YDB_OK:
    yield subs
    (rc, subs) = ydb_subscript_next(global, subs, tptoken)

iterator ydb_subscript_previous_iter*(global: string, start: Subscripts = @[], tptoken: uint64 = 0): Subscripts =
  var (rc, subs) = ydb_subscript_previous(global, start, tptoken)
  while rc == YDB_OK:
    yield subs
    (rc, subs) = ydb_subscript_previous(global, subs, tptoken)


# ------------------ Locks -----------------

# Max of 35 variable names in one call
proc ydb_lock*(timeout_nsec: int, keys: seq[Subscripts], tptoken: uint64 = 0) =
  ydb_lock_db(timeout_nsec, keys, tptoken)


# Only one variable name in one call
proc ydb_lock_incr*(timeout_nsec: int, name: string, keys: Subscripts, tptoken: uint64 = 0) =
  ydb_lock_incr_db(timeout_nsec, name, keys, tptoken)


# Only one variable name in one call
proc ydb_lock_decr*(name: string, keys: Subscripts, tptoken: uint64 = 0) =
  ydb_lock_decr_db(name, keys, tptoken)


proc str2zwr*(name: string, tptoken: uint64 = 0): string =
  ydb_str2zwr_db(name, tptoken)

proc zwr2str*(name: string, tptoken: uint64 = 0): string =
  ydb_zwr2str_db(name, tptoken)

# ------------------ YdbVar ----------------

proc newYdbVar*(global: string="", subscripts: Subscripts, value: string = ""): YdbVar =
  if global.isEmptyOrWhitespace: raise newException(YdbError, "Empty 'global' param")

  result.name = global
  result.subscripts = subscripts
  result.value = value
  # Read from / or write to DB
  if value.isEmptyOrWhitespace:
    result.value = ydb_get(result.name, result.subscripts)
  else:
    ydb_set(result.name, result.subscripts, result.value)    


proc `$`*(v: YdbVar): string =
  ydb_get(v.name, v.subscripts)


proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.name, v.subscripts, val)
  v.value = val


# Call-In Interface
proc ydb_ci*(name: string, tptoken: uint64 = 0) =
  ydb_ci_db(name, tptoken)


# ------- Binary Object Stream ----------------

proc serialize[T](obj: T): string =
  let fs = newStringStream()
  defer:
      fs.close()
  storeBin(fs, obj)
  fs.setPosition(0)
  return fs.readAll()


proc serializeToDb*[T](obj: T, idargs: varargs[string], tptoken: uint64 = 0) =
  # Serialize a Object to the Database in binary form
  # let data = Responder(id: 4711, name: "John Smith", gender: male, occupation: "student", age: 18,
  #           siblings: @[Sibling(sex: female, birthYear: 1991, relation: biological, alive: true),
  #           Sibling(sex: male, birthYear: 1989, relation: step, alive: true)])
  # serializeToDb(data, $id)

  let dta = serialize(obj)

  let global = "^" & $typeof(obj)
  var subs: Subscripts
  for arg in idargs:
    subs.add(arg)
  ydb_set(global, subs, dta, tptoken)


proc deserializeFromDb*[T](idargs: varargs[string], tptoken: uint64 = 0): T =
  # Deserialize a object T from the database
  # let responder = deserializeFromDb[Responder]($id)

  let global = "^" & $typeof(T)
  var subs: Subscripts
  for arg in idargs:
    subs.add(arg)

  let bindata = ydb_getblob_db(global, subs, tptoken)
  let fs = newStringStream(bindata)
  defer:
      fs.close()
  loadBin(fs, result)



# ------- Helpers --------
func classify(input: string): ValueType =
  var numeric: bool
  var numeric_float: bool
  for c in input:
    numeric = c in {'0','1','2','3','4','5','6','7','8','9','.'}
    if c == '.': numeric_float = true
  if numeric_float and numeric: return ValueType.FLOAT
  elif numeric: return ValueType.INTEGER
  else: return ValueType.ALPHA


proc keysToString*(subscript: Subscripts): string =
  for i, s in subscript:
    let valueType = classify(s)
    case valueType
    of INTEGER:
      let nmbr = parseInt(s)
      result.add($nmbr)
    of FLOAT:
      let nmbr = parseFloat(s)
      result.add($nmbr)
    else:
      result.add(s)

    if i < subscript.len - 1:
      result.add(",")


proc keysToString*(global: string, subscript: Subscripts): string =
  result = global & "("
  result.add(keysToString(subscript))
  result.add(")")


proc keysToString*(global: string, subscript: Subscripts, value:string): string =
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


proc listGlobal*(global: string) =
  # List all globals with its value
  var (rc, sub) = ydb_node_next(global, @[])
  while rc == YDB_OK:
    #let value = ydb_get(global, sub)
    echo subscriptsToValue(global, sub)
    (rc, sub)= ydb_node_next(global, sub)


proc deleteGlobal*(global: string) =
  var (rc, subs) = ydb_node_next(global)
  while rc == YDB_OK:
    ydb_delete_node(global, subs)
    (rc, subs) = ydb_node_next(global, subs)
  # test if really empty
  (rc, subs) = ydb_node_next(global, @[])
  if rc != YDB_ERR_NODEEND:
    raise newException(YdbError, "Data exists after deleteGlobal '" & global & "' but should not.")



proc getGlobals*(): seq[string] =
  # Get the global variables from the ydb ^%GD utility
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


proc getLocksFromYottaDb*(all: bool = false): seq[string] =
  # Show real locks on db with 'lke show'
  let pid = ydb_get("$JOB")
  result = @[]

  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if all and line.contains("Owned by"):
      result.add(line)    
    elif line.contains("Owned by") and line.contains(pid):
      result.add(line)    

proc getLockCountFromYottaDb*(all: bool = false): int =
  getLocksFromYottaDb(all).len


proc isLocked*(lock: string): bool =
  for line in getLocksFromYottaDb():
    if line.contains("^LOCKS(") and line.contains(lock):
      return true
  false


proc isLocked*(lock: int | float): bool =
  isLocked($lock)

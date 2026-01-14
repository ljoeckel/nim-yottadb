import std/[strutils, os, osproc, streams]
import pegs
import ydbtypes
import ydbimpl
import libydb
import bingo

func keysToString*(subs: seq[string]): string {.inline.} =
  if subs.len == 0: return ""
  let last = subs.len - 1
  for i, s in subs:
    result.add(s)
    if i < last: result.add(",")

func keysToString*(global: string, subscript: Subscripts): string {.inline.} =
  result = global & "("
  result.add(keysToString(subscript))
  result.add(")")

func keysToString*(global: string, subscript: Subscripts, value:string): string {.inline.} =
  result = global & "("
  result.add(keysToString(subscript))
  result.add(")")
  if not value.isEmptyOrWhitespace:
    result.add("=" & value)

func stringToSeq*(s: string): Subscripts =
    # Convert ^Global(1,2,3) -> @["1", "2", "3"]
    var str: string = newString(s.len)
    var idx = 0
    for c in s:
        if c == ',':
            str[idx] = c
            str.setLen(idx)
            result.add(str)
            str.setLen(str.capacity)
            idx = 0
            continue
        elif c in {'@', '[', ']', '\\', ' ', '"'} :            
            continue
        else:
            str[idx] = c
            inc idx

    if idx > 0:
        str.setLen(idx)
        result.add(str)

func stringToSeq*(subs: Subscripts): Subscripts =
    # seq @["@[\"4712\"]"] -> @["4712"]
    for sub in subs:
        result.add(stringToSeq(sub))


proc ydbMessage*(status: cint, tptoken: uint64 = 0): string =
  ydbMessage_db(status, tptoken)


proc ydb_set*(name: string, keys: Subscripts = @[]; value: string = "", tptoken: uint64 = 0) =
  ydb_set_db(name, keys, value, tptoken)


proc ydb_get*(name: string, keys: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_get_db(name, keys, tptoken)

proc ydb_getbinary*(name: string, keys: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_getbinary_db(name, keys, tptoken)


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


proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string = "", transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)

proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: int, transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)


proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: string = "", transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)

proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: int, transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)


# ------------------ Next/Previous Node -----------------

proc ydb_node_next*(global: string, subscripts: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_node_next_db(global, subscripts, tptoken)
  
proc ydb_node_previous*(global: string, subscripts: Subscripts = @[], tptoken: uint64 = 0): (int, Subscripts) =
  ydb_node_previous_db(global, subscripts, tptoken)

# ------------------ Next/Previous subscripts -----------------

proc ydb_subscript_next*(name: string, subs: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_subscript_next_db(name, subs, tptoken)

proc ydb_subscript_previous*(name: string, subs: Subscripts = @[], tptoken: uint64 = 0): string =
  ydb_subscript_previous_db(name, subs, tptoken)


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


# Call-In Interface
proc ydb_ci*(name: string, tptoken: uint64 = 0) =
  ydb_ci_db(name, tptoken)

# ------------------ YdbVar ----------------

proc newYdbVar*(global: string="", subscripts: Subscripts, value: string = "", tptoken: uint64 = 0): YdbVar =
  if global.isEmptyOrWhitespace: raise newException(YdbError, "Empty 'global' param")

  result.name = global
  result.subscripts = subscripts
  result.value = value
  result.tptoken = tptoken
  # Read from / or write to DB
  if value.isEmptyOrWhitespace:
    result.value = ydb_get(result.name, result.subscripts, result.tptoken)
  else:
    ydb_set(result.name, result.subscripts, result.value, result.tptoken)

proc `$`*(v: YdbVar): string =
  ydb_get(v.name, v.subscripts, v.tptoken)

proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.name, v.subscripts, val, v.tptoken)
  v.value = val


# ------- Binary Object Stream ----------------

proc serialize[T](obj: T): string =
  let fs = newStringStream()
  defer:
      fs.close()
  storeBin(fs, obj)
  fs.setPosition(0)
  return fs.readAll()

proc deserializeFromDb*[T](idargs: varargs[string], tptoken: uint64 = 0): T =
  # Deserialize a object T from the database
  # let responder = deserializeFromDb[Responder]($id)

  let global = "^" & $typeof(T)
  var subs: Subscripts
  for arg in idargs:
    subs.add(arg)

  let bindata = ydb_getbinary_db(global, subs, tptoken)
  let fs = newStringStream(bindata)
  defer:
      fs.close()
  loadBin(fs, result)

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


proc deleteGlobal*(global: string) =
  ydb_delete_tree(global, @[])
  # test if really empty
  var (rc, subs) = ydb_node_next(global, @[])
  if rc != YDB_ERR_NODEEND:
    raise newException(YdbError, "Data exists after deleteGlobal '" & global & "' but should not. data=" & $subs)


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

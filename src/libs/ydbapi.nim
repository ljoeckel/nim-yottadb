import std/[strutils]
import ydbtypes
import ydbimpl
import libydb

proc keysToString*(global: string, subs: Subscripts): string {.inline.} =
  result = global
  result.add("(")
  result.add(subs.join(","))
  result.add(")")

proc keysToString*(global: string, subs: Subscripts, value:string): string {.inline.} =
  result = global
  result.add("(")
  result.add(subs.join(","))
  result.add(")")
  if value.len > 0:
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
    if value.len <= YDB_MAX_BUF_SIZE:
        ydb_set_db(name, keys, value, tptoken)
    else:
        ydb_set_binary_db(name, keys, value, tptoken)


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


proc ydb_increment*(name: string, keys: Subscripts, Increment: int = 1, tptoken: uint64 = 0): int =
  ydb_increment_db(name, keys, Increment, tptoken)


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
  if global.len == 0: raise newException(YdbError, "Empty 'global' param")

  result.name = global
  result.subscripts = subscripts
  result.value = value
  result.tptoken = tptoken
  # Read from / or write to DB
  if value.len == 0:
    result.value = ydb_get(result.name, result.subscripts, result.tptoken)
  else:
    ydb_set(result.name, result.subscripts, result.value, result.tptoken)

proc `$`*(v: YdbVar): string =
  ydb_get(v.name, v.subscripts, v.tptoken)

proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.name, v.subscripts, val, v.tptoken)
  v.value = val



proc deleteGlobal*(global: string) =
  ydb_delete_tree(global, @[])
  # test if really empty
  var (rc, subs) = ydb_node_next(global, @[])
  if rc != YDB_ERR_NODEEND:
    raise newException(YdbError, "Data exists after deleteGlobal '" & global & "' but should not. Data=" & $subs)


proc subscriptsToValue*(global: string, subscript: Subscripts): string =
  var value: string
  try:
    value = ydb_get(global, subscript)
  except:
    discard
  if value.len == 0:
    result = keysToString(global, subscript)
  else:
    result = keysToString(global, subscript) & "=" & value

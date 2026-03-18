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


proc ydbMessage*(status: cint): string =
  ydbMessage_db(status)


proc ydb_set*(name: string, keys: Subscripts = @[]; value: string = "") =
    if value.len <= YDB_MAX_BUF_SIZE:
        ydb_set_db(name, keys, value)
    else:
        ydb_set_binary_db(name, keys, value)


proc ydb_get*(name: string, keys: Subscripts = @[]): string =
  ydb_get_db(name, keys)

proc ydb_getbinary*(name: string, keys: Subscripts = @[]): string =
  ydb_getbinary_db(name, keys)


proc ydb_data*(name: string, keys: Subscripts): int =
  ydb_data_db(name, keys)


proc ydb_delete_node*(name: string, keys: Subscripts) =
  ydb_delete_node_db(name, keys)


proc ydb_delete_tree*(name: string, keys: Subscripts) =
  ydb_delete_tree_db(name, keys)


proc ydb_delete_excl*(names: seq[string] = @[]) =
  # Default names to empty -> clear all local variables
  ydb_delete_excl_db(names)


proc ydb_increment*(name: string, keys: Subscripts, Increment: int = 1): int =
  ydb_increment_db(name, keys, Increment)


proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: string = "", transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)

proc ydb_tp_mt*[T: YDB_tp2fnptr_t](myTxnProc: T, param: int, transid: string = ""): int =
  ydb_tp2_start(myTxnProc, param, transid)


proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: string = "", transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)

proc ydb_tp*(myTxnProc: ydb_tpfnptr_t, param: int, transid: string = ""): int =
  ydb_tp_start(myTxnProc, param, transid)


# ------------------ Next/Previous Node -----------------

proc ydb_node_next*(global: string, subscripts: Subscripts = @[]): (int, Subscripts) =
  ydb_node_next_db(global, subscripts)
  
proc ydb_node_previous*(global: string, subscripts: Subscripts = @[]): (int, Subscripts) =
  ydb_node_previous_db(global, subscripts)

# ------------------ Next/Previous subscripts -----------------

proc ydb_subscript_next*(name: string, subs: Subscripts = @[]): string =
  ydb_subscript_next_db(name, subs)

proc ydb_subscript_previous*(name: string, subs: Subscripts = @[]): string =
  ydb_subscript_previous_db(name, subs)


# ------------------ Locks -----------------

# Max of 35 variable names in one call
proc ydb_lock*(timeout_nsec: int, keys: seq[Subscripts]) =
  ydb_lock_db(timeout_nsec, keys)


# Only one variable name in one call
proc ydb_lock_incr*(timeout_nsec: int, name: string, keys: Subscripts) =
  ydb_lock_incr_db(timeout_nsec, name, keys)


# Only one variable name in one call
proc ydb_lock_decr*(name: string, keys: Subscripts) =
  ydb_lock_decr_db(name, keys)


proc str2zwr*(name: string): string =
  ydb_str2zwr_db(name)

proc zwr2str*(name: string): string =
  ydb_zwr2str_db(name)


# Call-In Interface
proc ydb_ci*(name: string) =
  ydb_ci_db(name)

# ------------------ YdbVar ----------------

proc newYdbVar*(global: string="", subscripts: Subscripts, value: string = ""): YdbVar =
  if global.len == 0: raise newException(YdbError, "Empty 'global' param")

  result.name = global
  result.subscripts = subscripts
  result.value = value
  # Read from / or write to DB
  if value.len == 0:
    result.value = ydb_get(result.name, result.subscripts)
  else:
    ydb_set(result.name, result.subscripts, result.value)

proc `$`*(v: YdbVar): string =
  ydb_get(v.name, v.subscripts)

proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.name, v.subscripts, val)
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


proc trimString*(s: string): string =
  if s.len >= 2 and s[0] == '"' and s[^1] == '"':
    s[1..^2]
  else:
    s

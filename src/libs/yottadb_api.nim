import std/strutils 

import yottadb_impl
import yottadb_types
export yottadb_types

proc ydbMessage*(status: cint): string =
  return ydbMessage_db(status)

proc ydbSet*(name: string, keys: Subscripts = @[], value: string = "") =
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

# ------------------ Next/Previous items -----------------

iterator nextItem*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    subscripts = ydb_node_next_db(global, subscripts)
    if len(subscripts) == 0: break
    yield subscripts

iterator previousItem*(global: string, subscripts: var Subscripts): Subscripts =
  var i = -1
  while i < len(subscripts):
    subscripts = ydb_node_previous_db(global, subscripts)
    if len(subscripts) == 0: break
    yield subscripts

# ------------------ Next/Previous subscripts -----------------
proc ydb_subscript_next*(name: string, keys: var Subscripts): int =
  return ydb_subscript_next_db(name, keys)

proc ydb_subscript_previous*(name: string, keys: var Subscripts): int =
  return ydb_subscript_previous_db(name, keys)

# ------------------ Locks -----------------
# Max of 35 variable names in one call
proc ydbLock*(timeout_nsec: culonglong, keys: seq[Subscripts] = @[]): int =
  return ydb_lock_db(timeout_nsec, keys)

# ------------------ YdbVar ----------------
proc newYdbVar*(global: string, subscripts: Subscripts, value: string = ""): YdbVar =
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



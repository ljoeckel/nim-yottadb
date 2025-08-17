import std/strutils 

import yottadb_impl
import yottadb_types
export yottadb_types

proc ydbMessage*(status: cint): string =
  return ydbMessage_db(status)

proc ydbSet*(name: string, keys: seq[string] = @[], value: string = "") =
  ydb_set_db(name, keys, value)

proc ydbGet*(name: string, keys: seq[string] = @[]): string =
  return ydb_get_db(name, keys)

proc ydbData*(name: string, keys: seq[string]): int =
  return ydb_data_db(name, keys)

proc ydbDeleteNode*(name: string, keys: seq[string]): cint =
  return ydb_delete_node_db(name, keys)

proc ydbDeleteTree*(name: string, keys: seq[string]): cint =
  return ydb_delete_tree_db(name, keys)

proc ydbIncrement*(name: string, keys: seq[string], increment: int = 1): int =
  let s = ydb_increment_db(name, keys, increment)
  try:
    result = parseInt(s)
  except:
    raise newException(YottaDbError, "Illegal Number. Tried to parseInt(" & s & ")")

proc ydbNextNode*(name: string, keys: seq[string]): (int, seq[string]) =
  return ydb_node_next_db(name, keys)

proc ydbPreviousNode*(name: string, keys: seq[string]): (int, seq[string]) =
  return ydb_node_previous_db(name, keys)

proc ydb_subscript_next*(name: string, keys: var seq[string]): int =
  return ydb_subscript_next_db(name, keys)

proc ydb_subscript_previous*(name: string, keys: var seq[string]): int =
  return ydb_subscript_previous_db(name, keys)

# Max of 35 variable names in one call
proc ydbLock*(timeout_nsec: culonglong, keys: seq[seq[string]] = @[]): int =
  return ydb_lock_db(timeout_nsec, keys)

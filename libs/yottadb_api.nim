import yottadb_impl

import yottadb_types
export yottadb_types

proc ydbmsg*(status: cint): string =
  return ydbmsg_db(status)

proc ydb_set*(name: string, keys: seq[string] = @[], value: string = "") =
  ydb_set_db(name, keys, value)

proc ydb_get*(name: string, keys: seq[string] = @[]): string =
  return ydb_get_db(name, keys)

proc ydb_data*(name: string, keys: seq[string]): int =
  return ydb_data_db(name, keys)

proc ydb_delete_node*(name: string, keys: seq[string]): cint =
  return ydb_delete_node_db(name, keys)

proc ydb_delete_tree*(name: string, keys: seq[string]): cint =
  return ydb_delete_tree_db(name, keys)

proc ydb_increment*(name: string, keys: seq[string], increment: int): string =
  return ydb_increment_db(name, keys, increment)

proc ydb_node_next*(name: string, keys: seq[string]): (int, seq[string]) =
  return ydb_node_next_db(name, keys)

proc ydb_node_previous*(name: string, keys: seq[string]): (int, seq[string]) =
  return ydb_node_previous_db(name, keys)

proc ydb_subscript_next*(name: string, keys: var seq[string]): int =
  return ydb_subscript_next_db(name, keys)

proc ydb_subscript_previous*(name: string, keys: var seq[string]): int =
  return ydb_subscript_previous_db(name, keys)

# Max of 35 variable names in one call
proc ydb_lock*(timeout_nsec: culonglong, keys: seq[seq[string]]): cint =
  return ydb_lock_db(timeout_nsec, keys)

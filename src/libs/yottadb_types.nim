import libyottadb

type
  # Helper type for Multi-Threaded transaction processing
  # TODO: solve import problem with ydb_tp2fnptr_t
  YDB_tp2fnptr_t* = proc (a0: uint64, a1: ptr struct_ydb_buffer_t, a2: pointer): cint {.cdecl, gcsafe.}
  
  Direction* = enum
    Next,
    Previous

  YottaDbError* = object of CatchableError

  Subscripts* = seq[string]

  YdbVar* = object 
    global*: string
    subscripts*: Subscripts
    value*: string

const
  YDB_INT_MAX* = ((int)0x7fffffff)
  YDB_TP_RESTART* = (YDB_INT_MAX - 1)
  YDB_TP_ROLLBACK* = (YDB_INT_MAX - 2)
  YDB_ERR_TPTIMEOUT* = -150377322
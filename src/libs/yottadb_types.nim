import libyottadb

const
    YDB_OK* = 0


type
  # Helper type for Multi-Threaded transaction processing
  YDB_tp2fnptr_t* = proc (tptoken: uint64, buff: ptr struct_ydb_buffer_t, param: pointer): cint {.cdecl, gcsafe.}
  
  Direction* = enum
    Next,
    Previous

  YdbData* = enum 
    NO_DATA_NO_SUBTREE = 0,
    DATA_NO_SUBTREE = 1,
    x2 = 2,
    x3 = 3,
    x4 = 4,
    x5 = 5,
    x6 = 6,
    x7 = 7,
    x8 = 8,
    x9 = 9,
    NO_DATA_WITH_SUBTREE = 10,
    DATA_AND_SUBTREE = 11

  YdbDbError* = object of CatchableError

  Subscripts* = seq[string]

  YdbVar* = object 
    global*: string
    subscripts*: Subscripts
    value*: string

const
  YDB_TP_RESTART* = - 1
  YDB_TP_ROLLBACK* = - 2
  #YDB_ERR_TPTIMEOUT* = -150377322
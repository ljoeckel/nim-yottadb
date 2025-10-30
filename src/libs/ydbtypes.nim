import libydb

const
    YDB_OK* = 0
    YDB_MAX_ERRORMSG* = 1024
    YDB_MAX_NAMES* = 35
    YDB_MAX_SUBS* = 31

    YDB_ERR_NODEEND* = -151027922
    YDB_ERR_NUMOFLOW* = -150373506
    YDB_ERR_GVUNDEF* = -150372994
    YDB_ERR_TPTIMEOUT* = -150377322

    YDB_INT_MAX =  0x7fffffff
    YDB_TP_RESTART* = (YDB_INT_MAX - 1)
    YDB_TP_ROLLBACK* = (YDB_INT_MAX - 2)
    YDB_NOTOK* = (YDB_INT_MAX - 3)
    YDB_LOCK_TIMEOUT* = (YDB_INT_MAX - 4) 


    YDB_DATA_UNDEF* = 0 # Node is undefined
    YDB_DATA_VALUE_NODESC* = 1 # Node has a value but no descendants
    YDB_DATA_NOVALUE_DESC* = 10 # Node has no value but has descendants
    YDB_DATA_VALUE_DESC* = 11 # Node has both value and descendants

type
  # Helper type for Multi-Threaded transaction processing
  YDB_tp2fnptr_t* = proc (tptoken: uint64, buff: ptr struct_ydb_buffer_t, param: pointer): cint {.cdecl, gcsafe.}
  
  Direction* = enum
    Next,
    Previous

  YdbError* = object of CatchableError
  TpRestart* = object of CatchableError
  TpRollback* = object of CatchableError

  Subscripts* = seq[string]

  YdbVar* = object 
    prefix*: string
    name*: string
    subscripts*: Subscripts
    value*: string
    typdesc*: string

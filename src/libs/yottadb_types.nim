type 
  Direction* = enum
    Next,
    Previous

  YottaDbError* = object of CatchableError

  Subscripts* = seq[string]

type 
  YdbVar* = object 
    global*: string
    subscripts*: Subscripts
    value*: string

const
  YDB_INT_MAX* = ((int)0x7fffffff)
  YDB_TP_RESTART* = (YDB_INT_MAX - 1)
  YDB_TP_ROLLBACK* = (YDB_INT_MAX - 2)
  YDB_ERR_TPTIMEOUT* = -150377322
  
  YDB_OK* = 0 


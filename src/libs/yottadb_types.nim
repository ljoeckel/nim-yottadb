type 
  Direction* = enum
    Next,
    Previous

  YottaDbError* = object of CatchableError

  Subscripts* = seq[string]

const
   YDB_OK* = 0 

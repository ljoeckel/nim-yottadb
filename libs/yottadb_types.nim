type 
  Direction* = enum
    Next,
    Previous

  YottaDbError* = object of CatchableError

const
   YDB_OK* = 0 

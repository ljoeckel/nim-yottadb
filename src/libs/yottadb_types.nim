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
   YDB_OK* = 0 

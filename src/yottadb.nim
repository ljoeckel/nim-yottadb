import libs/libydb
import libs/ydbtypes
import libs/ydbimpl
import libs/dsl
import libs/bingoser

export libydb
export ydbtypes
export ydbimpl
export dsl
export bingoser


# ------------------ YdbVar ----------------

proc newYdbVar*(global: string="", subscripts: Subscripts, value: string = ""): YdbVar =
  if global.len == 0: raise newException(YdbError, "Empty 'global' param")

  result.name = global
  result.subscripts = subscripts
  result.value = value
  # Read from / or write to DB
  if value.len == 0:
    result.value = ydb_get(result.name, result.subscripts)
  else:
    ydb_set(result.name, result.subscripts, result.value)

proc `$`*(v: YdbVar): string =
  ydb_get(v.name, v.subscripts)

proc `[]=`*(v: var YdbVar; val: string) =
  ydb_set(v.name, v.subscripts, val)
  v.value = val

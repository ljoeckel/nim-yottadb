import libydb

const
    YDB_OK* = 0
    YDB_MAX_ERRORMSG* = 1024
    YDB_MAX_NAMES* = 35
    YDB_MAX_SUBS* = 31
    YDB_MAX_BUF_SIZE* = 1024*1024

    YDB_ERR_NODEEND* = -151027922
    YDB_ERR_NUMOFLOW* = -150373506
    YDB_ERR_GVUNDEF* = -150372994
    YDB_ERR_TPTIMEOUT* = -150377322
    YDB_ERR_INVSTRLEN* = -150375522

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
    value*: string
    typdesc*: string
    subscripts*: Subscripts

  YdbKey* = object
    ## Reusable key: variable name plus subscripts, without per-call allocation.
    ##
    ## `name` and `subs[i]` are *buffers*: `string.len` is the allocated
    ## capacity, the number of valid bytes is tracked in `nameUsed` and
    ## `subUsed[i]`. A `YdbKey` can thus be modified in place and handed to
    ## YottaDB again and again without any heap allocation. Traversal results
    ## (`ydb_node_next` / `ydb_subscript_next`) are written directly into it.
    ##
    ## Use `var` variables together with the `ydb_*` overloads:
    ##
    ## .. code-block:: nim
    ##   var key = initYdbKey("^orders", "customer", 42)
    ##   ydb_set(key, "open")
    ##   echo ydb_get(key)
    ##
    ## The fields are public for the `ydb_*` implementation; use the accessors
    ## (`setName`, `setSub`, `addSub`, `subCount`, ...) rather than setting them
    ## directly.
    name*: string
    key*: string # last $order key
    nameUsed*: int
    subs*: array[YDB_MAX_SUBS, string]
    subUsed*: array[YDB_MAX_SUBS, int]
    nsubs*: int
    cbufs*: array[YDB_MAX_SUBS, ydb_buffer_t]
    ## Cached `ydb_buffer_t` views on `subs`/`subUsed`. Maintained on every
    ## mutation so that no per-call conversion is needed.


const
  YDB_KEY_INITIAL_CAP* = 32
  ## Initial byte capacity of the name/subscript buffers of a `YdbKey`.


proc rebuildCbufs(k: var YdbKey) =
  ## Recreate the cached `ydb_buffer_t` views after the buffers moved.
  for i in 0 ..< YDB_MAX_SUBS:
    let cap = k.subs[i].len
    let used = if i < k.nsubs: k.subUsed[i] else: 0
    k.cbufs[i] = ydb_buffer_t(
      len_alloc: cap.uint32,
      len_used: used.uint32,
      buf_addr: (if cap == 0: nil else: cast[cstring](unsafeAddr k.subs[i][0])))

proc `=copy`*(dest: var YdbKey, src: YdbKey) =
  ## Copy hook: a plain (bitwise) copy would leave `cbufs` pointing into the
  ## source key's buffers, so they are rebuilt for the new copy.
  if dest.addr == src.addr: return
  dest.name = src.name
  dest.nameUsed = src.nameUsed
  for i in 0 ..< YDB_MAX_SUBS:
    dest.subs[i] = src.subs[i]
    dest.subUsed[i] = src.subUsed[i]
  dest.nsubs = src.nsubs
  dest.rebuildCbufs()


# -----------------------------------
# YdbKey buffer management
# -----------------------------------

proc reserve(s: var string, n: int) =
  ## Grow the buffer `s` so that it can hold at least `n` bytes.
  ## `s.len` is used as the capacity; the used length is tracked separately.
  if s.len >= n: return
  var cap = if s.len == 0: YDB_KEY_INITIAL_CAP else: s.len
  while cap < n: cap = cap + cap
  s.setLen(cap)

proc reserveSub*(k: var YdbKey, i: int, n: int) =
  ## Ensure the subscript buffer `i` can hold at least `n` bytes.
  doAssert i >= 0 and i < YDB_MAX_SUBS
  if k.subs[i].len >= n: return
  reserve(k.subs[i], n)
  # the buffer may have moved, refresh the cached C view
  let used = if i < k.nsubs: k.subUsed[i] else: 0
  k.cbufs[i] = ydb_buffer_t(
    len_alloc: k.subs[i].len.uint32,
    len_used: used.uint32,
    buf_addr: cast[cstring](unsafeAddr k.subs[i][0]))

proc subBuffers*(k: var YdbKey): ptr UncheckedArray[ydb_buffer_t] =
  ## Pointer to the cached `ydb_buffer_t` array of the key. All
  ## `YDB_MAX_SUBS` entries are valid, so the array can be used both as input
  ## subscripts and as output buffer for `ydb_node_next`.
  cast[ptr UncheckedArray[ydb_buffer_t]](addr k.cbufs[0])

proc reserveName(k: var YdbKey, n: int) =
  reserve(k.name, n)

func formatInt*(buf: var array[24, char], x: SomeInteger): int =
  ## Write the decimal representation of `x` right-aligned into `buf` and
  ## return the index of its first character. Allocation-free.
  var i = buf.len
  when x is SomeUnsignedInt:
    var v = uint64(x)
    while true:
      dec i
      buf[i] = char(ord('0') + int(v mod 10'u64))
      v = v div 10'u64
      if v == 0: break
  else:
    let neg = x < 0
    var v: uint64
    if neg: v = uint64(-(x + 1)) + 1'u64  # safe also for low(intN)
    else:   v = uint64(x)
    while true:
      dec i
      buf[i] = char(ord('0') + int(v mod 10'u64))
      v = v div 10'u64
      if v == 0: break
    if neg:
      dec i
      buf[i] = '-'
  i

proc setSubBytes(k: var YdbKey, i: int, src: pointer, n: int) =
  if i < 0 or i >= YDB_MAX_SUBS:
    raise newException(YdbError, "subscript index out of range: " & $i)
  reserveSub(k, i, n)
  if n > 0:
    copyMem(addr k.subs[i][0], src, n)
  k.subUsed[i] = n
  if i >= k.nsubs: k.nsubs = i + 1
  let cap = k.subs[i].len
  k.cbufs[i] = ydb_buffer_t(
    len_alloc: cap.uint32,
    len_used: n.uint32,
    buf_addr: (if cap == 0: nil else: cast[cstring](unsafeAddr k.subs[i][0])))

proc setName*(k: var YdbKey, name: string) =
  ## Set the variable name (e.g. `"^orders"`) of the key.
  reserveName(k, name.len)
  if name.len > 0:
    copyMem(addr k.name[0], unsafeAddr name[0], name.len)
  k.nameUsed = name.len

func globalName*(k: var YdbKey): string =
  ## The variable name of the key.
  k.name[0 ..< k.nameUsed]

func subCount*(k: var YdbKey): int =
  ## Number of subscripts of the key.
  k.nsubs

func subscript*(k: var YdbKey, i: int): string =
  ## The `i`-th subscript of the key.
  if i < 0 or i >= k.nsubs:
    raise newException(YdbError, "subscript index out of range: " & $i)
  k.subs[i][0 ..< k.subUsed[i]]

func toSeq*(k: YdbKey): seq[string] =
  ## Copy of the subscripts of the key as a `seq[string]`.
  ##
  ## Only the `k.nsubs` valid subscripts are returned; the remaining slots of
  ## the `subs` array are unused capacity and are skipped. Note that
  ## `subs[i].len` is the buffer capacity, so the used length comes from
  ## `subUsed[i]`.
  result = newSeq[string](k.nsubs)
  for i in 0 ..< k.nsubs:
    result[i] = k.subs[i][0 ..< k.subUsed[i]]

proc setSub*(k: var YdbKey, i: int, value: string) =
  ## Set subscript `i` to `value`.
  if value.len > 0:
    k.setSubBytes(i, unsafeAddr value[0], value.len)
  else:
    k.setSubBytes(i, nil, 0)

proc setSub*(k: var YdbKey, i: int, value: openArray[char]) =
  ## Set subscript `i` from a character array (no conversion, no allocation).
  if value.len > 0:
    k.setSubBytes(i, unsafeAddr value[0], value.len)
  else:
    k.setSubBytes(i, nil, 0)

proc setSub*[T: SomeInteger](k: var YdbKey, i: int, value: T) =
  ## Set subscript `i` to the decimal representation of `value` (allocation-free).
  var buf: array[24, char]
  let start = formatInt(buf, value)
  k.setSubBytes(i, addr buf[start], buf.len - start)

proc setSub*(k: var YdbKey, i: int, value: float) =
  ## Set subscript `i` to `$value` (allocates once for the conversion).
  k.setSub(i, $value)

proc setSub*(k: var YdbKey, i: int, value: bool) =
  ## Set subscript `i` to `"1"` (true) or `"0"` (false).
  k.setSub(i, (if value: "1" else: "0"))

proc addSub*(k: var YdbKey, value: string) =
  ## Append a subscript.
  k.setSub(k.nsubs, value)

proc addSub*[T: SomeInteger](k: var YdbKey, value: T) =
  ## Append a subscript (allocation-free).
  k.setSub(k.nsubs, value)

proc addSub*(k: var YdbKey, value: float) =
  ## Append a subscript.
  k.setSub(k.nsubs, value)

proc addSub*(k: var YdbKey, value: bool) =
  ## Append a subscript.
  k.setSub(k.nsubs, value)

proc initYdbKey*(name: string, subs: varargs[string]): YdbKey =
  ## Create a reusable key for the variable `name` with the given subscripts.
  ## A subscript collection (e.g. a `Subscripts` sequence) can be passed as a
  ## single argument.
  if name.len == 0:
    raise newException(YdbError, "Empty variable name")
  result.setName(name)
  for sub in subs:
    result.setSub(result.nsubs, sub)

proc delSub*(k: var YdbKey, i: int) =
  ## Remove subscript `i`, shifting the following subscripts down.
  if i < 0 or i >= k.nsubs:
    raise newException(YdbError, "subscript index out of range: " & $i)
  for j in i + 1 ..< k.nsubs:
    let n = k.subUsed[j]
    if n > 0:
      k.setSubBytes(j - 1, addr k.subs[j][0], n)
    else:
      k.setSubBytes(j - 1, nil, 0)
  dec k.nsubs
  k.subUsed[k.nsubs] = 0
  k.cbufs[k.nsubs].len_used = 0

proc setSubsLen*(k: var YdbKey, n: int) =
  ## Set the number of subscripts to `n`; new subscripts are empty.
  if n < 0 or n > YDB_MAX_SUBS:
    raise newException(YdbError, "subscript count out of range: " & $n)
  for i in n ..< k.nsubs:
    k.subUsed[i] = 0
    k.cbufs[i].len_used = 0
  for i in k.nsubs ..< n:
    k.subUsed[i] = 0
    k.cbufs[i].len_used = 0
  k.nsubs = n

proc clearSubs*(k: var YdbKey) =
  ## Remove all subscripts (buffer capacities are kept).
  k.setSubsLen(0)

proc setMaxSubscripts*(k: var YdbKey) =
  ## Set `YDB_MAX_SUBS` subscripts of five `0xFF` bytes each. This is the
  ## highest possible key and is used as the starting point to find the last
  ## node of a tree with `ydb_node_previous`.
  const highSub = "\xff\xff\xff\xff\xff"
  for i in 0 ..< YDB_MAX_SUBS:
    k.setSub(i, highSub)
  k.nsubs = YDB_MAX_SUBS

proc `$`*(k: var YdbKey): string =
  ## Render the key as `^global(sub1,sub2)`.
  result = k.globalName
  if k.nsubs == 0: return
  result.add '('
  for i in 0 ..< k.nsubs:
    if i > 0: result.add ','
    result.add k.subs[i][0 ..< k.subUsed[i]]
  result.add ')'

# -----------------------------------
# YdbKey <-> ydb_buffer_t
# -----------------------------------

proc nameBuffer*(k: var YdbKey): ydb_buffer_t =
  ## `ydb_buffer_t` view on the variable name of the key.
  ## The pointer remains valid as long as the key is not reallocated.
  ydb_buffer_t(
    len_alloc: k.name.len.uint32,
    len_used: k.nameUsed.uint32,
    buf_addr: (if k.name.len == 0: nil else: cast[cstring](unsafeAddr k.name[0])))

proc fillSubBuffers*(k: var YdbKey, dst: var array[YDB_MAX_SUBS, ydb_buffer_t]) =
  ## Copy the cached `ydb_buffer_t` views of the key into `dst`.
  ## All `YDB_MAX_SUBS` slots are filled so that the array can also be used as
  ## output buffer for `ydb_node_next` / `ydb_node_previous`.
  for i in 0 ..< YDB_MAX_SUBS:
    dst[i] = k.cbufs[i]


var TPTOKEN* {.threadvar.}: uint64
# TPTOKEN holds the transaction token given by YottaDB in the context
# of a Transaction when code is compiled with --threads:on
# In all other cases, TPTOKEN = 0
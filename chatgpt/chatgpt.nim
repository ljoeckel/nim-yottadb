# ydb_lock_demo.nim
# Nim-Client für YottaDB ydb_lock_s()

{.passl: "-lyottadb".}          # Linke gegen libyottadb
# Falls dein Header woanders liegt, den -I Pfad beim Kompilieren setzen (siehe oben).

type
  ydb_buffer_t* {.importc: "ydb_buffer_t", header: "libyottadb.h".} = object
    len_alloc*: cuint
    len_used*:  cuint
    buf_addr*:  cstring

# ydb_lock_s aus der C-API (variadisch!)
proc ydb_lock_s*(timeout_nsec: culonglong; namecount: cint): cint
  {.importc, varargs, header: "libyottadb.h".}

const
  YDB_OK* = 0

proc check(code: cint; ctx: string) =
  if code != YDB_OK:
    echo ctx," failed with status ", code

when isMainModule:
  # =========================
  # Variante A: 1 Subscript
  # ^LJ("LAND") und ^LJ("ORT")
  # =========================
  var
    var1 = ydb_buffer_t(len_alloc: 3'u32, len_used: 3'u32, buf_addr: "^LJ")
    var2 = ydb_buffer_t(len_alloc: 3'u32, len_used: 3'u32, buf_addr: "^LJ")

    subs1A = [ ydb_buffer_t(len_alloc: 4'u32, len_used: 4'u32, buf_addr: "LAND") ]
    subs2A = [ ydb_buffer_t(len_alloc: 3'u32, len_used: 3'u32, buf_addr: "ORT") ]

  let rcA = ydb_lock_s(1_000_000.culonglong, 2.cint,          # 1 ms, 2 Namen
                       addr var1, 1.cint, addr subs1A[0],     # ^LJ("LAND")
                       addr var2, 1.cint, addr subs2A[0])     # ^LJ("ORT")
  check(rcA, "lock (Variante A)")
  echo "Lock (Variante A) erfolgreich gesetzt."

  # =========================
  # Variante B: 3 Subscripts
  # z.B. ^LJ("LAND","DE","NORD") und ^LJ("ORT","BER","WEST")
  # =========================
  var
    subs1B: array[3, ydb_buffer_t] = [
      ydb_buffer_t(len_alloc: 4'u32, len_used: 4'u32, buf_addr: "LAND"),
      ydb_buffer_t(len_alloc: 2'u32, len_used: 2'u32, buf_addr: "DE"),
      ydb_buffer_t(len_alloc: 4'u32, len_used: 4'u32, buf_addr: "NORD")
    ]
    subs2B: array[3, ydb_buffer_t] = [
      ydb_buffer_t(len_alloc: 3'u32, len_used: 3'u32, buf_addr: "ORT"),
      ydb_buffer_t(len_alloc: 3'u32, len_used: 3'u32, buf_addr: "BER"),
      ydb_buffer_t(len_alloc: 4'u32, len_used: 4'u32, buf_addr: "WEST")
    ]

  let rcB = ydb_lock_s(1_000_000.culonglong, 2.cint,
                       addr var1, 3.cint, addr subs1B[0],
                       addr var2, 3.cint, addr subs2B[0])
  check(rcB, "lock (Variante B)")
  echo "Lock (Variante B) erfolgreich gesetzt."

  # ===== Alle Locks freigeben =====
  let rcU = ydb_lock_s(0.culonglong, 0.cint)  # namecount=0 => alle Locks dieses Prozesses freigeben
  check(rcU, "unlock")
  echo "Locks erfolgreich freigegeben."



# The macro solution for dynamic variadic variables
import macros

macro ydbLockDbVariadic(timeout: uint; names: typed; subs: typed): untyped =
  result = newCall(ident("ydb_lock_s"))
  result.add newCall(ident("culonglong"), timeout)
  result.add newCall(ident("cint"), newDotExpr(names, ident("len")))
  for i in 0 ..< names.len:
    result.add newCall(ident("addr"), newTree(nnkBracketExpr, names, newLit(i)))
    result.add newCall(ident("cint"), newDotExpr(newTree(nnkBracketExpr, subs, newLit(i)), ident("len")))
    result.add newCall(ident("addr"), newTree(nnkBracketExpr, newTree(nnkBracketExpr, subs, newLit(i)), newLit(0)))


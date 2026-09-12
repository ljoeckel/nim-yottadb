import libs/libydb
import libs/ydbtypes
import libs/ydbimpl
import libs/dsl
import libs/bingoser
import dbstats
import zippy 
import lz4
import zstd/compress as zstdenc   # aliased: proc `zstd` below would shadow the module name

export libydb
export ydbtypes
export ydbimpl
export dsl
export bingoser
export dbstats

# --- Compression with .gzip and .zlib postfix
const DEFAULT_GZIP_LEVEL = BestSpeed # NoCompression, BestSpeed, BestCompression, DefaultCompression, HuffmanOnly
const DEFAULT_LZ4_LEVEL = 2
const DEFAULT_ZSTD_LEVEL = 3 # https://facebook.github.io/zstd/zstd_manual.html

proc gzip*(s: string, level: int = DEFAULT_GZIP_LEVEL): string =
    compress(s, level, CompressedDataFormat.dfGzip)

proc gzip*[T](s: seq[T], level: int = DEFAULT_GZIP_LEVEL): string =
    compress($s, level, CompressedDataFormat.dfGzip)

proc zlib*(s: string, level: int = DEFAULT_GZIP_LEVEL): string =
    compress(s, level, CompressedDataFormat.dfZlib)

proc zlib*[T](s: seq[T], level: int = DEFAULT_GZIP_LEVEL): string =
    compress($s, level, CompressedDataFormat.dfZlib)


proc lz4*(s: string, level: int = DEFAULT_LZ4_LEVEL): string =
    lz4.compress(s, level)

proc lz4*[T](s: seq[T], level: int = DEFAULT_LZ4_LEVEL): string =
    lz4.compress($s, level)

# Reusable zstd compression context, one per thread. Reusing it lets zstd keep
# its internal working buffers allocated across calls instead of re-allocating
# them on every compress. It is intentionally never freed (lives for the thread's
# lifetime), so it is safe to reuse but NOT to share across threads.
var ZSTD_CCTX {.threadvar.}: ptr zstdenc.ZSTD_CCtx

proc zstdCctx(): ptr zstdenc.ZSTD_CCtx =
    ## Returns this thread's reusable `ZSTD_CCtx`, creating it lazily.
    if ZSTD_CCTX.isNil:
        ZSTD_CCTX = zstdenc.new_compress_context()
    ZSTD_CCTX

proc zstd*(s: string, level: int = DEFAULT_ZSTD_LEVEL): string =
    let buf = zstdenc.compress(zstdCctx(), s, level)   # returns seq[byte]
    result = newString(buf.len)
    copyMem(result[0].addr, buf[0].unsafeAddr, buf.len)
        
proc zstd*[T](s: seq[T], level: int = DEFAULT_ZSTD_LEVEL): string =
    let buf = zstdenc.compress(zstdCctx(), $s, level)  # returns seq[byte]
    result = newString(buf.len)
    copyMem(result[0].addr, buf[0].unsafeAddr, buf.len)


# --- YdbVar

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




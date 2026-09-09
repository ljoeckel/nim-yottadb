import libs/libydb
import libs/ydbtypes
import libs/ydbimpl
import libs/dsl
import libs/bingoser
import dbstats
import zippy 
import lz4
import zstd/compress as zstdenc   # aliased: proc `zstd` below would shadow the module name
import brotli as zbrotli

export libydb
export ydbtypes
export ydbimpl
export dsl
export bingoser
export dbstats

# --- Compression with .gzip and .zlib postfix
const DEFAULT_LEVEL = BestSpeed # NoCompression, BestSpeed, BestCompression, DefaultCompression, HuffmanOnly
const DEFAULT_LZ4_LEVEL = 2
const DEFAULT_ZSTD_LEVEL = 3

proc gzip*(s: string, level: int = DEFAULT_LEVEL): string =
    compress(s, level, CompressedDataFormat.dfGzip)
proc gzip*[T](s: seq[T], level: int = DEFAULT_LEVEL): string =
    compress($s, level, CompressedDataFormat.dfGzip)

proc zlib*(s: string, level: int = DEFAULT_LEVEL): string =
    compress(s, level, CompressedDataFormat.dfZlib)
proc zlib*[T](s: seq[T], level: int = DEFAULT_LEVEL): string =
    compress($s, level, CompressedDataFormat.dfZlib)


proc lz4*(s: string, level: int = DEFAULT_LZ4_LEVEL): string =
    lz4.compress(s, level)
proc lz4*[T](s: seq[T], level: int = DEFAULT_LEVEL): string =
    lz4.compress($s, level)

proc zstd*(s: string, level: int = DEFAULT_ZSTD_LEVEL): string =
    let cctx = zstdenc.new_compress_context()
    let buf = zstdenc.compress(cctx, s, level)   # returns seq[byte]
    result = newString(buf.len)
    copyMem(result[0].addr, buf[0].unsafeAddr, buf.len)
    discard zstdenc.free_context(cctx)

proc zstd*[T](s: seq[T], level: int = DEFAULT_ZSTD_LEVEL): string =
    let cctx = zstdenc.new_compress_context()
    let buf = zstdenc.compress(cctx, $s, level)  # returns seq[byte]
    result = newString(buf.len)
    copyMem(result[0].addr, buf[0].unsafeAddr, buf.len)
    discard zstdenc.free_context(cctx)

proc brotli*(s: string, level: int = DEFAULT_LZ4_LEVEL): string =
    zbrotli.compressBrotli(s)
proc brotli*[T](s: seq[T], level: int = DEFAULT_LEVEL): string =
    zbrotli.compressBrotli($s)


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




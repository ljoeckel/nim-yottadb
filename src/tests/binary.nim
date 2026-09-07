import std/strutils
import std/[unittest]
import yottadb
import ydbutils

proc setup() =
    Kill:
      ^tmp
      ^images

const
    BLOCKSIZES = [1024, 1025, 2048, 2049, 65536]

var TOTAL_BYTES = 0

var KB = newStringOfCap(1024)
for j in 0..<4:
    for i in 0 .. 255:
        KB.add(i.char)

proc dumpKeys() =
    for (k,v) in QueryItr ^tmp.kv:
        echo k," len=", v.len

proc createBinData(kb: int): string =
  # create a binary string of 'kb' kilobytes
  result = KB.repeat(kb)


proc testBinary() =
  Kill ^tmp
  Set: ^tmp("binary") = createBinData(1)
  let dbval = Get ^tmp("binary")
  assert dbval == createBinData(1)

  # Create binary Data upto 1MB
  for i in 4095 .. 4096:
    let data = createBinData(i)
    Set: ^tmp("binary", i) = data
    let dbval = Get ^tmp("binary", i)
    assert dbval == data
  

proc testBinaryHugeWrite(): int =
  Kill ^tmp
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    inc(TOTAL_BYTES, data.len)
    Set: ^tmp(size) = data
    let dbdata = Get ^tmp(size)
    assert data == dbdata
  return totalBytes

proc testBinaryHugeRead(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size)
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES
  return totalBytes


proc testBinaryHugeWriteGzip(): int =
  Kill ^tmp
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    Set: ^tmp(size) = data.gzip
    let dbdata = Get ^tmp(size).gzip
    assert data == dbdata
  return totalBytes

proc testBinaryHugeReadGzip(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size).gzip
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES
  return totalBytes

proc testBinaryHugeReadGzipVerify(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    let dbdata = Get ^tmp(size).gzip
    assert dbdata == data
    inc(totalBytes, dbdata.len)
  assert totalBytes == TOTAL_BYTES
  return totalBytes


proc testBinaryHugeWriteZlib(): int =
  Kill ^tmp
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    Set: ^tmp(size) = data.zlib
    let dbdata = Get ^tmp(size).zlib
    assert data == dbdata
  return totalBytes

proc testBinaryHugeReadZlib(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size).zlib
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes

proc testBinaryHugeReadZlibVerify(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    let dbdata = Get ^tmp(size).zlib
    assert data == dbdata
    inc(totalBytes, dbdata.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes


proc testBinaryHugeWriteLZ4(): int =
  Kill ^tmp
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    Set: ^tmp(size) = data.lz4
    let dbdata = Get ^tmp(size).lz4
    assert data == dbdata
  return totalBytes

proc testBinaryHugeReadLZ4(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size).lz4
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes

proc testBinaryHugeReadVerifyLZ4(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    let dbdata = Get ^tmp(size).lz4
    assert data == dbdata
    inc(totalBytes, dbdata.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes


proc testBinaryHugeWriteZSTD(): int =
  Kill ^tmp
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(totalBytes, data.len)
    Set: ^tmp(size) = data.zstd
    let dbdata = Get ^tmp(size).zstd
    assert data == dbdata
  return totalBytes

proc testBinaryHugeReadZSTD(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size).zstd
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes

proc testBinaryHugeReadVerifyZSTD(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = createBinData(size)
    let dbdata = Get ^tmp(size).zstd
    assert data == dbdata
    inc(totalBytes, dbdata.len)
  assert totalBytes == TOTAL_BYTES    
  return totalBytes


if isMainModule:
    test "binary": testBinary()

    test "binary huge write": 
      var (ms, rc) = timed_rc: testBinaryHugeWrite()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024
      calcSpace("^tmp")

    test "binary huge read": 
      var (ms, rc) = timed_rc: testBinaryHugeRead()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge write GZIP": 
      var (ms, rc) = timed_rc: testBinaryHugeWriteGzip()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024
      calcSpace("^tmp")

    test "binary huge read GZIP": 
      var (ms, rc) = timed_rc: testBinaryHugeReadGzip()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read GZIP Verify": 
      var (ms, rc) = timed_rc: testBinaryHugeReadGzipVerify()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge write ZLIB": 
      var (ms, rc) = timed_rc: testBinaryHugeWriteZlib()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024
      calcSpace("^tmp")

    test "binary huge read ZLIB": 
      var (ms, rc) = timed_rc: testBinaryHugeReadZlib()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read ZLIB Verify": 
      var (ms, rc) = timed_rc: testBinaryHugeReadZlibVerify()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge write LZ4": 
      var (ms, rc) = timed_rc: testBinaryHugeWriteLZ4()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024
      calcSpace("^tmp")

    test "binary huge read LZ4": 
      var (ms, rc) = timed_rc: testBinaryHugeReadLZ4()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read LZ4 Verify": 
      var (ms, rc) = timed_rc: testBinaryHugeReadVerifyLZ4()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge write ZSTD": 
      var (ms, rc) = timed_rc: testBinaryHugeWriteZSTD()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024
      calcSpace("^tmp")

    test "binary huge read ZSTD": 
      var (ms, rc) = timed_rc: testBinaryHugeReadZSTD()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read ZSTD Verify": 
      var (ms, rc) = timed_rc: testBinaryHugeReadVerifyZSTD()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024


    Kill ^tmp
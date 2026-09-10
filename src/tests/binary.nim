import std/strutils
import std/[unittest]
import yottadb
import ydbutils


const
    BLOCKSIZES = [1024, 1025, 2048, 2049, 65536]

var TOTAL_BYTES = 0

var KB = newStringOfCap(1024)
for j in 0..<4:
    for i in 0 .. 255:
        KB.add(i.char)

proc createBinData(kb: int, w3c: bool = false): string =
  # create a binary string of 'kb' kilobytes
  result = KB.repeat(kb)

proc calcRatio(ms: int, bytes: int) =
    let compressedSize = calcSpace("^tmp", false)
    let bps = bytes / ms * 1000
    let ratio = bytes.float / compressedSize.float
    echo "App. Size: ", bytes, "b, Compressed Size:", compressedSize, "b processed in ", ms, " ms. MB/sec=", bps / 1024 / 1024, "  Ratio=", ratio


proc testBinary(): int =
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

proc testBinaryRead(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size)
    inc(totalBytes, data.len)
  assert totalBytes == TOTAL_BYTES
  return totalBytes


template defineTest(typeName; w3c: bool = false): untyped =
    proc `testBinaryHugeWrite typename w3c`(): int =
        let algo = astToStr(typeName)
        echo "Running test for '", algo, "'"
        Kill ^tmp
        TOTAL_BYTES = 0
        for kb in BLOCKSIZES:
          let data = createBinData(kb, w3c)
          inc(TOTAL_BYTES, data.len)
          Set: ^tmp(kb) = data.`typename`
          let dbdata = Get ^tmp(kb).`typename`
          assert data == dbdata
        return TOTAL_BYTES
    proc `testBinaryHugeRead typename w3c`(): int =
        var total = 0
        for kb in BLOCKSIZES:
          let compressed = Get ^tmp(kb)
          echo "  RC (", kb ,") ", compressed.len, " bytes"
          let lenCompressed = compressed.len  
          let dbdata = Get ^tmp(kb).`typename`
          echo "  R  (", kb ,") ", dbdata.len, " bytes"
          inc(total, dbdata.len)
        assert total == TOTAL_BYTES    
        return total
    proc `testBinaryHugeReadVerify typename w3c`(): int =
        var totalBytes = 0
        for kb in BLOCKSIZES:
            let data = createBinData(kb, w3c)
            let dbdata = Get ^tmp(kb).`typename`
            echo "  R  (", kb ,") ", dbdata.len, " bytes"
            assert data == dbdata
            inc(totalBytes, dbdata.len)
        assert totalBytes == TOTAL_BYTES    
        return totalBytes

defineTest(gzip)
defineTest(zlib)
defineTest(lz4)
defineTest(zstd)
defineTest(brotli)


template runTest(typeName): untyped =
    var (ms, bytes) = timed_rc:
        `testBinaryHugeWrite typeName false`()
    calcRatio(ms, bytes)


if isMainModule:
    test "binary": 
        let (ms, bytes) = timed_rc:
            testBinary()
        calcRatio(ms, bytes)

    test "gzip":
        runTest(gzip)
    test "zlib":
        runTest(zlib)
    test "lz4":
        runTest(lz4)
    test "zstd":
        runTest(zstd)
    test "brotli":
        runTest(brotli)

    Kill ^tmp
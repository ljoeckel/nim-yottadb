import std/strutils
import std/[unittest]
import yottadb
import ydbutils


const
    BLOCKSIZES = [1024, 1025, 2048, 2049, 65536]

var TOTAL_BYTES = 0

# create a binary string of 'kb' kilobytes
var KB = newStringOfCap(1024)
for j in 0..<4:
    for i in 0 .. 255:
        KB.add(i.char)

proc createBinData(kb: int): string =
    result = KB.repeat(kb)

proc calcRatio(ms: int, bytes: int) =
    let compressedSize = calcSpace("^tmp", false)
    let bps = bytes / ms * 1000
    let ratio = bytes.float / compressedSize.float
    echo "App. Size: ", bytes, "b, Compressed Size:", compressedSize, "b processed in ", ms, " ms. MB/sec=", bps / 1024 / 1024, "  Ratio=", ratio


proc testBinary(): int =
  Kill ^tmp
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(result, data.len)
    Set: ^tmp(size) = data
    let dbdata = Get ^tmp(size)
    assert data == dbdata


proc testBinaryYK(): int =
  Kill ^tmp
  var key = initYdbKey("^tmp")
  for size in BLOCKSIZES:
    let data = createBinData(size)
    inc(result, data.len)
    key.setSub(0, size)
    ydb_set(key, data)
    let dbdata = ydb_get(key)
    assert data == dbdata


proc testBinaryRead(): int =
  for size in BLOCKSIZES:
    let data = Get ^tmp(size)
    inc(result, data.len)
  assert result == TOTAL_BYTES

proc testBinaryReadYK(): int =
  var key = initYdbKey("^tmp")
  for size in BLOCKSIZES:
    key.setSub(0, size)
    let dbdata = ydb_get(key)
    inc(result, dbdata.len)
  assert result == TOTAL_BYTES


template defineTest(typeName; w3c: bool = false): untyped =
    proc `testBinaryHugeWrite typename w3c`(): int =
        let algo = astToStr(typeName)
        echo "Running test for '", algo, "'"
        Kill ^tmp
        for kb in BLOCKSIZES:
          let data = createBinData(kb)
          inc(result, data.len)
          Set: ^tmp(kb) = data.`typename`
          let dbdata = Get ^tmp(kb).`typename`
          assert data == dbdata

    proc `testBinaryHugeRead typename w3c`(): int =
        for kb in BLOCKSIZES:
          let compressed = Get ^tmp(kb)
          echo "  RC (", kb ,") ", compressed.len, " bytes"
          let lenCompressed = compressed.len  
          let dbdata = Get ^tmp(kb).`typename`
          echo "  R  (", kb ,") ", dbdata.len, " bytes"
          inc(result, dbdata.len)
        assert result == TOTAL_BYTES    

    proc `testBinaryHugeReadVerify typename w3c`(): int =
        for kb in BLOCKSIZES:
            let data = createBinData(kb)
            let dbdata = Get ^tmp(kb).`typename`
            echo "  R  (", kb ,") ", dbdata.len, " bytes"
            assert data == dbdata
            inc(result, dbdata.len)
        assert result == TOTAL_BYTES    

defineTest(gzip)
defineTest(zlib)
defineTest(lz4)
defineTest(zstd)


template runTest(typeName): untyped =
    var (ms, bytes) = timed_rc:
        `testBinaryHugeWrite typeName false`()
    calcRatio(ms, bytes)


if isMainModule:
    test "binary": 
        let (ms, bytes) = timed_rc:
            testBinary()
        TOTAL_BYTES = bytes
        calcRatio(ms, bytes)

    test "binaryYK": 
        let (ms, bytes) = timed_rc:
            testBinaryYK()
        calcRatio(ms, bytes)

    test "binaryRead": 
        let (ms, bytes) = timed_rc:
            testBinaryRead()
        calcRatio(ms, bytes)

    test "binaryReadYK": 
        let (ms, bytes) = timed_rc:
            testBinaryReadYK()
        calcRatio(ms, bytes)

    test "gzip":
        runTest(gzip)
    test "zlib":
        runTest(zlib)
    test "lz4":
        runTest(lz4)
    test "zstd":
        runTest(zstd)

    Kill ^tmp
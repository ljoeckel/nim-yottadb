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

var KB = newStringOfCap(1024)
for j in 0..<4:
    for i in 0 .. 255:
        KB.add(i.char)


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
    Set: ^tmp(size) = data
    let dbdata = Get ^tmp(size)
    assert data == dbdata
  return totalBytes

proc testBinaryHugeRead(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let data = Get ^tmp(size)
    inc(totalBytes, data.len)
  return totalBytes

proc testBinaryHugeVerify(): int =
  var totalBytes = 0
  for size in BLOCKSIZES:
    let dbdata = Get ^tmp(size)
    inc(totalBytes, dbdata.len)
    assert createBinData(size) == dbdata
  return totalBytes


if isMainModule:
    test "binary": testBinary()

    test "binary huge write": 
      var (ms, rc) = timed_rc: testBinaryHugeWrite()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " written in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge read": 
      var (ms, rc) = timed_rc: testBinaryHugeRead()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    test "binary huge verify": 
      var (ms, rc) = timed_rc: testBinaryHugeVerify()
      let bps = rc / ms * 1000
      echo "Total bytes ", rc, " read in ", ms, " ms. MB/sec=", bps / 1024 / 1024

    Kill ^tmp
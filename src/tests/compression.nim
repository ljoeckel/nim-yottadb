import std/strutils
import std/[unittest]
import std/enumerate
import std/tables

import std/random
import yottadb
import ydbutils

var COMPRESSED: seq[string]
var RAW: seq[string]

const MAX_RUN = 100000
proc getWordCount(): int =
    for cnt in OrderItr ^stopwordsDE.count:
        return cnt

let cnt = getWordCount()
var wordsTable = initTable[int, string](cnt)
for (i, key) in enumerate(OrderItr ^stopwordsDE):
    wordsTable[i] = key

proc createTestData() =
    proc genWords(): string =
        result = newStringOfCap(1024)
        for words in 0..rand(50..512):
            let r = rand(0..cnt-1)
            result.add(wordsTable[r])
            result.add(' ')

    for i in 0..MAX_RUN:
        RAW.add(genWords())

proc calcRatio(info: string, ms: int, bytes: int, compressedSize: int) =
    let bps = bytes / ms * 1000
    let ratio = bytes.float / compressedSize.float
    echo info, " raw: ", hrb(bytes), "b, Compressed:", hrb(compressedSize), "b processed in ", ms, " ms. MB/sec=", bps / 1024 / 1024, "  Ratio=", ratio


template defineTest(typeName): untyped =
    proc `testCompress typename`() =
        var wordLen, compressedLen = 0
        COMPRESSED.setLen(0)
        let ms = timed_ms:
            for data in RAW:
                COMPRESSED.add(data.`typeName`)

            for i in 0..<COMPRESSED.len:
                inc(wordLen, RAW[i].len)
                inc(compressedLen, COMPRESSED[i].len)
        calcRatio("Compress", ms, wordLen, compressedLen)

    proc `testUncompress typename`() =
        var wordLen, compressedLen = 0
        let ms = timed_ms:
            for i in 0..<COMPRESSED.len:
                let data = COMPRESSED[i].`typeName`
                inc(compressedLen, COMPRESSED[i].len)
                inc(wordLen, data.len)
        calcRatio("Uncompress", ms, wordLen, compressedLen)

    
    # proc `testUncompress typename`(): int =
    #     var total = 0
    #     for kb in BLOCKSIZES:
    #       let compressed = Get ^tmp(kb)
    #       echo "  RC (", kb ,") ", compressed.len, " bytes"
    #       let lenCompressed = compressed.len  
    #       let dbdata = Get ^tmp(kb).`typename`
    #       echo "  R  (", kb ,") ", dbdata.len, " bytes"
    #       inc(total, dbdata.len)
    #     assert total == TOTAL_BYTES    
    #     return total

defineTest(gzip)
defineTest(zlib)
defineTest(lz4)
defineTest(zstd)


template runTest(typeName): untyped =
    `testCompress typeName`()
    `testUncompress typeName`()
    


if isMainModule:
    createTestData()
    test "gzip": runTest(gzip)
    test "zlib": runTest(zlib)
    test "lz4":  runTest(lz4)
    test "zstd": runTest(zstd)

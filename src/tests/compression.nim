import std/[strutils, os, algorithm, unittest]
import yottadb
import ydbutils

# ---------------------------------------------------------------------------
# Payload
#
# The benchmark compresses the project's own source code instead of reading
# words from a global of another project (^stopwordsDE), so it is
# self-contained and runs in any environment.
# ---------------------------------------------------------------------------

const
    BlockSize = 64 * 1024          ## bytes of source per compressed block
    TargetBytes = 8 * 1024 * 1024  ## repeat the corpus until we have this much
    SkippedDirs = ["nimcache", "nimblecache", "nimbledeps", ".git", "htmldocs"]

const ThisFile = currentSourcePath()
let projectRoot = ThisFile.parentDir.parentDir.parentDir

var RAW: seq[string]  ## uncompressed blocks used as payload

func isSourceFile(path: string): bool =
    case path.splitFile.ext.toLowerAscii
    of ".nim", ".nims", ".cfg": true
    else: false

proc isSkipped(root, path: string): bool =
    for part in relativePath(root, path).split(DirSep):
        if part in SkippedDirs:
            return true
    false

proc collectSourceCode(root: string): string =
    ## Concatenates all Nim sources and config files below `root`.
    var files: seq[string]
    for path in walkDirRec(root):
        if path.isSourceFile and not isSkipped(root, path):
            files.add(path)
    files.sort()

    for path in files:
        result.add("\n# ---- ")
        result.add(path.relativePath(root))
        result.add(" ----\n")
        result.add(readFile(path))

proc buildPayload(): seq[string] =
    ## Cuts the project's source code into fixed size blocks and repeats the
    ## block list until `TargetBytes` is reached, so timings are meaningful.
    let corpus = collectSourceCode(projectRoot)
    doAssert corpus.len > 0, "No source files found below " & projectRoot

    var blocks: seq[string]
    var pos = 0
    while pos < corpus.len:
        let stop = min(pos + BlockSize, corpus.len)
        blocks.add(corpus[pos ..< stop])
        pos = stop

    var total = 0
    while total < TargetBytes:
        for chunk in blocks:
            result.add(chunk)
            inc total, chunk.len

func humanBytes(bytes: int): string =
    if bytes < 1024:
        $bytes & " B"
    elif bytes < 1024 * 1024:
        formatFloat(bytes.float / 1024, ffDecimal, 1) & " KiB"
    else:
        formatFloat(bytes.float / 1024 / 1024, ffDecimal, 2) & " MiB"

proc calcRatio(info: string, elapsedMs: int64, bytes, compressedSize: int) =
    let ms = max(elapsedMs, 1)
    let mbPerSec = bytes.float / 1024 / 1024 / (ms.float / 1000)
    let ratio = bytes.float / max(compressedSize, 1).float
    echo info, ": raw=", humanBytes(bytes),
         ", compressed=", humanBytes(compressedSize),
         ", ratio=", formatFloat(ratio, ffDecimal, 2),
         ", ", ms, " ms, ", formatFloat(mbPerSec, ffDecimal, 2), " MB/s"


proc compressGzip(s: string): string = yottadb.gzip(s)
proc compressZlib(s: string): string = yottadb.zlib(s)
proc compressLz4(s: string): string = yottadb.lz4(s)
proc compressZstd(s: string): string = yottadb.zstd(s)

template defineTest(typeName: untyped, label: string, compress, decompress: untyped) =

    proc `testCompress typeName`(): seq[string] =
        var rawLen, compressedLen = 0
        result = newSeqOfCap[string](RAW.len)
        let elapsed = timed_ms:
            for chunk in RAW:
                result.add(compress(chunk))
            for i in 0 ..< result.len:
                inc rawLen, RAW[i].len
                inc compressedLen, result[i].len
                Set: ^testCompression(label, i) = result[i] # save compress on db
        calcRatio("compress " & label, elapsed, rawLen, compressedLen)

    proc `testUncompress typeName`(compressed: seq[string]) =
        var decompressed = newSeq[string](compressed.len)
        var rawLen, compressedLen = 0
        let elapsed = timed_ms:
            for i in 0 ..< compressed.len:
                decompressed[i] = decompress(compressed[i])
                inc compressedLen, compressed[i].len
                inc rawLen, decompressed[i].len
        calcRatio("uncompress " & label, elapsed, rawLen, compressedLen)
        for i in 0 ..< decompressed.len:
            #check decompressed[i] == RAW[i] # in memory
            check Get ^testCompression(label, i).`typename` == RAW[i]

defineTest(Gzip, "gzip", compressGzip, decompressGzip)
defineTest(Zlib, "zlib", compressZlib, decompressZlib)
defineTest(Lz4, "lz4", compressLz4, decompressLz4)
defineTest(Zstd, "zstd", compressZstd, decompressZstd)

if isMainModule:
    RAW = buildPayload()
    var totalBytes = 0
    for chunk in RAW:
        inc totalBytes, chunk.len
    echo "Payload: ", RAW.len, " blocks from ", projectRoot,
         " (", humanBytes(totalBytes), ")"

    test "gzip":
        testUncompressGzip(testCompressGzip())
    test "zlib":
        testUncompressZlib(testCompressZlib())
    test "lz4":
        testUncompressLz4(testCompressLz4())
    test "zstd":
        testUncompressZstd(testCompressZstd())

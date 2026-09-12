import yottadb
import ydbutils
import std/enumerate
import std/unittest
import std/os

let files = directoryWalk("/home/ljoeckel/git/nimydbsamples/src/rss/xml")
var filedata = newSeqOfCap[string](files.len)

proc loadData(): int =    
    echo "Loading files ..."
    var cnt = 0
    for file in files:
        let content = readFile(file)
        filedata.add(content)
        inc(result, content.len)
        inc cnt
        if cnt == 10000: break
    echo "Loaded ", cnt, " files"
    
    
# `level` is a compile-time constant that is threaded through to the
# compression proc (`content.gzip(level)` etc.) and embedded in the generated
# proc names so that several levels of the same algorithm can coexist.
# level == 0 means "use the algorithm's own default".
template defineFileTest(typeName; level: static int = 0): untyped =
    proc `testCompress typeName level`(): int =
        Kill ^RSSArchive

        var sumRaw = 0
        for (cnt, content) in enumerate(filedata):
            inc(sumRaw, content.len)
            when level != 0:
                Set: ^RSSArchive(cnt) = content.`typeName`(level)
            else:
                Set: ^RSSArchive(cnt) = content.`typeName`
            #if cnt == 1000: break
        return sumRaw

    proc `testUncompress typeName level`(): int =
        var total = 0
        for keys in QueryItr ^RSSArchive.keys:
            let lenUncompressed = (Get ^RSSArchive(keys).`typeName`).len
            inc(total, lenUncompressed)
        return total

    proc `getCompressedBytes typeName level`(): int =
        var sumCompressed = 0
        for keys in QueryItr ^RSSArchive.keys:
            let lenCompressed = (Get ^RSSArchive(keys)).len
            inc(sumCompressed, lenCompressed)
        return sumCompressed


defineFileTest(gzip)
defineFileTest(zlib)
defineFileTest(lz4)
defineFileTest(zstd)
defineFileTest(zstd, -3)


proc info(title: string, ms: int, bytes: int) =
    let throughput:int = bytes div ms * 1000
    echo title,": time:", ms, " ms. bytes:", bytes, " Throughput: ", hrb(throughput) , "/s."


template runTest(typeName; level: static int = 0): untyped =
    let label = astToStr(typeName) & (if level > 0: " lvl " & $level else: "")
    var (ms, bytes) = timed_rc:
        `testCompress typeName level`()
    info("Compression " & label, ms, bytes)

    discard execShellCmd("sync")

    (ms, bytes) = timed_rc:
        `testUncompress typeName level`()
    info("Decompression " & label, ms, bytes)

    let (ms2, compressedBytes) = timed_rc:
        `getCompressedBytes typeName level`()
    info("Read Compressed " & label, ms2, compressedBytes)
    echo "Ratio ", label, ": ", bytes.float / compressedBytes.float
    


when isMainModule:
    var (ms, bytes) = timed_rc:
        loadData()
    info("Load data: ", ms, bytes)
    
    #test "gzip": runTest(gzip)
    #test "zlib": runTest(zlib)
    test "lz4": runTest(lz4)
    test "zstd lvl 3": runTest(zstd)
    test "zstd lvl -3": runTest(zstd, -3)
    #test "zstd lvl -5": runTest(zstd, -5)

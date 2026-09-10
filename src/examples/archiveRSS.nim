import yottadb
import ydbutils
import std/enumerate
import std/unittest
import std/os


let files = directoryWalk("/home/ljoeckel/git/nimydbsamples/src/rss/xml")
echo "Have ", files.len, " files to archive"

template defineFileTest(typeName): untyped =
    
    proc `testCompress typename`(): int =
        Kill ^RSSArchive

        var sumRaw = 0
        for (cnt, file) in enumerate(files):
            let content = readFile(file)
            inc(sumRaw, content.len)
            Set: ^RSSArchive(file) = content.`typeName`
            #if cnt == 1000: break
        return sumRaw

    proc `testUncompress typename`(): int =
        var total = 0
        for keys in QueryItr ^RSSArchive.keys:
            let lenUncompressed = (Get ^RSSArchive(keys).`typeName`).len
            inc(total, lenUncompressed)
        return total

    proc `getCompressedBytes typename`(): int =
        var sumCompressed = 0
        for keys in QueryItr ^RSSArchive.keys:
            let lenCompressed = (Get ^RSSArchive(keys)).len
            inc(sumCompressed, lenCompressed)
        return sumCompressed


defineFileTest(gzip)
defineFileTest(zlib)
defineFileTest(lz4)
defineFileTest(zstd)


template runTest(typeName): untyped =
    var (ms, bytes) = timed_rc:
        `testCompress typeName`()
    echo "File read and compression time: ", ms, "ms.  Number of bytes:", bytes

    var (ms2, bytes2) = timed_rc:
        `testUncompress typeName`()
    echo "Decompression in ", ms2, "ms.  Number of bytes:", bytes2

    var (ms3, compressedBytes) = timed_rc:
        `getCompressedBytes typeName`()
    echo "Reading compressed data in ", ms3, "ms.  Number of compressed bytes:", compressedBytes
    echo "Ratio:", bytes.float / compressedBytes.float
    
    discard execShellCmd("sync")

when isMainModule:
    test "gzip": runTest(gzip)
    test "bzip": runTest(zlib)
    test "lz4": runTest(lz4)
    test "zstd": runTest(zstd)

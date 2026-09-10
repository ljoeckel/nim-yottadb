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
        var sumRaw = 0
        for keys in QueryItr ^RSSArchive.keys:
            #let data = Get ^RSSArchive(keys)
            let uncompressed = Get ^RSSArchive(keys).`typeName`
            #inc(sumCompressed, data.len)
            inc(sumRaw, uncompressed.len)
        #echo "Uncompress: Raw:", sumBytes, " Compressed:", sumCompressed, " bytes. Ratio:", sumBytes.float / sumCompressed.float
        return sumRaw

    proc `getCompressedBytes typename`(): int =
        var sumCompressed = 0
        for keys in QueryItr ^RSSArchive.keys:
            let data = Get ^RSSArchive(keys)
            inc(sumCompressed, data.len)
        return sumCompressed


defineFileTest(gzip)
defineFileTest(zlib)
defineFileTest(lz4)
defineFileTest(zstd)
#defineFileTest(brotli)


template runTest(typeName): untyped =
    var (ms, bytes) = timed_rc:
        `testCompress typeName`()
    echo "Run in ", ms, "ms.  Number of bytes:", bytes

    var (ms2, bytes2) = timed_rc:
        `testUncompress typeName`()
    echo "Run in ", ms2, "ms.  Number of bytes:", bytes2

    var (ms3, compressedBytes) = timed_rc:
        `getCompressedBytes typeName`()
    echo "Run in ", ms3, "ms.  Number of compressed bytes:", compressedBytes
    echo "Ratio:", bytes.float / compressedBytes.float
    
    discard execShellCmd("sync")

when isMainModule:
    test "gzip": runTest(gzip)
    test "bzip": runTest(zlib)
    test "lz4": runTest(lz4)
    test "zstd": runTest(zstd)
    #test "brotli": runTest(brotli)

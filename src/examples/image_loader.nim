import os
import std/[times, strutils, strformat]
import yottadb
import ydbutils

proc walk(path: string): seq[string] =
    for kind, path in walkDir(path):
        case kind:
        of pcFile, pcLinkToFile:
            result.add(path)
        of pcDir, pcLinkToDir:
            result.add(walk(path))

proc saveImagesToDb(basedir: string): uint =
    killnode: ^CNT("image_number")
    kill: ^images 

    var totalBytes: uint
    for image in walk(basedir):
        let image_number = increment(^CNT("image_number"))
        let image_data = readFile(image)
        echo fmt"Save image {image} ({image_data.len} bytes) to db"
        setvar:
            ^images($image_number) = image_data
            ^images($image_number, "path") = image
            ^images($image_number, "created") = now()
        inc(totalBytes, image_data.len)
    return totalBytes

proc saveImageToFilesystem(target:  string, path: string, img: string) =
    if not dirExists(target):
        createDir(target)

    let filename = path.split("/")[^1]
    let fullpath = target & "/" & filename
    writeFile(fullpath, img)

proc readImagesFromDb(target: string): uint =
    var totalBytes: uint
    var (rc, subs) = nextsubscript: ^images(@[""]).seq # -> @["223"], @["224"], ...
    while rc == YDB_OK:
        let img     = getvar ^images(subs).binary
        let path    = getvar ^images(subs, "path")
        saveImageToFilesystem(target, path, img)
        var cnt = 0
        for c in img:
            inc cnt
        inc(totalBytes, img.len)
        (rc, subs) = nextsubscript: ^images(subs).seq
    return totalBytes

if isMainModule:
    var totalBytesWritten, totalBytesRead: uint
    timed:
        echo "Loading images to db"
        totalBytesWritten = saveImagesToDb("./images") # read from the folder and save in db

    timed:
        echo "Saving images to filesystem"
        totalBytesRead = readImagesFromDb("./images_fromdb") # read from db and save under this folder
    echo "written=", totalBytesWritten, " read=", totalBytesRead
    #TODO: why different results? assert totalBytesWritten == totalBytesRead
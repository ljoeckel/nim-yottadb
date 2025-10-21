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
    let cnt = "^CNT(image_number)"
    kill: @cnt
    kill: ^images 

    var totalBytes: uint
    for image in walk(basedir):
        let image_number = increment @cnt
        let image_data = readFile(image)
        echo fmt"Save image {image} ({image_data.len} bytes) to db"
        let gbl = fmt"^images({image_number})"
        setvar:
            @gbl = image_data
            @gbl("path") = image
            @gbl("created") = now()
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
    var (rc, gbl) = nextsubscript: ^images # -> @["223"], @["224"], ...
    while rc == YDB_OK:
        let img     = getvar @gbl.binary
        let path    = getvar @gbl("path")
        echo "Read image ", path, " (", img.len, " bytes)"
        saveImageToFilesystem(target, path, img)
        inc(totalBytes, img.len)
        (rc, gbl) = nextsubscript: @gbl
    return totalBytes

if isMainModule:
    timed:
        echo "Loading images to db"
        var totalBytesWritten = saveImagesToDb("./images") # read from the folder and save in db
    timed:
        echo "Saving images to filesystem"
        var totalBytesRead = readImagesFromDb("./images_fromdb") # read from db and save under this folder
    echo "written=", totalBytesWritten, " read=", totalBytesRead
    assert totalBytesRead == totalBytesWritten
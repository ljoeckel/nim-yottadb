import os
import std/[times, strutils, strformat]
import yottadb
import ydbutils

const
    IMGNBR = "^CNT(image_number)"

proc walk(path: string): seq[string] =
    for kind, path in walkDir(path):
        case kind:
        of pcFile, pcLinkToFile:
            result.add(path)
        of pcDir, pcLinkToDir:
            result.add(walk(path))

proc saveImagesToDb(basedir: string): uint =
    var totalBytes: uint
    for image in walk(basedir):
        let image_number = increment @IMGNBR
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
    for key in orderItr ^images.key:
        let img     = getvar @key.binary
        let path    = getvar @key("path")
        echo fmt"Read image {path} ({img.len} bytes)"
        saveImageToFilesystem(target, path, img)
        inc(totalBytes, img.len)
    return totalBytes

if isMainModule:
    timed "kill ^images":
        kill: 
            ^images
            @IMGNBR

    timed "Load images to db":
        var totalBytesWritten = saveImagesToDb("./images") # read from the folder and save in db

    timed "Read from db and save in filesystem":
        var totalBytesRead = readImagesFromDb("./images_fromdb") # read from db and save under this folder
        echo "written=", totalBytesWritten, " read=", totalBytesRead
        assert totalBytesRead == totalBytesWritten
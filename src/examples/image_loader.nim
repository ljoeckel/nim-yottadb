import os
import std/[times, strutils, strformat]
import yottadb

const
    ID = "^CNT(id)"

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
        let image_data = readFile(image)
        echo fmt"Save image {image} ({image_data.len} bytes) to db"
        let id = Increment @ID
        let gbl = fmt"^images({id})"
        Set:
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
    for key in OrderItr ^images.key:
        let img     = Get @key.binary
        let path    = Get @key("path")
        echo fmt"Read image {path} ({img.len} bytes)"
        saveImageToFilesystem(target, path, img)
        inc(totalBytes, img.len)
    return totalBytes

if isMainModule:
    Kill:
        ^images
        @ID

    var totalBytesWritten = saveImagesToDb("./images") # read from the folder and save in db
    var totalBytesRead = readImagesFromDb("./images_fromdb") # read from db and save under this folder
    echo "written=", totalBytesWritten, " read=", totalBytesRead, " images:", Get @ID
    assert totalBytesRead == totalBytesWritten
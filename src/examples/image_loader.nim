import os
import std/[streams, times, strutils]
import yottadb

proc walk(path: string): seq[string] =
    for kind, path in walkDir(path):
        case kind:
        of pcFile, pcLinkToFile:
            result.add(path)
        of pcDir, pcLinkToDir:
            result.add(walk(path))

proc loadImagesToDb(basedir: string) =
    let images = walk(basedir)
    for image in images:
        var strm = newFileStream(image, fmRead)
        let image_data = strm.readAll()
        strm.close()

        let image_number = incr(^CNT("image_number"))
        set:
            ^images($image_number) = image_data
            ^images($image_number, "path") = image
            ^images($image_number, "size") = image_data.len
            ^images($image_number, "created") = now()

proc saveImage(target: string, path: string, img: string) =
    if not existsDir(target):
        createDir(target)

    let filename = path.split("/")[^1]
    let fullpath = target & "/" & filename
    writeFile(fullpath, img)

proc readImagesFromDb(target: string) =
    var (rc, subs) = nextsubscript: ^images(@[""]) # -> @["223"], @["224"], ...
    while rc == YDB_OK:
        let img     = get(^images(subs))
        let path    = get(^images(subs, "path"))
        let size    = get(^images(subs, "size"))
        saveImage(target, path, img)
        (rc, subs) = nextsubscript: ^images(subs)

if isMainModule:
    loadImagesToDb("../../images") # read from the folder and save in db
    readImagesFromDb("./local_images") # read from db and save under this folder
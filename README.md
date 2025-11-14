# nim-yottadb
**Nim Language implementation for the YottaDB database**

This project adds 'Nim' (https://nim-lang.org) as another language to access YottaDB NoSQL database. (https://yottadb.com)

YottaDB is a proven Multi-Language NoSQL database engine whose code base has decades of maturity and continuous investment. It is currently in production at some of the largest real-time core banking applications and electronic health record deployments.

For latest changes see the [CHANGELOG](doc/CHANGELOG.md)

The nim-yottadb implementation delievers the following features:
### Simple-API ###
- ydb_data (Get the state of a node or tree)
- ydb_delete (Node or Tree)
- ydb_delete_excl (Delete local variables except ...)
- ydb_get (Get a local or global variable)
- ydb_incr (Atomic Increment a local or global variable)
- ydb_lock (Lock 1 or more global variables)
- ydb_lock_incr / ydb_lock_dec (Increment or decrement a lock count)
- ydb_node_next (Get the next node of a global)
- ydb_node_previous (Like next, but other direction)
- ydb_set (Set the value of a local or global variable)
- ydb_subscript_next (Traverse the subscript tree of a Global). Up to 32 subscripts are allowed
- ydb_subscript_previous (Like ydb_subscript_next, but other direction)
- ydb_tp (Start a transaction)
- ydb_ci (Call a M-Routine via Call-In Interface)
- ydb_zwr2str / ydb_zwr2str Convert bindary data and convert back

### Extensions to the Simple-API
- Support for binary data > 1MB
- [DSL](doc/dsl.md)
- Indirection with @
- YdbVar with $ and [] operator
```nim
# Indirection
for node in queryItr ^GEO:
    let value = getvar @node
    
# YdbVar
for i in 0..MAX:
    var v = newYdbVar("^Geo", @["Country", "zip", i])
    # update db with new value
    v[] = "New " & v.value
    let val = $v # -> "New 0"
```
All API-Calls are available in a single- or multi-threaded version and ara automatically selected via the **when compileOption("threads")**

### No Maximum Record size
The YottaDB limit of 1MB for record size is no longer in effect. nim-yottadb handles larger record sizes up to 99_999_999 MB. The size is only limited due to memory constraints.
In the future there will be a `stream-interface`to handle virtual unlimited record sizes.

Records larger than 1 MB are split into subrecords. To do this, an additional key index is appended to the keys, incrementing from 0 to a maximum of 99999999, with each record containing 1 MB of data.

```nim
"___$00000000$___"
```
When reading back with getvar and the `.binary` postfix, nim-yottadb automatically checks whether such index keys exist and loads the data accordingly.
The processing of strings and binary data is also automatic.

### Sample to load / restore images into YottaDb
```nim
import os
import std/[times, strutils]
import yottadb

proc walk(path: string): seq[string] =
    for kind, path in walkDir(path):
        case kind:
        of pcFile, pcLinkToFile:
            result.add(path)
        of pcDir, pcLinkToDir:
            result.add(walk(path))

proc loadImagesToDb(basedir: string) =
    for image in walk(basedir):
        let image_number = increment(^CNT("image_number"))
        setvar:
            ^images($image_number) = readFile(image)
            ^images($image_number, "path") = image
            ^images($image_number, "created") = now()

proc saveImage(targetvar  string, path: string, img: string) =
    if not dirExists(target):
        createDir(target)

    let filename = path.split("/")[^1]
    let fullpath = target & "/" & filename
    writeFile(fullpath, img)

proc readImagesFromDb(targetvar  string) =
    var (rc, subs) = nextsubscript: ^images(@[""]) # -> @["223"], @["224"], ...
    while rc == YDB_OK:
        let img     = getvar ^images(subs).binary
        let path    = getvar ^images(subs, "path")
        saveImage(target, path, img)
        (rc, subs) = nextsubscript: ^images(subs)

if isMainModule:
    loadImagesToDb("./images") # read from the folder and save in db
    readImagesFromDb("./images_fromdb") # read from db and save under this folder
```

### More Info
For the project's architecture details look at https://deepwiki.com/ljoeckel/nim-yottadb/1-overview

- [Blog](doc/blog.md) gives some general information about the project
- Go to [Installation](doc/installation_and_using.md) for installation details.
- For ARM Architecture look [here](doc/installation_yottadb.md)
- [dsl](doc/dsl.md) for details about the Domain Specific Language
- Details about the Call-In Interface are found [here](doc/callin_interface.md)
- [Object-Serialization](doc/object_serialization.md) gives infos how to serialize and deserialize Nim object to YottaDB.
- Some details about Transactions are [here](doc/yottadb.md). Need's further work
- Benchmark results (few) are [here](doc/benchmark.md)

This project was started to learn Nim (https://nim-lang.org)
I'm truly impressed by the simplicity, power, and flexibility of Nim. The possibilities offered by macros and templates, in particular, make Nim a powerful tool. Developing software is finally fun again.

### Test's and Examples
In a cloned repo, you can run the tests and examples with
```bash
nimble test
nimble examples
```

### Feedback
nim-yottadb is a **work in progress** and any feedback or suggestions are welcome. It is hosted on GitHub [nim-yottadb](https://github.com/ljoeckel/nim-yottadb) with an MIT license so issues, forks and PRs are most appreciated. 


If you want to contact me please email to **lothar.joeckel@gmail.com**

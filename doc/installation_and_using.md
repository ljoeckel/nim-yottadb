# Install YottaDB
For a Linux installation go to [Get-Started](https://yottadb.com/product/get-started/#your-linux-system)
and follow the instructions.

# Install Nim
For installation go to [Install Nim](https://nim-lang.org/install.html)

# Install nimyottadb
By now, nimyottadb is not yet in the [nimble.directory](https://nimble.directory/). So you can install with
```nim
nimble install https://github.com/ljoeckel/nim-yottadb.git
```

If it's in the package registry, install simply with
```nim
nimble install nimyottadb
```

# Create project
- nimble init ydbtest
- cd to ydbtest
- Add file "nim.cfg" and add the following content:
```nim
--mm:arc --threads:on --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb"
```

Create the sourcefile src/"hello.nim"
```nim
import std/strformat
import yottadb

proc main() =
  set:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  var subs:Subscripts = @[]
  var rc = YDB_OK

  echo "Iterate over all customers"
  while rc == YDB_OK:
    (rc, subs) = nextsub: ^CUSTOMER(subs)
    if rc == YDB_OK:
      let id = subs[0]
      let name = get: ^CUSTOMER(id, "Name")
      let email = get: ^CUSTOMER(id, "Email")
      echo fmt"Customer {id}: {name} <{email}>"

  echo "Iterate over all nodes and use subscripts()"
  subs = @[]
  rc = YDB_OK
  while rc == YDB_OK:
    (rc, subs) = nextn: ^CUSTOMER(subs)
    if rc == YDB_OK:
      let value = get: ^CUSTOMER(subs)
      echo fmt"Node {subs} = {value}"

when isMainModule:
  main()
````
compile:
```nim
nim c -r src/hello.nim
````

The output should look like:
```nim
Iterate over all customers
Customer 1: John Doe <john-doe.@gmail.com>
Customer 2: Jane Smith <jane.smith.@yahoo.com>
Iterate over all nodes and use subscripts()
Node @["1", "Email"] = john-doe.@gmail.com
Node @["1", "Name"] = John Doe
Node @["2", "Email"] = jane.smith.@yahoo.com
Node @["2", "Name"] = Jane Smith
```
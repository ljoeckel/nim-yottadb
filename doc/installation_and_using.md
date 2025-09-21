# Install YottaDB
For a Linux installation on x86 architecture go to [Get-Started](https://yottadb.com/product/get-started/#your-linux-system)
and follow the instructions. For installation on ARM go to [here](installation_yottadb.md)

# Install Nim
For installation go to [Install Nim](https://nim-lang.org/install.html)
To Install on ARM Architecture, you need to build from source:
- Get the source files 
***wget https://nim-lang.org/download/nim-2.2.4.tar.xz***
- Unpack
***tar xf nim-2.2.4.tar.xz***
```
cd nim-2.2.4
sh build.sh
bin/nim c koch
./koch boot -d:release
./koch tools
sudo ./install.sh /usr/local/bin
```

Test
```
ljoeckel@m4ubt01:~$ nim -v
Nim Compiler Version 2.2.4 [Linux: arm64]
Compiled at 2025-09-13
Copyright (c) 2006-2025 by Andreas Rumpf
active boot switches: -d:release
```

To compile nimyottadb applications, the path to the libyottadb.so must be set in your .profile or .bashrc
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/yottadb/r202
```

Add to the following to .profile or .bashrc ***before*** you install tui_widget because nimgen is required for this to work.
```bash
export PATH=$PATH:$HOME/.nimble/bin
````

For the example 'traverse' to compile the nim packet 'tui-widget' is required. To install:
```bash
nimble install nimclipboard
nimble install asciigraph
nimble install https://github.com/jaar23/tui_widget.git
```
Also, some other linux packages are required to handle the clipboard functionality
```bash
sudo apt install xcb libx11-xcb-dev
```


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
    (rc, subs) = nextsubscript: ^CUSTOMER(subs)
    if rc == YDB_OK:
      let id = subs[0]
      let name = get: ^CUSTOMER(id, "Name")
      let email = get: ^CUSTOMER(id, "Email")
      echo fmt"Customer {id}: {name} <{email}>"

  echo "Iterate over all nodes and use subscripts()"
  subs = @[]
  rc = YDB_OK
  while rc == YDB_OK:
    (rc, subs) = nextnode: ^CUSTOMER(subs)
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
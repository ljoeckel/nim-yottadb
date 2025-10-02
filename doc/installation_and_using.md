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

### Install grabnim
grabnim is a tool to install the latest version of Nim. It also enhances the `nimlangserver` integration with Visual Studio Code.
```bash 
wget https://codeberg.org/janAkali/grabnim/raw/branch/master/misc/install.sh
sh install.sh
```
Run `grabnim -h` to see the options.


# Install nimyottadb
By now, nimyottadb is not yet in the [nimble.directory](https://nimble.directory/). So you can install with
```nim
nimble install https://github.com/ljoeckel/nim-yottadb.git
```

If it's in the package registry, install simply with
```nim
nimble install nimyottadb
```

# Create a nim-yottadb project
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
  setvar:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  echo "Iterate over all customers"
  var (rc, subs) = nextsubscript: ^CUSTOMER()
  while rc == YDB_OK:
    let name = get: ^CUSTOMER(subs, "Name")
    let email = get: ^CUSTOMER(subs, "Email")
    echo fmt"Customer {subs[0]}: {name} <{email}>"
    (rc, subs) = nextsubscript: ^CUSTOMER(subs) # Read next

  echo "Iterate over all nodes"
  (rc, subs) = nextnode: ^CUSTOMER()
  while rc == YDB_OK:
    let value = get: ^CUSTOMER(subs)
    echo fmt"Node {subs} = {value}"
    (rc, subs) = nextnode: ^CUSTOMER(subs) # Read next

when isMainModule:
  main()
```
compile with
```nim
nim c -r src/hello.nim
````

The output should look like:
```nim
Iterate over all customers
Customer 1: John Doe <john-doe.@gmail.com>
Customer 2: Jane Smith <jane.smith.@yahoo.com>
Iterate over all nodes
Node @["1", "Email"] = john-doe.@gmail.com
Node @["1", "Name"] = John Doe
Node @["2", "Email"] = jane.smith.@yahoo.com
Node @["2", "Name"] = Jane Smith
```
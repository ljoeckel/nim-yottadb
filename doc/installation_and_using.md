# Install YottaDB
For a Linux installation on x86 architecture go to [Get-Started](https://yottadb.com/product/get-started/#your-linux-system)
and follow the instructions or look at `Quickstart`. For installation on ARM go to [here](installation_yottadb.md)

### Quickstart YottaDB Installation
Install required development software:
```bash
sudo apt-get install --no-install-recommends file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates
```

Download and build YottaDB from source
```bash
ydb_distrib="https://gitlab.com/api/v4/projects/7957109/repository/tags"
ydb_tmpdir='tmpdir'
mkdir $ydb_tmpdir
wget -P $ydb_tmpdir ${ydb_distrib} 2>&1 1>${ydb_tmpdir}/wget_latest.log
ydb_version=`sed 's/,/\n/g' ${ydb_tmpdir}/tags | grep -E "tag_name|.pro.tgz" | grep -B 1 ".pro.tgz" | grep "tag_name" | sort -r | head -1 | cut -d'"' -f6`
git clone --depth 1 --branch $ydb_version https://gitlab.com/YottaDB/DB/YDB.git
cd YDB
```
```bash
mkdir build && cd build
cmake ..
make -j 2
make install
cd yottadb_r*
sudo ./ydbinstall --gui --utf8
```

Add `ydb_env_set`to your .bashrc or .profile
```bash
. /usr/local/etc/ydb_env_set
```

Logout and login again.
Enter `ydb`.
The `YDB>` prompt should be visible.
Enter `Ctrl^D` to leave.


# Install Nim
The best option to install Nim is to use the `grabnim` package.
```bash
wget https://codeberg.org/janAkali/grabnim/raw/branch/master/misc/install.sh
sh install.sh
```
Add the following exports to your .profile or .bashrc file:
```bash
export PATH="$HOME/.local/share/grabnim/current/bin:$PATH"
export PATH=„$HOME/.nimble/bin:$PATH"
````

Logout and login again
```bash
grabnim
nim -v
```
You should see now something like this:
```bash
Nim Compiler Version 2.2.5 [Linux: arm64]
Compiled at 2025-09-25
Copyright (c) 2006-2025 by Andreas Rumpf

git hash: 0a18975472557d9d5ec1312cd44ccaa178b7f06c
active boot switches: -d:release
```
For development with g.e. Visual Studio Code, the nimlangserver (LSP) is essential.
```bash
nimble install nimlangserver
```

Now install the required packages for `nimyottadb``
```bash
nimble install bingo
nimble install malebolgia
```
Now you can start development with VisualStudio Code
Install the following extensions:
- Remote SSH (Microsoft)
- NimLang (nim-lang.org)

## Build your own code
To compile nimyottadb applications, the path to the libyottadb.so must be set in your .profile or .bashrc
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/yottadb/r202
```

#### Install nimyottadb
By now, nimyottadb is not yet in the [nimble.directory](https://nimble.directory/). So you can install with
```nim
nimble install https://github.com/ljoeckel/nim-yottadb.git
```

### Create a nim-yottadb project
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
    let name = getvar  ^CUSTOMER(subs, "Name")
    let email = getvar  ^CUSTOMER(subs, "Email")
    echo fmt"Customer {subs[0]}: {name} <{email}>"
    (rc, subs) = nextsubscript: ^CUSTOMER(subs) # Read next

  echo "Iterate over all nodes"
  (rc, subs) = nextnode: ^CUSTOMER()
  while rc == YDB_OK:
    let value = getvar  ^CUSTOMER(subs)
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
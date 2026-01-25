

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
nimble install bingo malebolgia chronicles
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
```nim
nimble install malebolgia
nimble install bingo
nimble install nimyottadb
```

### Create a nim-yottadb project
- nimble init ydbtest
- cd to ydbtest
- Add file "nim.cfg" and add the following content where --passL should point to the path where yottadb is installed.
:
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

  echo "Iterate over all customer id's"
  for id in orderItr(^CUSTOMER):
    let name = getvar  ^CUSTOMER(id, "Name")
    let email = getvar  ^CUSTOMER(id, "Email")
    echo fmt"Customer {id}: {name} <{email}>"

  echo "Iterate over all nodes"
  for node in queryItr ^CUSTOMER:
    let value = getvar @node
    echo fmt"{node}={value}"

when isMainModule:
  main()
```

Compile with
```nim
nim c -r src/hello.nim
````

The output looks like:
```nim
Iterate over all customer id's
Customer 1: John Doe <john-doe.@gmail.com>
Customer 2: Jane Smith <jane.smith.@yahoo.com>
Iterate over all nodes
^CUSTOMER(1,Email)=john-doe.@gmail.com
^CUSTOMER(1,Name)=John Doe
^CUSTOMER(2,Email)=jane.smith.@yahoo.com
^CUSTOMER(2,Name)=Jane Smith
```
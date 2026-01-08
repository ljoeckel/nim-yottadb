# Install
Installing with 'grabnim' Nim:
```bash
wget https://codeberg.org/janAkali/grabnim/raw/branch/master/misc/install.sh
sh install.sh
export PATH="$HOME/.local/share/grabnim/current/bin:$PATH"
export PATH=„$HOME/.nimble/bin:$PATH"
```
Install the 'nimyottadb' package:
```bash
nimble install malebolgia
nimble install bingo
nimble install nimyottadb
```

# Use
```bash
wget https://raw.githubusercontent.com/ljoeckel/nim-yottadb/master/src/examples/sayHello.nim

nim c -r --passL:"-L/usr/local/lib/yottadb/r203 -lyottadb" sayHello.nim
````
The --passL path points to the place where the libyottadb.so is installed. Depends on the YottaDB installation.
This path needs also to be set in the LD_LIBRARY_PATH shell environment variable.


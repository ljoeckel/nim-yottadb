# Install
#### Install Nim:
```bash
curl -sSf https://nim-lang.org/choosenim/init.sh | sh
```
#### Add to your .bashrc
```bash
export PATH=$HOME/.nimble/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib/yottadb/r202
```
#### Logout and login to update the environment variables.

#### Install the 'nimyottadb' package:
```bash
nimble install malebolgia bingo nimyottadb
```

# Use
#### Get sayHello and run
```bash
wget https://raw.githubusercontent.com/ljoeckel/nim-yottadb/master/src/examples/sayHello.nim

nim c -r --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" sayHello.nim
````
The --passL path points to the place where the libyottadb.so is installed. Depends on the YottaDB installation.
This path needs also to be set in the LD_LIBRARY_PATH shell environment variable.

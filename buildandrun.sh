# To generate yottadb.nim
#nim c -r -d:futhark -d:nodeclguards --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" client.nim
# Already generated yottadb.nim
#nim c --forceBuild:on -r --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" client.nim
nim c -r --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" client.nim

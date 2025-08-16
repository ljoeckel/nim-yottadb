# To generate yottadb.nim
#nim c -r -d:futhark -d:nodeclguards --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" client.nim
# Already generated yottadb.nim
#nim c --forceBuild:on --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" client.nim
nim c --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" upcount.nim

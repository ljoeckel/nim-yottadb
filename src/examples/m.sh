rm -vf $ydb_dir/$ydb_rel/g/*.dat
mupip create
mupip set -journal=disable -region '*'
nim c --mm:markAndSweep -d:release -d:danger --threads:off --passL:"-L/usr/local/lib/yottadb/r202 -lyottadb" say_hello.nim
time ./say_hello

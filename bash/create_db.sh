rm -vf $ydb_dir/$ydb_rel/g/*.dat
mupip create
mupip set -journal=disable -region '*'

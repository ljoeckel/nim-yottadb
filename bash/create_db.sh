rm -vf $ydb_dir/$ydb_rel/g/*.dat
rm -vf $ydb_dir/$ydb_rel/g/*.mjl*
mupip create
mupip set -journal=enable -region '*'

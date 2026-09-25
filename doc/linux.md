sudo apt-get install libzstd-dev


When you see: Unhandled exception: -150377706 : YDB_ERR_GTMSECSHRPERM [YdbError]
   chmod 6755 /usr/local/lib/yottadb/r206/gtmsecshr

# Init YottaDB environment
.bashrc
. /usr/local/lib/yottadb/r206/ydb_env_set
export ydb_ci=/home/ljoeckel/.yottadb/r2.06_x86_64/r/callm.ci
export LD_LIBRARY_PATH=/usr/local/lib/yottadb/r206:${LD_LIBRARY_PATH}

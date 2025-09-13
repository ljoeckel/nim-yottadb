## Required Develpment Software
**sudo apt install build-essential libcurl4-openssl-dev cmake pkgconf**

## Install on ARM64 Architecture
```
sudo apt install --no-install-recommends clang llvm lld
sudo apt-get install --no-install-recommends file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates
```
```
ydb_distrib="https://gitlab.com/api/v4/projects/7957109/repository/tags"
ydb_tmpdir='tmpdir'
mkdir $ydb_tmpdir
wget -P $ydb_tmpdir ${ydb_distrib} 2>&1 1>${ydb_tmpdir}/wget_latest.log
ydb_version=`sed 's/,/\n/g' ${ydb_tmpdir}/tags | grep -E "tag_name|.pro.tgz" | grep -B 1 ".pro.tgz" | grep "tag_name" | sort -r | head -1 | cut -d'"' -f6`
git clone --depth 1 --branch $ydb_version https://gitlab.com/YottaDB/DB/YDB.git
cd YDB
```
```
mkdir build && cd build
cmake ..
make -j 2
make install
cd yottadb_r*
./ydbinstall --gui --utf8
```

***Append to .profile***
```bash
. /usr/local/lib/yottadb/r2.02/ydb_env_set
export ydb_ci=$HOME/.yottadb/r2.02_aarch64/r/callm.ci
```

Logout & Login again



## Install on x86 Architecture

m4ubt01:~$ **mkdir /tmp/tmp && cd /tmp/tmp && wget https://download.yottadb.com/ydbinstall.sh && chmod +x ydbinstall.sh**
```
--2025-09-13 17:53:05--  https://download.yottadb.com/ydbinstall.sh
Resolving download.yottadb.com (download.yottadb.com)... 3.77.103.135, 3.67.33.93
Connecting to download.yottadb.com (download.yottadb.com)|3.77.103.135|:443... connected.
HTTP request sent, awaiting response... 307 Temporary Redirect
Location: https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh [following]
--2025-09-13 17:53:05--  https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
Resolving gitlab.com (gitlab.com)... 172.65.251.78, 2606:4700:90:0:f22e:fbec:5bed:a9b9
Connecting to gitlab.com (gitlab.com)|172.65.251.78|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 75167 (73K) [text/plain]
Saving to: ‘ydbinstall.sh’

ydbinstall.sh                    100%[==========================================================>]  73.41K  --.-KB/s    in 0.008s
2025-09-13 17:53:05 (9.20 MB/s) - ‘ydbinstall.sh’ saved [75167/75167]
```

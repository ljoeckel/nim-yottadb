## Install on x86 Architecture
- Create a temporary directory and change to it, e.g.: mkdir /tmp/tmp ; cd /tmp/tmp

- Get the YottaDB install script: 
```bash
wget https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
```
- Make it executable: 
```bash
chmod +x ydbinstall.sh
```
- Run it (omit the --verbose option if you want less output). This command installs YottaDB under /usr/local/lib/.:
```bash
sudo ./ydbinstall.sh --verbose --utf8 --gui --octo
```
The `--gui` option installs a management dashboard, `--octo` the SQL layer if you want also SQL access.

The script has a plethora of installation options, which you will not use in the Acculturation Workshop. You can Query it to list the options with the --help option, e.g., `./ydbinstall.sh --help`.

`ydb -version` provides a detailed report on the YottaDB build, e.g.,


# Building YottaDB from source
- Install required development software:
```bash
sudo apt-get install --no-install-recommends build-essential libcurl4-openssl-dev cmake pkgconf file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates
```

## Install on ARM64 Architecture
If you want to run YottaDB under a virtual environment on a Mac(Mini) or Raspberry Pi, you need to build YottaDB from source. The setup i use is:
- MacMini M4 (2024)
- [UTM](https://mac.getutm.app/) Virtual Machine based on 
QEMU
- Ubuntu 24.04.3 LTS

```bash
sudo apt install --no-install-recommends clang llvm lld
sudo apt-get install --no-install-recommends file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates
```
clang, llvm and lld only if you want to CLANG as the compiler backend or YottaDB Rust support.

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
./ydbinstall --gui --utf8
```

## Configuration (.bashrc or .profile)
Add the YottadDB configuration script `ydb_env_set` to your startup scripts
```bash
. /usr/local/etc/ydb_env_set
export ydb_ci=$HOME/.yottadb/r2.02_aarch64/r/callm.ci
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/yottadb/r202
```
- Logout & Login again, then enter
```bash
ydb
```
The `YDB>` prompt should be visible.
Enter `Ctrl^D` to leave.

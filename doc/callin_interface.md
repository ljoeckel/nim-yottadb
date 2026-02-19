The YottaDB Call-In Interface allows normally to call methods defined in a *.ci file. 
For each method a signature has to be defined and for each method a corresponding call on the nim side is required.

This is overall not nessecary because nim-yottadb can read and write variables (local or global) which are read- and writeable on both sides.

Therefore the Call-In Interface supports only a simple call to a method name e.g. 'method1' which needs to be implemented in a M-File.

YottaDB requires a .ci file to be placed on a location defined in the environment variable **ydb_ci**. 

**.profile / .bashrc**
```bash
    . /usr/local/lib/yottadb/r202/ydb_env_set
    # x86
    export ydb_ci=$HOME/.yottadb/r2.02_x86_64/r/callm.ci
    # mac arm
    export ydb_ci=$HOME/.yottadb/r2.02_aarch64/r/callm.ci
```
**callm.ci**
```bash
    method1 :   method1^callm
```
To create the M-program:
- On the command line open the yottadb-shell with **ydb**
- Edit the callm.m program with **zedit "callm"**
- Compile and link with **zlink "callm"**
- To test, run **do method1^callm** in the ydb-shell.

**callm.m**
```
    callm
        quit

    method1
        ; VAR1 can be set in nim-yottadb with
        ;    Set: VAR1()="something"
        ; Do whatever you want here in M and create
        ; variables to passback the result to nim.
        set RESULT="MyResultFromWork"
        ; RESULT will be set as local variable
        ; and can be read in nim-yottadb with
        ;    let result = Get RESULT()
        quit
```
**test_ci.nim**
```nim
proc test_ydb_ci() =
    let tm = getTime()
    Set: VAR1()=tm             # set a YottaDB variable
    ydb_ci("method1")           # call CI method
    let result = Get RESULT() # Read variable
```


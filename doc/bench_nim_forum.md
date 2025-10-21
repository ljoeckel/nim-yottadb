```nim
proc myTxn(p0: pointer): cint {.cdecl.} =
  let i = $cast[cstring](p0)
  try:
    #ydb_set("^GBL", @[i], i)
    setvar: ^GBL(i)=i
  except:
    echo getCurrentExceptionMsg()
    return YDB_TP_ROLLBACK

  YDB_OK # commit the transaction

timed:
    for i in 0..10000000:
        let rc = ydb_tp(myTxn, $i)
        if rc != YDB_OK:
            echo "Error ", rc

#timed:
    #for i in 0..10000000:
        #setvar: ^GBL(i) = i 
        #ydb_set("^GBL", @[$i], $i)
        #discard ydb_get("^GBL", @[$i])
        #discard getvar ^GBL(i)
```

Empty database for each run created
```bash
          WriteAhead api.     api                                 dsl          new dsl
Operation   Log      1. run   2. run   threads Transaction  1. run  2. run  1. run   2. run
Set         Off      4456 ms  3917 ms    on                 3321 ms 2935 ms
Get         Off               3123 ms    on                         1898 ms
Set         On       4315 ms  4091 ms    on                 3298 ms 2897 ms
Get         On                3101 ms    on                         1849 ms

Set         Off      2394 ms  2044 ms    off                3291 ms 2860 ms  3099 ms 2767 ms
Get         Off               1380 ms    off                        1727 ms
Set         On       2402 ms  2076 ms    off                3232 ms 2858 ms
Get         On                1557 ms    off                        1725 ms

Set         On       3583 ms  2994 ms    off     yes        4717 ms 3756 ms
```
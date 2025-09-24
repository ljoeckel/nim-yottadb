Problems: 25.09.2025

-  Local variables can not use the .int or .float conversion
   let val: int = mylocal(4711).int # Will not compile
   Global variables work
   let val: int = ^myglobal(4711).int # works

-  doAssertRaises(YdbError): delexcl { ^SOMEGLOBAL } # ^ not raised for globals

-  Make timeout value setable for delexcl: ^LL("HAUS", timeout=100000)

- Consolidate and refactor transformation logic for DSL macros

- Change Syntax for incr: macro: for increments > 1
    let incrval = incr: ^CNT("TXID") = 10 
  Should be ^CNT("TXID", inc=10)

import std/[unittest]
import yottadb

proc testDeleteExcl() =
  # Global's / Special / Invalid names are not allowed
  doAssertRaises(YdbError): delexcl: { ^SOMEGLOBAL }
  doAssertRaises(YdbError): delexcl: { $SOMEGLOBAL }
  doAssertRaises(YdbError): delexcl: {
     ^SOMEGLOBAL,
     $SOMEGLOBAL,
  }
  
  # Set local variables
  setvar:
    DELTEST0("deltest")="deltest"
    DELTEST1="1"
    DELTEST2="2"
    DELTEST3="3"
    DELTEST4="4"
    DELTEST5="5"

  # Test if local variable is readable
  discard getvar  DELTEST0("deltest")
  discard getvar  DELTEST1
  
  # Remove all except the following
  delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard getvar  DELTEST1
  discard getvar  DELTEST3
  discard getvar  DELTEST5

  # Removed vars should raise exception on access
  doAssertRaises(YdbError): discard getvar  DELTEST2
  doAssertRaises(YdbError): discard getvar  DELTEST4

  # delete all variables
  delexcl: {}
  doAssertRaises(YdbError): discard getvar  DELTEST1

if isMainModule:
  test "DeleteExcl": testDeleteExcl()
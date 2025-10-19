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
  discard get: DELTEST0("deltest")
  discard get: DELTEST1
  
  # Remove all except the following
  delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard get: DELTEST1
  discard get: DELTEST3
  discard get: DELTEST5

  # Removed vars should raise exception on access
  doAssertRaises(YdbError): discard get: DELTEST2
  doAssertRaises(YdbError): discard get: DELTEST4

  # delete all variables
  delexcl: {}
  doAssertRaises(YdbError): discard get: DELTEST1

if isMainModule:
  test "DeleteExcl": testDeleteExcl()
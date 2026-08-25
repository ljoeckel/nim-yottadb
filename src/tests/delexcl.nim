import std/[unittest]
import yottadb

proc testDeleteExcl() =
  # Global's / Special / Invalid names are not allowed
  doAssertRaises(YdbError): Delexcl: { ^SOMEGLOBAL }
  doAssertRaises(YdbError): Delexcl: { $SOMEGLOBAL }
  doAssertRaises(YdbError): Delexcl: {
     ^SOMEGLOBAL,
     $SOMEGLOBAL,
  }
  
  # Set local variables
  Set:
    DELTEST0("deltest")="deltest"
    DELTEST1="1"
    DELTEST2="2"
    DELTEST3="3"
    DELTEST4="4"
    DELTEST5="5"

  # Test if local variable is readable
  discard Get DELTEST0("deltest")
  discard Get DELTEST1
  
  # Remove all except the following
  Delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard Get DELTEST1
  discard Get DELTEST3
  discard Get DELTEST5

  # Removed vars should be empty
  assert 0 == Data DELTEST2
  assert 0 == Data DELTEST2

  # delete all variables
  Delexcl: {}
  assert 0 == Data DELTEST1

if isMainModule:
  test "DeleteExcl": testDeleteExcl()

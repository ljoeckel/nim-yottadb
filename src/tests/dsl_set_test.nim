import std/times
import std/unittest
import std/strutils
import ../yottadb
import ../libs/utils

proc testDeleteExcl() =
  # Global's are not allowed
  #doAssertRaises(YdbDbError):
  #TODO: ^ not recognized
  delexcl: { ^SOMEGLOBAL }

  # Set local variables
  set:
    DELTEST0("deltest")="deltest"
    DELTEST1()="1"
    DELTEST2()="2"
    DELTEST3()="3"
    DELTEST4()="4"
    DELTEST5()="5"

  # Test if local variable is readable
  discard get: DELTEST0("deltest")
  discard get: DELTEST1()
  
  # Remove all except the following
  delexcl: 
    {
      DELTEST1, DELTEST3, DELTEST5 
    }

  # 1,3 and 5 should be there
  discard get: DELTEST1()
  discard get: DELTEST3()
  discard get: DELTEST5()

  # Removed vars should raise exception on access
  doAssertRaises(YdbDbError): discard get: DELTEST2()
  doAssertRaises(YdbDbError): discard get: DELTEST4()

  # delete all variables
  delexcl: {}
  doAssertRaises(YdbDbError): discard get: DELTEST1()

when isMainModule:
  testDeleteExcl()

import macros
dumpTree:
  v =  get: DELTEST5()
  assert get: DELTEST5() == "5"
    


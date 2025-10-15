import std/[times, os, unittest, strutils]
import yottadb
import utils

proc setupLL() =
  setvar:
    ^LL("HAUS")=""
    ^LL("HAUS", "ELEKTRIK")=""
    ^LL("HAUS", "ELEKTRIK", "DOSEN")=""
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "1") = "Telefondose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "2") = "Steckdose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "3") = "IP-Dose"
    ^LL("HAUS", "ELEKTRIK", "DOSEN", "4") = "KFZ-Dose"
    ^LL("HAUS", "ELEKTRIK", "KABEL")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "FARBEN")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "FIN")=""
    ^LL("HAUS", "ELEKTRIK", "KABEL", "STAERKEN")=""
    ^LL("HAUS", "ELEKTRIK", "SICHERUNGEN")=""
    ^LL("HAUS", "FLAECHEN", "RAUM1")=""
    ^LL("HAUS", "FLAECHEN", "RAUM2")=""
    ^LL("HAUS", "FLAECHEN", "RAUM2")=""
    ^LL("HAUS", "HEIZUNG")=""
    ^LL("HAUS", "HEIZUNG", "MESSGERAETE")=""
    ^LL("HAUS", "HEIZUNG", "ROHRE")=""
    ^LL("LAND")=""
    ^LL("LAND", "FLAECHEN")=""
    ^LL("LAND", "NUTZUNG")=""
    ^LL("ORT")=""

  setvar:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"


# ------------ Test procs ------------

proc testDel() =
  setvar: ^X(1)="hello"
  let s = get: ^X(1)
  assert "hello" == s
  delnode: ^X(1) # delete node
  doAssertRaises(YdbError): # expect exception because node removed
    discard get: ^X(1)
  
  # create a tree
  setvar: ^X(1,1)="hello"
  setvar: ^X(1,2)="world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  deltree: ^X(1)
  doAssertRaises(YdbError): # expect exception because node removed
    discard  get: ^X(1)


proc testData() =
  setvar:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  
  var dta = data: ^X(0)
  assert dta == YDB_DATA_UNDEF
  assert YDB_DATA_UNDEF == data ^x(0)
  assert YDB_DATA_VALUE_NODESC == data ^X(6)
  assert YDB_DATA_VALUE_DESC == data ^X(5)
  assert data(^X(7)) == YDB_DATA_NOVALUE_DESC


proc testSetGet() =
  let id = 123
  setvar:
    ^X(id, "s") = "pi"
    assert "pi" == get ^X(id, "s")
    ^X(id, "i", 4711) = 3
    assert 3 == get ^X(id, "i", 4711).int
    ^X(id, id, 4711, "i")=33
    assert 33 == get ^X(id, id, 4711, "i").int
    ^X(id, "f") = 3.1414
    assert get(^X(id, "f").float) == 3.1414
  
  # Set multiple items
  setvar:
      ^X(id, 1) = "pi" # First call to setxxx
      ^X(id, 2) = "pi" # Second call to setxxx
      ^X(id, 3) = "pi" # Third call to setxxx
      #^X(id, ...) = "pi" # ... call to setxxx

  for i in 1..<3:
    assert "pi" == get ^X(id, i)

  # Set loop
  for id in 0..<5:
    let tm = cpuTime()
    setvar: ^CUST(id, "Timestamp") = tm
    assert tm == get ^CUST(id, "Timestamp").float

  # Set with exception, too many subscripts
  doAssertRaises(YdbError):
    setvar: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)="xxx"
  # Should work without exception
  setvar: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)="xxx"
  let s2 = get: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
  assert "xxx" == s2


proc testIncrement() =  
  # Increment
  delnode ^CNT("TXID")
  delnode ^cnt
  assert 1 == increment ^CNT("TXID")
  let incrval = increment ^CNT("TXID", by=10)
  assert 11 == incrval
  assert 1 == increment ^cnt
  assert 11 == increment ^cnt(by=10)



proc testGetUpdate() =
  let subs = @["4711", "Acc123"]
  block:
    # Get and Update .int
    setvar: ^CUST(subs) = 1500
    var amount = get: ^CUST(subs).int
    amount += 1500
    setvar: ^CUST(subs) = amount
    let dbamount = get: ^CUST(subs).int  # read from db
    assert dbamount == amount

  block:
    # Get and Update .float
    setvar: ^CUST(subs) = 1500.50
    var amount = get: ^CUST(subs).float
    amount += 1500.50
    setvar: ^CUST(subs) = amount
    let dbamount = get: ^CUST(subs).float  # read from db
    assert dbamount == amount


proc testLock()  =
  # Set Locks
  lock:
    {
      ^LL("HAUS", "11"),
      ^LL("HAUS", "12"),
      ^LL("HAUS", "XX"), # not yet existent, but ok
    }
  var numOfLocks = getLockCountFromYottaDb()
  assert 3 == numOfLocks

  lock: {} # release all locks
  numOfLocks = getLockCountFromYottaDb()
  assert 0 == getLockCountFromYottaDb()
  

proc testLockIncrement() =
  lock: +^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 1
  lock: +^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 2
  lock: +^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  lock: -^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 2
  lock: -^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 1
  lock: -^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 0

  # Increment non existing subscript (Lock will be created)
  lock: +^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  lock: -^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Decrement non existing global (Lock will be created)
  lock: +^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  lock: -^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Increment 3 times same lock
  lock: +^ZZZZ("HAUS", 31)
  assert getLockCountFromYottaDb() == 1
  lock: +^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lock: +^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  # Decrement 3 times
  lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lock: -^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 0
  

proc testNextNode() =
  var rc:int
  var node:Subscripts

  (rc, node) = nextnode: ^LL()
  assert node == @["HAUS"]
  (rc, node) = nextnode: ^LL(node)
  assert node == @["HAUS", "ELEKTRIK"]
  (rc, node) = nextnode: ^LL("HAUS")
  assert node == @["HAUS", "ELEKTRIK"]
  (rc, node) = nextnode: ^LL(node)
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]

  (rc, node) = nextnode: ^LL("HAUS", "ELEKTRIK")
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]
  (rc, node) = nextnode: ^LL(node)  
  assert node == @["HAUS", "ELEKTRIK", "DOSEN", "1"]

  node = @["HAUS", "ELEKTRIK", "DOSEN"]
  (rc, node) = nextnode: ^LL(node)
  let val = get: ^LL(node)
  assert val == "Telefondose"
  let val2 = get: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
  assert val2 == "Telefondose"


proc testOrder() =
  # Go forwards
  block:
    var results: seq[string]
    var (rc, node) = nextnode: ^XX()
    while rc == YDB_OK:
      results.add(subscriptsToValue("^XX", node))
      (rc, node) = nextnode: ^XX(node)
    assert results.len == 6
    assert results[0] == "^XX(1,2,3)=123"
    assert results[1] == "^XX(1,2,3,7)=1237"
    assert results[2] == "^XX(1,2,4)=124"
    assert results[3] == "^XX(1,2,5,9)=1259"
    assert results[4] == "^XX(1,6)=16"
    assert results[5] == "^XX(B,1)=AB"

  # Go backwards
  block:
    var results: seq[string]
    var (rc, node) = prevnode: ^XX()
    while rc == YDB_OK:
      results.add(subscriptsToValue("^XX", node))
      (rc, node) = prevnode: ^XX(node)

    assert results.len == 6
    assert results[5] == "^XX(1,2,3)=123"
    assert results[4] == "^XX(1,2,3,7)=1237"
    assert results[3] == "^XX(1,2,4)=124"
    assert results[2] == "^XX(1,2,5,9)=1259"
    assert results[1] == "^XX(1,6)=16"
    assert results[0] == "^XX(B,1)=AB"


proc testNextCount() =
  var
    cnt = 0
    rc:int
    node:Subscripts

  (rc, node) = nextnode: ^LL()
  while rc == YDB_OK:
    inc(cnt)
    (rc, node) = nextnode: ^LL(node)
  assert cnt == 21


proc testPrevNode() =
  var (rc, node) = prevnode: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]
  (rc, node) = prevnode: ^LL("HAUS", "ELEKTRIK")
  assert node == @["HAUS"]
  (rc, node) = prevnode: ^LL("HAUS")
  assert node.len == 0
  (rc, node) = prevnode: ^LL()
  assert node == @["ORT"]
  (rc, node) = prevnode: ^LL("")
  assert node == @["ORT"]
  

  let (haus, elektrik, dosen) = ("HAUS", "ELEKTRIK", "DOSEN")
  (rc, node) = prevnode: ^LL(haus, elektrik, dosen, 1)
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]

  node = @["HAUS", "ELEKTRIK"]
  (rc, node) = prevnode: ^LL(node)
  assert node == @["HAUS"]


proc testNextSubscriptCaret() =
  var rc:int
  var node: Subscripts
  (rc, node) = nextsubscript: ^LL("HAUS", "ELEKTRIK")
  assert rc == YDB_OK and node == @["HAUS", "FLAECHEN"]
  (rc, node) = nextsubscript: ^LL("HAUS")
  assert rc == YDB_OK and node == @["LAND"]
  (rc, node) = nextsubscript: ^LL("")
  assert rc == YDB_OK and node == @["HAUS"]
  (rc, node) = nextsubscript: ^LL("ZZZZZZZ")
  assert rc == YDB_ERR_NODEEND and node == @[]

proc testPrevSubscriptCaret() =
  var rc:int
  var node: Subscripts
  (rc, node) = prevsubscript: ^LL("HAUS", "FLAECHEN")
  assert rc == YDB_OK and node == @["HAUS", "ELEKTRIK"]
  (rc, node) = prevsubscript: ^LL("LAND")
  assert rc == YDB_OK and node == @["HAUS"]
  (rc, node) = prevsubscript: ^LL("HAUS")
  assert rc == YDB_ERR_NODEEND and node == @[]

proc testNextSubscript(start: Subscripts, expected: Subscripts) =
  var rc:int
  var node: Subscripts = start 
  (rc, node) = nextsubscript: ^LL(node)
  assert rc == YDB_OK and node == expected

proc testPrevSubscript(start: Subscripts, expected: Subscripts) =
  var rc:int
  var node: Subscripts = start 
  (rc, node) = prevsubscript: ^LL(node)
  if rc == YDB_ERR_NODEEND:
    assert node == expected
  else:
    assert rc == YDB_OK and node == expected

proc testNextSubsIter(start: Subscripts, expected: Subscripts) =
  var node: Subscripts= start
  var lastnode: Subscripts
  var rc = YDB_OK
  while rc == YDB_OK:
    lastnode = node
    (rc, node) = nextsubscript: ^LL(node)
  assert lastnode == expected

proc testSpecialVars() =
  # Get
  let zversion = get: $ZVERSION
  assert zversion.len > 0 and zversion.startsWith("GT.M")

  # Set
  setvar: $ZMAXTPTIME()="2"
  let zmaxtptime = get: $ZMAXTPTIME
  assert zmaxtptime == "2"

proc testDeleteExcl() =
  # Global's / Special / Invalid names are not allowed
  doAssertRaises(YdbError): delexcl { ^SOMEGLOBAL }
  doAssertRaises(YdbError): delexcl { $SOMEGLOBAL }
  doAssertRaises(YdbError): delexcl { !SOMEGLOBAL }
  doAssertRaises(YdbError): delexcl {
     ^SOMEGLOBAL,
     $SOMEGLOBAL,
     !SOMEGLOBAL
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

proc test_ydb_ci() =
  let ydb_ci = getEnv("ydb_ci")
  if ydb_ci.isEmptyOrWhitespace:
    echo "Could not find environment variable 'ydb_ci' to set the callin table. *** Test ignored ***"
    return
  if not fileExists(ydb_ci):
    echo "Could not find callin file ", ydb_ci, " *** Test ignored ***"
    return

  let tm = getTime()
  setvar: VAR1()=tm # pass this callm.m
  ydb_ci: "method1"
  var result = get: RESULT  # Read the YottaDB variable from the Callin
  assert $tm == result

  ydb_ci: "method2"
  result = get: RESULT
  assert "TheResultFrom YDB" == result


proc test() =
  suite "YottaDB DSL Tests":
    test "set": testSetGet()
    test "increment": testIncrement()
    test "getUpdate": testGetUpdate()
    test "data": testData()
    test "testDel": testDel()
    test "testDeleteLocalExcl": testDeleteExcl()
    test "locks": testLock()
    test "lockincrement": testLockIncrement()
    test "ydb_node_next": testNextNode()
    test "order": testOrder()
    test "ydb_node_next count": testNextCount()
    test "ydb_node_previous": testPrevNode()
    test "testNextSubscript":
      test "testNextSubscript1": testNextSubscript(@["HAUS", "ELE..."], @["HAUS", "ELEKTRIK"])
      test "testNextSubscript2": testNextSubscript(@["HAUS", "ELEKTRIK"], @["HAUS", "FLAECHEN"])
      test "testNextSubscript3": testNextSubscript(@["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "DOSEN"])
      test "testNextSubscript4": testNextSubscript(@["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "1"])
    test "testNextSubsIter":
      test "testNextSubsIter1": testNextSubsIter(@[], @["ORT"])
      test "testNextSubsIter2": testNextSubsIter(@[""], @["ORT"])
      test "testNextSubsIter3": testNextSubsIter(@["H.."], @["ORT"])
      test "testNextSubsIter4": testNextSubsIter(@["HAUS"], @["ORT"])
      test "testNextSubsIter5": testNextSubsIter(@["HAUS", "ELE..."], @["HAUS", "HEIZUNG"])
      test "testNextSubsIter6": testNextSubsIter(@["HAUS", "ELEKTRIK", ""], @["HAUS", "ELEKTRIK", "SICHERUNGEN"])
      test "testNextSubsIter7": testNextSubsIter(@["HAUS", "ELEKTRIK", "DOSEN", ""], @["HAUS", "ELEKTRIK", "DOSEN", "4"])
    test "testPrevSubscript":
      test "testPrevSubscript": testPrevSubscript(@["HAUS", "FLAECHEN"], @["HAUS", "ELEKTRIK"])
      test "testPrevSubscript": testPrevSubscript(@["HAUS", "FLA."], @["HAUS", "ELEKTRIK"])      
      test "testPrevSubscript": testPrevSubscript(@["HAUS", "ELEKTRIK"], @[])
      test "testPrevSubscript": testPrevSubscript(@["HAUS", "ELEKTRIK", "DOSEN", "9999"], @["HAUS", "ELEKTRIK", "DOSEN", "4"])
    test "SubscriptCaret":
      test "testNextSubscriptCaret": testNextSubscriptCaret()
      test "testPrevSubscriptCaret": testPrevSubscriptCaret()
    test "Misc":
      test "SpecialVars": testSpecialVars()
      test "DeleteExcl": testDeleteExcl()
      test "Call-In Interface": test_ydb_ci()


when isMainModule:
  setupLL()
  timed "test" : test()

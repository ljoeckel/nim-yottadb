import std/[times, os, unittest, strutils]
import ../yottadb
import ../libs/utils

proc setupLL() =
  set:
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

  set:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"


# ------------ Test procs ------------

proc testDel() =
  set: ^X(1)="hello"
  let s = get: ^X(1)
  assert "hello" == s
  delnode: ^X(1) # delete node
  doAssertRaises(YdbDbError): # expect exception because node removed
    discard get: ^X(1)
  
  # create a tree
  set: ^X(1,1)="hello"
  set: ^X(1,2)="world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  deltree: ^X(1)
  doAssertRaises(YdbDbError): # expect exception because node removed
    discard  get: ^X(1)


proc testData() =
  set:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  
  var dta = data: ^X(0)
  assert YdbData(dta) == NO_DATA_NO_SUBTREE
  dta = data: ^X(6)
  assert YdbData(dta) == DATA_NO_SUBTREE
  dta = data: ^X(5)
  assert YdbData(dta) == DATA_AND_SUBTREE
  dta = data: ^X(7)
  assert YdbData(dta) == NO_DATA_WITH_SUBTREE


proc testSetGet() =
  let id = 1
  # Set
  set: ^X(id, "s") = "pi"
  let s = get: ^X(id, "s")
  assert s == "pi"

  set: ^X(id, "i") = 3
  let i = get: ^X(id, "i").int
  assert i == 3

  set: ^X(id, "f") = 3.1414
  let f = get: ^X(id, "f").float
  assert f == 3.1414
  
  # Set multiple items
  set:
      ^X(id, 1) = "pi" # First call to setxxx
      ^X(id, 2) = "pi" # Second call to setxxx
      ^X(id, 3) = "pi" # Third call to setxxx
      #^X(id, ...) = "pi" # ... call to setxxx

  for i in 1..<3:
    let s = get: ^X(id, i)
    assert "pi" == s

  # Set loop
  for id in 0..<5:
    let tm = cpuTime()
    set: ^CUST(id, "Timestamp") = tm
    let s = get: ^CUST(id, "Timestamp").float
    assert s == tm

  # Set with exception, too many subscripts
  doAssertRaises(YdbDbError):
    set: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)="xxx"
  # Should work without exception
  set: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)="xxx"
  let s2 = get: ^CUST(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
  assert "xxx" == s2


proc testIncrement() =  
  # Increment
  delnode: ^CNT("TXID")
  var incrval = incr: ^CNT("TXID")
  assert 1 == incrval
  incrval = incr: ^CNT("TXID") = 10
  assert 11 == incrval


proc testGetUpdate() =
  let subs = @["4711", "Acc123"]
  block:
    # Get and Update .int
    set: ^CUST(subs) = 1500
    var amount = get: ^CUST(subs).int
    amount += 1500
    set: ^CUST(subs) = amount
    let dbamount = get: ^CUST(subs).int  # read from db
    assert dbamount == amount

  block:
    # Get and Update .float
    set: ^CUST(subs) = 1500.50
    var amount = get: ^CUST(subs).float
    amount += 1500.50
    set: ^CUST(subs) = amount
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
  lockincr: ^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 1
  lockincr: ^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 2
  lockincr: ^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  lockdecr: ^LL("HAUS", "FLAECHEN")
  assert getLockCountFromYottaDb() == 2
  lockdecr: ^LL("HAUS", "HEIZUNG")
  assert getLockCountFromYottaDb() == 1
  lockdecr: ^LL("HAUS", "ELEKTRIK")
  assert getLockCountFromYottaDb() == 0

  # Increment non existing subscript (Lock will be created)
  lockincr: ^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  lockdecr: ^LL("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Decrement non existing global (Lock will be created)
  lockincr: ^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 1
  lockdecr: ^ZZZZ("HAUS", "XXXXXXX")
  assert getLockCountFromYottaDb() == 0

  # Increment 3 times same lock
  lockincr: ^ZZZZ("HAUS", 31)
  assert getLockCountFromYottaDb() == 1
  lockincr: ^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lockincr: ^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  # Decrement 3 times
  lockdecr: ^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lockdecr: ^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 1
  lockdecr: ^ZZZZ("HAUS", 31)  
  assert getLockCountFromYottaDb() == 0
  

proc testNextNode() =
  var rc:int
  var node:Subscripts

  (rc, node) = nextn: ^LL()
  assert node == @["HAUS"]
  (rc, node) = nextn: ^LL(node)
  assert node == @["HAUS", "ELEKTRIK"]

  (rc, node) = nextn: ^LL("HAUS")
  assert node == @["HAUS", "ELEKTRIK"]
  (rc, node) = nextn: ^LL(node)
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]

  (rc, node) = nextn: ^LL("HAUS", "ELEKTRIK")
  assert node == @["HAUS", "ELEKTRIK", "DOSEN"]
  (rc, node) = nextn: ^LL(node)  
  assert node == @["HAUS", "ELEKTRIK", "DOSEN", "1"]

  node = @["HAUS", "ELEKTRIK", "DOSEN"]
  (rc, node) = nextn: ^LL(node)
  let val = get: ^LL(node)
  assert val == "Telefondose"
  let val2 = get: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
  assert val2 == "Telefondose"


proc testOrder() =
  # Go forwards
  block:
    var results: seq[string] = @[]
    var rc:int = YDB_OK
    var node:Subscripts = @[]
    while rc == YDB_OK:
      (rc, node) = nextn: ^XX(node)
      if rc == YDB_OK:
        results.add(subscriptsToValue("^XX", node))
    assert results.len == 6
    assert results[0] == "^XX(1,2,3)=123"
    assert results[1] == "^XX(1,2,3,7)=1237"
    assert results[2] == "^XX(1,2,4)=124"
    assert results[3] == "^XX(1,2,5,9)=1259"
    assert results[4] == "^XX(1,6)=16"
    assert results[5] == "^XX(\"B\",1)=AB"

  # Go backwards
  block:
    var results: seq[string] = @[]
    var rc:int = YDB_OK
    var node:Subscripts = @["B","9999999999"]
    while rc == YDB_OK:
      (rc, node) = prevn: ^XX(node)
      if rc == YDB_OK:
        results.add(subscriptsToValue("^XX", node))
    assert results.len == 6
    assert results[5] == "^XX(1,2,3)=123"
    assert results[4] == "^XX(1,2,3,7)=1237"
    assert results[3] == "^XX(1,2,4)=124"
    assert results[2] == "^XX(1,2,5,9)=1259"
    assert results[1] == "^XX(1,6)=16"
    assert results[0] == "^XX(\"B\",1)=AB"


proc testNextCount() =
  var
    cnt = 0
    rc:int
    node:Subscripts

  (rc, node) = nextn: ^LL()
  while rc == YDB_OK:
    inc(cnt)
    (rc, node) = nextn: ^LL(node)
  assert cnt == 21


proc testPrevNode() =
  var rc:int
  var node:Subscripts
  block:
    (rc, node) = prevn: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
    assert node == @["HAUS", "ELEKTRIK", "DOSEN"]

  block:
    (rc, node) = prevn: ^LL("HAUS", "ELEKTRIK")
    assert node == @["HAUS"]

  block:
    (rc, node) = prevn: ^LL("HAUS")
    assert node.len == 0

  block:
    (rc, node) = prevn: ^LL()
    assert node.len == 0

proc testNextSubscriptCaret() =
  var rc:int
  var node: Subscripts
  (rc, node) = nextsub: ^LL("HAUS", "ELEKTRIK")
  assert rc == YDB_OK and node == @["HAUS", "FLAECHEN"]
  (rc, node) = nextsub: ^LL("HAUS")
  assert rc == YDB_OK and node == @["LAND"]
  (rc, node) = nextsub: ^LL("")
  assert rc == YDB_OK and node == @["HAUS"]
  (rc, node) = nextsub: ^LL("ZZZZZZZ")
  assert rc == YDB_ERR_NODEEND and node == @[""]

proc testPrevSubscriptCaret() =
  var rc:int
  var node: Subscripts
  (rc, node) = prevsub: ^LL("HAUS", "FLAECHEN")
  assert rc == YDB_OK and node == @["HAUS", "ELEKTRIK"]
  (rc, node) = prevsub: ^LL("LAND")
  assert rc == YDB_OK and node == @["HAUS"]
  (rc, node) = prevsub: ^LL("HAUS")
  assert rc == YDB_ERR_NODEEND and node == @[""]

proc testNextSubscript(start: Subscripts, expected: Subscripts) =
  var rc:int
  var node: Subscripts = start 
  (rc, node) = nextsub: ^LL(node)
  assert rc == YDB_OK and node == expected

proc testPrevSubscript(start: Subscripts, expected: Subscripts) =
  var rc:int
  var node: Subscripts = start 
  (rc, node) = prevsub: ^LL(node)
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
    (rc, node) = nextsub: ^LL(node)
  assert lastnode == expected

proc testSpecialVars() =
  # Get
  let zversion = get: $ZVERSION
  assert zversion.len > 0 and zversion.startsWith("GT.M")

  # Set
  set: $ZMAXTPTIME()="2"
  let zmaxtptime = get: $ZMAXTPTIME
  assert zmaxtptime == "2"

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

proc test_ydb_ci() =
  let ydb_ci = getEnv("ydb_ci")
  if ydb_ci.isEmptyOrWhitespace:
    echo "Could not find environment variable 'ydb_ci' to set the callin table."
    echo "*** Test ignored ***"
    return
  if not fileExists(ydb_ci):
    echo "Could not find callin file ", ydb_ci
    echo "*** Test ignored ***"
    return

  let tm = getTime()
  set: VAR1()=tm                      # set a YottaDB variable
  ydb_ci: "method1"
  let result = get: RESULT()  # Read the YottaDB variable from the Callin
  assert $tm == result



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
      test "testPrevSubscript": testPrevSubscript(@["HAUS", "ELEKTRIK"], @["HAUS", ""])
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
  timed:
    test()

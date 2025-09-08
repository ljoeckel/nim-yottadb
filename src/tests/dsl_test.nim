import std/times
import std/unittest
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


# ------------ Test procs ------------

proc testDel() =
  set: ^X(1)="hello"
  let s = get: ^X(1)
  assert "hello" == s
  var rc = delnode: ^X(1) # delete node
  doAssertRaises(YdbDbError): # expect exception because node removed
    let v = get: ^X(1)
  
  # create a tree
  set: ^X(1,1)="hello"
  set: ^X(1,2)="world"
  let dta = data: ^X(1) 
  assert 10 == dta # Expect no data but subtree
  rc = deltree: ^X(1)
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
  let s2 = get: ^CUST(id, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)
  assert "xxx" == s2


proc testIncrement() =  
  # Increment
  let rc = delnode: ^CNT("TXID")
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
  

proc testNextNode() =
  block:
    var node = nextn: ^LL()
    assert node[0] == "HAUS"
    node = nextn: ^LL(node)
    assert (node[0] == "HAUS" and node[1] == "ELEKTRIK")

  block:
    var node = nextn: ^LL("HAUS")
    assert (node[0] == "HAUS" and node[1] == "ELEKTRIK")
    node = nextn: ^LL(node)
    assert (node[0] == "HAUS" and node[1] == "ELEKTRIK" and node[2] == "DOSEN")

  block:
    var node = nextn: ^LL("HAUS", "ELEKTRIK")
    assert (node[0] == "HAUS" and node[1] == "ELEKTRIK" and node[2] == "DOSEN")
    node = nextn: ^LL(node)  
    assert (node[0] == "HAUS" and node[1] == "ELEKTRIK" and node[2] == "DOSEN" and node[3] == "1")

  block:
    var node:Subscripts = @["HAUS", "ELEKTRIK", "DOSEN"]
    node = nextn: ^LL(node)
    let val = get: ^LL(node)
    assert val == "Telefondose"
    let val2 = get: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
    assert val2 == "Telefondose"


proc testNextCount() =
  var cnt = 0
  var node:Subscripts = @[]
  while true:
    node = nextn: ^LL(node)
    if node.len == 0: break
    inc(cnt)
    let val = get: ^LL(node)
  assert cnt == 20

proc testPrevNode() =
  block:
    var node = prevn: ^LL("HAUS", "ELEKTRIK", "DOSEN", "1")
    assert node.len == 3 and node[0] == "HAUS" and node[1] == "ELEKTRIK" and node[2] == "DOSEN"

  block:
    var node = prevn: ^LL("HAUS", "ELEKTRIK")
    assert node.len == 1 and node[0] == "HAUS"

  block:
    var node = prevn: ^LL("HAUS")
    assert node.len == 0

  block:
    var node = prevn: ^LL()
    assert node.len == 0


proc test(): int =
  suite "YottaDB DSL Tests":
    test "set": testSetGet()
    test "increment": testIncrement()
    test "getUpdate": testGetUpdate()
    test "data": testData()
    test "testDel": testDel()
    test "locks": testLock()
    test "nextNode": testNextNode()
    test "nextNode count": testNextCount()
    test "prevNode": testPrevNode()


when isMainModule:
  setupLL()
  let (ms, rc) = timed:
    test()
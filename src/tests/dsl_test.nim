import std/[unittest]
import yottadb
import ydbutils


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

  setvar:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  

# ------------ Test procs ------------



proc testData() =
  var dta = data: ^X(0)
  assert dta == YDB_DATA_UNDEF
  assert YDB_DATA_UNDEF == data ^x(0)
  assert YDB_DATA_VALUE_NODESC == data ^X(6)
  assert YDB_DATA_VALUE_DESC == data ^X(5)
  assert data(^X(7)) == YDB_DATA_NOVALUE_DESC




proc testIncrement() =  
  # Increment
  delnode:
    ^CNT("TXID")
    ^cnt
  assert 1 == increment ^CNT("TXID")
  let incrval = increment (^CNT("TXID"), by=10)
  assert 11 == incrval
  assert 1 == increment ^cnt
  assert 11 == increment (^cnt, by=10)





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
  var node:string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  (rc, node) = nextnode: ^LL
  assert node == "^LL(HAUS)"

  # as seq[string]
  (rc, nodeseq) = nextnode: @node.seq
  assert nodeseq == @["HAUS", "ELEKTRIK"]

  # use seq[string] as keys
  (rc, node) = nextnode: ^LL(nodeseq)
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"

  (rc, node) = nextnode: @node
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert "Telefondose" == get @node

proc testPrevNode() =
  var rc:int
  var node:string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  (rc, node) = prevnode: ^LL
  assert node == "^LL(ORT)"

  # as seq[string]
  (rc, nodeseq) = prevnode: @node.seq
  assert nodeseq == @["LAND", "NUTZUNG"]

  # use seq[string] as keys
  (rc, node) = prevnode: ^LL(nodeseq)
  assert node == "^LL(LAND,FLAECHEN)"

  (rc, node) = prevnode: @node
  assert node == "^LL(LAND)"


proc testOrder() =
  # Go forwards
  block:
    var results: seq[string]
    var (rc, node) = nextnode: ^XX
    while rc == YDB_OK:
      results.add(node)
      (rc, node) = nextnode: @node
      
    assert results.len == 6
    assert results[0] == "^XX(1,2,3)"
    assert results[1] == "^XX(1,2,3,7)"
    assert results[2] == "^XX(1,2,4)"
    assert results[3] == "^XX(1,2,5,9)"
    assert results[4] == "^XX(1,6)"
    assert results[5] == "^XX(B,1)"

  # Go backwards
  block:
    var results: seq[string]
    var (rc, node) = prevnode: ^XX
    while rc == YDB_OK:
      results.add(node)
      (rc, node) = prevnode: @node

    assert results.len == 6
    assert results[5] == "^XX(1,2,3)"
    assert results[4] == "^XX(1,2,3,7)"
    assert results[3] == "^XX(1,2,4)"
    assert results[2] == "^XX(1,2,5,9)"
    assert results[1] == "^XX(1,6)"
    assert results[0] == "^XX(B,1)"


proc testNextCount() =
  var
    cnt = 0
    rc:int
    node:string

  (rc, node) = nextnode: ^LL()
  while rc == YDB_OK:
    inc(cnt)
    (rc, node) = nextnode: @node
  assert cnt == 21


proc testNextSubscript() =
  var (rc2, node2) = nextsubscript @"^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert node2 == "^LL(HAUS,ELEKTRIK,DOSEN,2)"
  var (rc3, node3) = nextsubscript @"^LL(HAUS,ELEKTRIK,DOSEN,1)".seq
  assert node3 == @["HAUS", "ELEKTRIK", "DOSEN", "2"]


proc testPrevSubscript() =
  var (rc, node) = prevsubscript @"^LL(HAUS,ELEKTRIK,DOSEN,2)"
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  (rc, node) = prevsubscript @node
  assert node == ""
  (rc, node) = prevsubscript @"^LL(HAUS,ELEKTRIK,)"
  assert node == "^LL(HAUS,ELEKTRIK,SICHERUNGEN)"
  (rc, node) = prevsubscript @node
  assert node == "^LL(HAUS,ELEKTRIK,KABEL)"
  (rc, node) = prevsubscript @node
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"


when isMainModule:
  setupLL()
  test "increment": testIncrement()
  test "data": testData()
  test "locks": testLock()
  test "lockincrement": testLockIncrement()
  test "ydb_node_next": testNextNode()
  test "ydb_node_previous": testPrevNode()
  test "order": testOrder()
  test "ydb_node_next count": testNextCount()
  test "testNextSubscript": testNextSubscript()
  test "testPrevSubscript": testPrevSubscript()

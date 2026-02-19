import std/[unittest]
import yottadb


proc setupLL() =
  Set:
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

  Set:
    ^XX(1,2,3)=123
    ^XX(1,2,3,7)=1237
    ^XX(1,2,4)=124
    ^XX(1,2,5,9)=1259
    ^XX(1,6)=16
    ^XX("B",1)="AB"

  Set:
    ^X(1, "A")="1.A"
    ^X(3)=3
    ^X(4)="B"
    ^X(5)="F"
    ^X(5,1)="D"
    ^X(5,2)="E"
    ^X(6)="G"
    ^X(7,3)="H"
  

# ------------ Test procs ------------

proc testQuery() =
  var node, value: string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  node = Query: ^LL
  assert node == "^LL(HAUS)"

  # as seq[string]
  nodeseq = Query @node.keys
  assert nodeseq == @["HAUS", "ELEKTRIK"]

  # use seq[string] as keys
  node = Query ^LL(nodeseq)
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"

  node = Query @node
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert "Telefondose" == Get @node

  value = Query @node.val
  assert "Steckdose" == value

  (node, value) = Query @node.kv
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,2)"
  assert "Steckdose" == value


proc testQueryReverse() =
  var node:string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  node = Query ^LL.reverse
  assert node == "^LL(ORT)"

  # as seq[string]
  nodeseq = Query @node.keys.reverse
  assert nodeseq == @["LAND", "NUTZUNG"]

  # use seq[string] as keys
  node = Query ^LL(nodeseq).reverse
  assert node == "^LL(LAND,FLAECHEN)"

  node = Query @node.reverse
  assert node == "^LL(LAND)"

  node = "^LL(HAUS,ELEKTRIK,DOSEN,2)"
  var value = Query @node.val.reverse
  assert "Telefondose" == value

  (node, value) = Query @node.kv.reverse
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert "Telefondose" == value


proc testQuery2() =
  let expectedKeys = @["^XX(1,2,3)", "^XX(1,2,3,7)", "^XX(1,2,4)", "^XX(1,2,5,9)", "^XX(1,6)", "^XX(B,1)"]
  let expectedKeysReverse = @["^XX(B,1)","^XX(1,6)","^XX(1,2,5,9)","^XX(1,2,4)","^XX(1,2,3,7)","^XX(1,2,3)"]

  # Go forwards with 'Query'
  block:
    var results: seq[string]
    var node = Query ^XX
    while node.len > 0:
      results.add(node)
      node = Query @node

    assert results.len == 6
    assert results == expectedKeys

  # Go forwards with 'QueryItr'
  block:
    var results: seq[string]
    for node in QueryItr ^XX:
      results.add(node)

    assert results.len == 6
    assert results == expectedKeys

  # Go backwards with Query
  block:
    var results: seq[string]
    var node = Query ^XX.reverse
    while node.len > 0:
      results.add(node)
      node = Query @node.reverse
    assert results.len == 6
    assert expectedKeysReverse == results

  # Go backwards with 'QueryItr'
  block:
    var results: seq[string]
    for node in QueryItr ^XX.reverse:
      results.add(node)
    assert results.len == 6
    assert expectedKeysReverse == results

proc testQueryCount() =
  var cnt = 0
  for node in QueryItr ^LL:
    inc(cnt)
  assert cnt == 21

  cnt = Query ^LL.count
  assert cnt == 21

proc testNextOrder() =
  var node2 = Order @"^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert node2 == "2"
  var node3 = Order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".keys
  assert node3 == @["HAUS", "ELEKTRIK", "DOSEN", "3"]


proc testPrevOrder() =
  var node = Order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".reverse
  assert node == "1"
  
  node = Order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".key.reverse
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"

  node = Order @node.reverse
  assert node == ""
  
  node = Order @"^LL(HAUS,ELEKTRIK,)".reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,SICHERUNGEN)"
  
  node = Order @node.reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,KABEL)"
  
  node = Order @node.reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"


when isMainModule:
  setupLL()
  test "Query": testQuery()
  test "Query reverse": testQueryReverse()
  test "Query": testQuery2()
  test "Query count": testQueryCount()
  test "testNextOrder": testNextOrder()
  test "testPrevOrder": testPrevOrder()

import std/[unittest]
import yottadb


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

proc testQuery() =
  var node, value: string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  node = query: ^LL
  assert node == "^LL(HAUS)"

  # as seq[string]
  nodeseq = query @node.keys
  assert nodeseq == @["HAUS", "ELEKTRIK"]

  # use seq[string] as keys
  node = query ^LL(nodeseq)
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"

  node = query @node
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert "Telefondose" == getvar @node

  value = query @node.val
  assert "Steckdose" == value

  (node, value) = query @node.kv
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,2)"
  assert "Steckdose" == value


proc testQueryReverse() =
  var node:string
  var nodeseq: seq[string]

  # as full qualified global/subscript
  node = query ^LL.reverse
  assert node == "^LL(ORT)"

  # as seq[string]
  nodeseq = query @node.keys.reverse
  assert nodeseq == @["LAND", "NUTZUNG"]

  # use seq[string] as keys
  node = query ^LL(nodeseq).reverse
  assert node == "^LL(LAND,FLAECHEN)"

  node = query @node.reverse
  assert node == "^LL(LAND)"

  node = "^LL(HAUS,ELEKTRIK,DOSEN,2)"
  var value = query @node.val.reverse
  assert "Telefondose" == value

  (node, value) = query @node.kv.reverse
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert "Telefondose" == value


proc testQuery2() =
  let expectedKeys = @["^XX(1,2,3)", "^XX(1,2,3,7)", "^XX(1,2,4)", "^XX(1,2,5,9)", "^XX(1,6)", "^XX(B,1)"]
  let expectedKeysReverse = @["^XX(B,1)","^XX(1,6)","^XX(1,2,5,9)","^XX(1,2,4)","^XX(1,2,3,7)","^XX(1,2,3)"]

  # Go forwards with 'query'
  block:
    var results: seq[string]
    var node = query ^XX
    while node.len > 0:
      results.add(node)
      node = query @node

    assert results.len == 6
    assert results == expectedKeys

  # Go forwards with 'queryItr'
  block:
    var results: seq[string]
    for node in queryItr ^XX:
      results.add(node)

    assert results.len == 6
    assert results == expectedKeys

  # Go backwards with query
  block:
    var results: seq[string]
    var node = query ^XX.reverse
    while node.len > 0:
      results.add(node)
      node = query @node.reverse
    assert results.len == 6
    assert expectedKeysReverse == results

  # Go backwards with 'queryItr'
  block:
    var results: seq[string]
    for node in queryItr ^XX.reverse:
      results.add(node)
    assert results.len == 6
    assert expectedKeysReverse == results

proc testQueryCount() =
  var cnt = 0
  for node in queryItr ^LL:
    inc(cnt)
  assert cnt == 21

  cnt = query ^LL.count
  assert cnt == 21

proc testNextOrder() =
  var node2 = order @"^LL(HAUS,ELEKTRIK,DOSEN,1)"
  assert node2 == "2"
  var node3 = order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".keys
  assert node3 == @["HAUS", "ELEKTRIK", "DOSEN", "3"]


proc testPrevOrder() =
  var node = order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".reverse
  assert node == "1"
  
  node = order @"^LL(HAUS,ELEKTRIK,DOSEN,2)".key.reverse
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN,1)"

  node = order @node.reverse
  assert node == ""
  
  node = order @"^LL(HAUS,ELEKTRIK,)".reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,SICHERUNGEN)"
  
  node = order @node.reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,KABEL)"
  
  node = order @node.reverse.key
  assert node == "^LL(HAUS,ELEKTRIK,DOSEN)"


when isMainModule:
  setupLL()
  test "query": testQuery()
  test "query reverse": testQueryReverse()
  test "query": testQuery2()
  test "query count": testQueryCount()
  test "testNextOrder": testNextOrder()
  test "testPrevOrder": testPrevOrder()

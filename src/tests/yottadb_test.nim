import std/[strformat, unittest]
import yottadb
import ydbutils

const
  MAX = 10

proc setupLL() =
  Kill:
    ^LL
    ^LJ
    
  let global = "^LL"
  const paths = [
    @["HAUS"],
    @["HAUS", "ELEKTRIK"],
    @["HAUS", "ELEKTRIK", "DOSEN"],
    @["HAUS", "ELEKTRIK", "KABEL"],
    @["HAUS", "ELEKTRIK", "KABEL", "FARBEN"],
    @["HAUS", "ELEKTRIK", "KABEL", "STAERKEN"],
    @["HAUS", "ELEKTRIK", "SICHERUNGEN"],
    @["HAUS", "FLAECHEN", "RAUM1"],
    @["HAUS", "FLAECHEN", "RAUM2"],
    @["HAUS", "HEIZUNG"],
    @["HAUS", "HEIZUNG", "MESSGERAETE"],
    @["HAUS", "HEIZUNG", "ROHRE"],
    @["LAND"],
    @["LAND", "FLAECHEN"],
    @["LAND", "NUTZUNG"],
    @["ORT"],
  ]
  for path in paths:
    var k = initYdbKey(global, path)
    ydb_set(k, "")

  const dosen = [
    ("1", "Telefondose"),
    ("2", "Steckdose"),
    ("3", "IP-Dose"),
    ("4", "KFZ-Dose"),
  ]
  for (sub, value) in dosen:
    var k = initYdbKey(global, "HAUS", "ELEKTRIK", "DOSEN", sub)
    ydb_set(k, value)


# ------------- Test cases are here ---------------------
# Write ^X(0..1000000) in 800ms. 
proc simpleSet(global: string, cnt: int) =
  var k = initYdbKey(global)
  for i in 0..cnt:
    k.setSub(0, i)
    ydb_set(k, $i)

# Read ^X(0..100000000) in 600ms. 
proc simpleGet(global: string, cnt: int) =
  var k = initYdbKey(global)
  for i in 0..cnt:
    k.setSub(0, i)
    assert $i == ydb_get(k)

# Delete ^X(0..100000000) in 550ms. 
proc simpleDelete(global: string, cnt: int) =
  var k = initYdbKey(global)
  for i in 0..cnt:
    k.setSub(0, i)
    ydb_delete(k, YDB_DEL_NODE)

proc setWithError() =
  # set with empty global
  doAssertRaises(YdbError): # -151027762, %YDB-E-INVVARNAME
    var k = initYdbKey("", "x")
    ydb_set(k, "x")
  
  # Write global without subscript -> ^x="x"
  var k = initYdbKey("^x")
  ydb_set(k, "x")
  assert "x" == ydb_get(k)

  # Write global without value
  k.setSub(0, "x")
  ydb_set(k, "")
  assert "" == ydb_get(k)



proc testYdbVar() =
  for i in 0..MAX:
    discard newYdbVar("^LJ", @["LAND", "ORT", $i], $i)

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    assert v.value == $i
    # update db with new value
    v[] = "New " & v.value

  for i in 0..MAX:
    var v = newYdbVar("^LJ", @["LAND", "ORT", $i])
    assert v.value == "New " & $i

proc testYdbSetGet() =
  var k = initYdbKey("^LJ", "LAND", "ORT")
  for i in 0..MAX:
    let value = fmt"Hello Lothar Jöckel {i} aus der Schweiz"
    k.setSub(2, i)
    ydb_set(k, value)
    assert value == ydb_get(k)
    k.setSub(3, i)
    ydb_set(k, value)
    assert value == ydb_get(k)
    k.setSubsLen(3)

  var s = initYdbKey("^LJ", "LAND", "STRASSE")
  ydb_set(s, fmt"Gartenweg 4")


proc testData() =
  var k = initYdbKey("^LJ", "XXX")
  assert 0 == ydb_data(k)  # There is neither a value nor a subtree, i.e., it is undefined.
  k = initYdbKey("^LJ", "LAND")
  assert 10 == ydb_data(k)  # There is no value, but there is a subtree.
  k = initYdbKey("^LJ", "LAND", "ORT", "1")
  assert 11 == ydb_data(k)  # There are both a value and a subtree.
  k = initYdbKey("^LJ", "LAND", "STRASSE")
  assert 1 == ydb_data(k)  # There is a value, but no subtree


proc testNextNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var cur = initYdbKey(global, start)
  var rc = ydb_node_next(cur)
  while rc == YDB_OK:
    inc cnt
    rc = ydb_node_next(cur)
  assert cnt > 0
  assert rc == YDB_ERR_NODEEND
  # At the end of the tree the key keeps its last position
  let lastNode = cur.toSeq()
  assert ydb_node_next(cur) == YDB_ERR_NODEEND
  assert cur.toSeq() == lastNode


proc testPreviousNode(global: string, start: Subscripts = @[]) =
  var cnt = 0
  var cur = initYdbKey(global, start)
  var rc = ydb_node_previous(cur)
  while rc == YDB_OK:
    inc(cnt)
    rc = ydb_node_previous(cur)
  doAssert cnt == MAX * 2 + 2

proc testNextNodeIterator() =
  Kill: ^X

  Set:
    ^X(5, 1) = 1
    ^X(5, 2) = 2
    ^X(7, 3) = 3
    ^X(123, 1) = 4
    ^X(123, 2) = 5
    ^X(123, 3) = 6
    ^X(123, 123) = 7
    ^X(4711, "i") = 8
    ^X(123, "f") = 9
    ^X(123, 123, 4711, "i") = 10
    ^X(123, "i", 4711) = 11
    ^X(123, "s") = 12

  let refdata = @[
    @["5", "1"], @["5", "2"], @["7", "3"], @["123", "1"], @["123", "2"], @["123", "3"], 
    @["123", "123"], @["123", "123", "4711", "i"], @["123", "f"], @["123", "i", "4711"], @["123", "s"], @["4711", "i"]
  ]
  var dbdata: seq[Subscripts]
  let start: Subscripts = @[""]
  for subs in QueryItr ^X(start).keys:
    dbdata.add(subs)
  assert dbdata == refdata

proc testPreviousNodeIterator() =
  let refdata = @[
    @["4711", "i"], @["123", "s"], @["123", "i", "4711"], @["123", "f"], @["123", "123", "4711", "i"], @["123", "123"], @["123", "3"],
    @["123", "2"], @["123", "1"], @["7", "3"], @["5", "2"], @["5", "1"]
  ]
  var dbdata: seq[Subscripts]
  for subs in QueryItr ^X.reverse.keys:
    dbdata.add(subs)
  assert dbdata == refdata

proc nextSubscript(global: string, start: Subscripts, expected: string) =
  var k = initYdbKey(global, start)
  doAssert ydb_subscript_next(k) == expected

proc deleteTree() =
  var k = initYdbKey("^LJ", "LAND", "STRASSE")
  ydb_delete(k, YDB_DEL_NODE)
  k = initYdbKey("^LJ", "LAND", "ORT")
  for i in 0..MAX:
    k.setSub(2, i)
    k.setSub(3, i)
    ydb_delete(k, YDB_DEL_TREE)

# Delete all globals from ^LJ, ^LJ will be removed from %GD
proc testDeleteTree() =
  var k = initYdbKey("^LJ", "LAND")
  ydb_delete(k, YDB_DEL_TREE)
  let globals = getGlobals()
  assert globals.find("^LJ") == -1

proc deleteNode() =
    var k = initYdbKey("^CNT", "CHANNEL", "INPUT")
    ydb_delete(k, YDB_DEL_NODE)
    let result = ydb_increment(k, 1)
    assert ydb_get(k) == $result



proc testSpecialVariables() =

  let vars = [
    "$ESTACK", "$ETRAP", "$HOROLOG", "$IO", "$JOB", "$PRINCIPAL", "$QUIT", "$REFERENCE", "$STACK", "$STORAGE", "$SYSTEM",
    "$TLEVEL", "$TRESTART", "$X", "$Y", "$ZA", "$ZALLOCSTOR", "$ZAUDIT", "$ZCHSET", "$ZCLOSE", "$ZCSTATUS", "$ZDATEFORM",
    "$ZDIRECTORY", "$ZEDITOR", "$ZEOF", "$ZERROR", "$ZGBLDIR", "$ZHOROLOG", "$ZININTERRUPT", "$ZINTERRUPT", "$ZIO",
    "$ZJOB", "$ZLEVEL", "$ZMALLOCLIM", "$ZMAXTPTIME", "$ZMODE", "$ZONLNRLBK", "$ZPATNUMERIC", "$ZPIN", "$ZPOSITION", "$ZPOUT",
    "$ZPROMPT", "$ZQUIT", "$ZREALSTOR", "$ZRELDATE", "$ZROUTINES", "$ZSTATUS", "$ZSTEP", "$ZSTRPLLIM", "$ZSYSTEM", "$ZTIMEOUT",
    "$ZUSEDSTOR", "$ZUT", "$ZVERSION", "$ZYRELEASE"]

  let xvars = [
    "$DEVICE", "$ECODE", "$KEY", "$ZCMDLINE", "$ZKEY", "$ZCOMPILE", "$ZB", "$ZTEXIT",
    "$ZYSQLNULL", "$ZSOURCE", "$ZYERROR", "$ZYINTRSIG", "$ZTRAP"
  ]

  for variable in vars:
    var k = initYdbKey(variable)
    assert "" != ydb_get(k)

  for variable in xvars:
    var raised: bool
    try:
        var k = initYdbKey(variable)
        discard ydb_get(k)
    except:
        raised = true
    assert raised == true


proc testSetAndGetiable() =
  var k = initYdbKey("X")
  ydb_set(k, "hello")
  k.setSub(0, "1")
  ydb_set(k, "hello X(1)")
  k.setSub(1, "1")
  ydb_set(k, "hello X(1,1)")
  k.setSub(1, "2")
  ydb_set(k, "hello X(1,2)")
  k.setSub(1, "3")
  ydb_set(k, "hello X(1,3)")
  k = initYdbKey("X", "2")
  ydb_set(k, "hello X(2)")
  k.setSub(1, "3")
  ydb_set(k, "hello X(2,3)")

  k = initYdbKey("X")
  doAssert ydb_get(k) == "hello"
  k.setSub(0, "1")
  doAssert ydb_get(k) == "hello X(1)"
  k.setSub(1, "1")
  doAssert ydb_get(k) == "hello X(1,1)"


proc testLock() =
  let globals :seq[seq[string]]= @[
        @["^LL","HAUS", "1"], @["^LL","HAUS", "2"], @["^LL","HAUS", "3"],
        @["^LL","HAUS", "4"], @["^LL","HAUS", "5"], @["^LL","HAUS", "6"], 
        @["^LL","HAUS", "7"], @["^LL","HAUS", "8"], @["^LL","HAUS", "9"], @["^LL","HAUS", "10"],
        @["^LL","HAUS", "11"], @["^LL","HAUS", "12"], @["^LL","HAUS", "13"],
        @["^LL","HAUS", "14"], @["^LL","HAUS", "15"], @["^LL","HAUS", "16"],
        @["^LL","HAUS", "17"], @["^LL","HAUS", "18"], @["^LL","HAUS", "19"], @["^LL","HAUS", "20"],
        @["^LL","HAUS", "21"], @["^LL","HAUS", "22"], @["^LL","HAUS", "23"],
        @["^LL","HAUS", "24"], @["^LL","HAUS", "25"], @["^LL","HAUS", "26"],
        @["^LL","HAUS", "27"], @["^LL","HAUS", "28"], @["^LL","HAUS", "29"], @["^LL","HAUS", "30"],
        @["^LL","HAUS", "31"], @["^LL","HAUS", "32"], @["^LL","HAUS", "33"], @["^LL","HAUS", "34"], 
        @["^LL","HAUS", "35"]
        ]

  var toLock:seq[seq[string]]
  for global in  globals:
    toLock.add(global)
    ydb_lock(100000, toLock)
    assert getLockCountFromYottaDb() == toLock.len

  ydb_lock(100000, @[])
  assert getLockCountFromYottaDb() == 0

  # Too many locks
  toLock.add(@["^LL","HAUS", "36"])
  doAssertRaises(YdbError): ydb_lock(100000, toLock)


proc testLockIncrement() =
  var k = initYdbKey("^LL", "HAUS", "31")
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 1
  k.setSub(1, "32")
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 2
  k.setSub(1, "33")
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 3

  # Decrement locks one by one
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 2
  k.setSub(1, "32")
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 1
  k.setSub(1, "31")
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing Lock (Should be ignored)
  k.setSub(1, "99")
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 0

  # Increment / Decrement non existing global (Lock will be created)
  k = initYdbKey("^ZZZZ", "HAUS", "31")
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 1

  # Increment / Decrement same Lock multiple times
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 1
  ydb_lock_incr(100000, k)
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 1
  ydb_lock_decr(k)
  assert getLockCountFromYottaDb() == 0


proc testIncrement() =
  let MAX = 1000 
  var cnt:int 
  var k = initYdbKey("^COUNTERS", "upcount")
  ydb_set(k, "0")
  for i in 0..<MAX:
    cnt = ydb_increment(k)
  assert cnt == MAX
  assert ydb_get(k) == $MAX

proc testMaxSubscripts() =
  for i in 0..<33:
    var keys:seq[string] = @[]
    for j in 0..<i:
      keys.add($j)

    if i < 32:
      var k = initYdbKey("^SUBS", keys)
      ydb_set(k, $i)
      assert $i == ydb_get(k)
    else:
      doAssertRaises(YdbError):
        var k = initYdbKey("^SUBS", keys)
        ydb_set(k, $i)


proc testDeleteExcl() =
  for name in ["DELTEST1", "DELTEST2", "DELTEST3", "DELTEST4", "DELTEST5"]:
    var k = initYdbKey(name, "A")
    ydb_set(k, "1")

  for name in ["DELTEST1", "DELTEST2", "DELTEST3", "DELTEST4", "DELTEST5"]:
    var k = initYdbKey(name, "A")
    doAssert ydb_get(k) == "1"

  ydb_delete_excl(@["DELTEST1","DELTEST3","DELTEST5"])

  # Global's are not allowed
  doAssertRaises(YdbError): ydb_delete_excl(@["^DELTEST"])

  for name in ["DELTEST1", "DELTEST3", "DELTEST5"]:
    var k = initYdbKey(name, "A")
    doAssert ydb_get(k) == "1"
  for name in ["DELTEST2", "DELTEST4"]:
    var k = initYdbKey(name, "A")
    assert 0 == ydb_data(k)

  # delete all variables
  ydb_delete_excl()
  var k = initYdbKey("DELTEST1", "A")
  assert 0 == ydb_data(k)

# -------------------------------------------------------------------

if isMainModule:
  setupLL()

  test "simpleSet": simpleSet("^X", MAX)
  test "simpleGet": simpleGet("^X", MAX)
  test "simpleDelete": simpleDelete("^X", MAX)
  test "testYdbVar": testYdbVar()
  test "testWithError": setWithError()
  test "testYdbSetGet": testYdbSetGet()
  test "testData": testData()
  test "testNextNode ^LL": testNextNode("^LL")
  test "testNextNodeIterator": testNextNodeIterator()
  test "testPreviousNodeIterator": testPreviousNodeIterator()
  test "testPreviousNode": testPreviousNode("^LJ", @["LAND", "STRASSE"])
  test "deleteTree": deleteTree()
  test "deleteNode": deleteNode()
  test "deleteGlobalVar": testDeleteTree()
  test "testLocalVarExcl": testDeleteExcl()
  test "testSpecialVariables": testSpecialVariables()
  test "Increment": testIncrement()
  test "maxSubscripts": testMaxSubscripts()
  test "testSetAndGetiable": testSetAndGetiable()
  test "testLock": testLock()
  test "testLockIncrement": testLockIncrement()

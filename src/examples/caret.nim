import macros
import ../yottadb
import std/strformat
import std/strutils
import std/times

template t1(body: untyped): untyped =
  static:
    dumpTree(body)

template transformBody(body: untyped): untyped =
  if body.kind == nnkStmtList:
    result = newStmtList()
    for stmt in body:
      result.add transform(stmt)
  else:
    result = transform(body)

proc transformCallNode(node: NimNode): seq[NimNode] = 
  ## tablePrefix '^' for yottadb global variables, '$' for Special variables, '' empty for variables
  if node.kind == nnkPrefix:
    let prefix = node[0].strVal # get ^, $, or ''
    let callNode = node[1]
    if callNode.kind == nnkCall:
      let tableIdent = callNode[0]
      result.add newLit(prefix & $tableIdent)      # turn Ident into string "CUSTOMER"
      for i in 1 ..< callNode.len:
        result.add newCall(ident"$", callNode[i])
  else:
    echo "unsupported node node.kind=", node.kind

macro set*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs)
        return newCall(ident"setxxx", args)
    else:
      return node

  transformBody body

macro incr*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkAsgn:  # assignment ^CNT("AUTO")=<increment>
      let lhs = node[0]
      let rhs = node[1]
      if lhs.kind == nnkPrefix:
        var args = transformCallNode(lhs)
        args.add newCall(ident"$", rhs) # the value to assign
        return newCall(ident"incrxxx", args)
    elif node.kind == nnkPrefix:  # ^CNT("AUTO"). (Increment defaults to 1)
      var args = transformCallNode(node)
      return newCall(ident"incr1xxx", args)
    else:
      return node
  
  transformBody body

macro get*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"getxxx", args)
    else:
      return node

  transformBody body

macro data*(body: untyped): untyped =
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      var args = transformCallNode(node)
      return newCall(ident"dataxxx", args)
    else:
      return node

  transformBody body

# Case 1: Single Global      
# StmtList
#   Prefix
#     Ident "^"
#     Call
#       Ident "LL"
#       StrLit "HAUS"
#       StrLit "11"
#
# Case 2: Multiple Globals in Curly braces
# StmtList
#   Curly
#     Prefix
#       Ident "^"
#       Call
#         Ident "LL"
#         StrLit "HAUS"
#         StrLit "11"
#     Prefix
#       Ident "^"
#       Call
#         Ident "LL"
#         StrLit "HAUS"
#         StrLit "12"

macro lock*(body: untyped): untyped =
  var args:seq[NimNode] = @[]
  proc transform(node: NimNode): NimNode =
    if node.kind == nnkPrefix:
      args.add(transformCallNode(node))
      return newCall(ident"lockxxx", args)
    elif node.kind == nnkCurly:
      for n in 0..<node.len:
        let prefixNode = node[n]
        args.add(transformCallNode(prefixNode))
      return newCall(ident"lockxxx", args)
    else:
      return node

  transformBody body


# Proc^s that implement the ydb call's
proc setxxx(args: varargs[string]) =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = args[^1]
  ydbSet(global, subscripts, value)

proc incr1xxx(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  return ydbIncrement(global, subscripts)

proc incrxxx(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^2]
  let value = parseInt(args[^1])
  return ydbIncrement(global, subscripts, value)

proc getxxx(args: varargs[string]): string =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbGet(global, subscripts)

proc dataxxx(args: varargs[string]): int =
  let global = args[0]
  let subscripts = args[1..^1]
  result = ydbData(global, subscripts)

proc lockxxx(args: varargs[string]) =
  # Convert 
  # args=["^LL", "HAUS", "11", "^LL", "HAUS", "12"] ->
  # subs:@[@["^LL", "HAUS", "11"], @["^LL", "HAUS", "12"]]
  var subs:seq[seq[string]] = @[]
  var tmp:seq[string] = @[]
  for arg in args:
    if arg[0] == '^':
        if tmp.len > 0:
          subs.add(tmp)
          tmp = @[]
    tmp.add(arg)
  if tmp.len > 0:
    subs.add(tmp)
  try:
    ydbLock(100000, subs)
  except:
    echo getCurrentExceptionMsg()


proc main() =
  let id = 1
  # Data
  let raw = data: ^CUST(id)
  case YdbData(raw):
  of NO_DATA_NO_SUBTREE: echo "No data, no subtree"
  of NO_DATA_WITH_SUBTREE: echo "No data, but has subtree"
  of DATA_NO_SUBTREE: echo "Has data but no subtree"
  of DATA_AND_SUBTREE: echo "Has data and subtree"

  # Set
  set:
      ^CUST(id, 1) = 3.1414

  # Set multiple items
  set:
      ^CUST(id, 2) = 3.1414
      ^CUST(id, 3) = 3.1414
      ^CUST(id, 4) = 3.1414
      ^CUST(id, 5) = 3.1414

  # Set loop
  for id in 0..<5:
    set:
      ^CUST(id, "Timestamp") = cpuTime()

  # Get
  let val = get:
      ^CUST(id, 1)
  echo "id:", id, " val:", val

  for id in 0..<5:
    let ts = get:
      ^CUST(id, "Timestamp")
    echo fmt"^CUST({id},'Timestamp')={ts}"

  # Update
  var fval = parseFloat(val)
  fval += 1
  set:
    ^CUST(id, 1) = fval

  # Increment
  var txid = get: ^CNT("TXID")
  echo fmt"TXID before increment is {txid}"
  var incrval = incr: ^CNT("TXID")
  echo fmt"TXID incremented by 1: {incrval}" 
  incrval = incr: ^CNT("TXID") = 10
  echo fmt"TXID incremented by 10: {incrval}" 

proc testLock() =
  # Set Locks
  lock:
    {
      ^LL("HAUS", "11"),
      ^LL("HAUS", "12"),
      ^LL("HAUS", "XX"), # not yet existent, but ok
    }

  var numOfLocks = getLockCountFromYottaDb()
  echo "Number of locks set: ", numOfLocks
  assert 3 == numOfLocks

  lock: {}
  numOfLocks = getLockCountFromYottaDb()
  echo "Number of locks set: ", numOfLocks
  assert 0 == getLockCountFromYottaDb()
  

main()
testLock()
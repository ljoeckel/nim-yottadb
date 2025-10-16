import macros
import std/strutils
import std/strformat
import std/sets
import std/unittest
import std/tables
import utils
import libs/libydb
import libs/ydbtypes
import libs/ydbapi
import serialization/bingoser
when compileOption("profiler"):
  import std/nimprof

const 
    PREFIX_CHARS = {'^', '+', '-', '$', '@'}
    INDIRECTION = "@"
    VALUEMARK = "!"
    TYPEDESC = "|TD|"
    DATAVAL = "|VAL|"
    FIELDMARK = "|"


# ------------------
# Macro procs
# ------------------

proc findAttributes(node: NimNode, kv: var Table[string, NimNode]) =
    case node.kind
    of nnkStmtList, nnkCall, nnkCurly, nnkTupleConstr:
        for i in 0..<node.len:
            findAttributes(node[i], kv)
    of nnkExprEqExpr:   # by=, timeout=,...
        kv[repr(node[0])] = node[1]
    else:
        discard

proc transformCallNode(node: NimNode, args: var seq[NimNode]) =
    if node.kind in [nnkStrLit, nnkIntLit, nnkIdent]:
        args.add(newCall(ident"$", node))
    else:
        discard

proc transform(node: NimNode, args: var seq[NimNode]) =
    case node.kind
    of nnkStmtList, nnkTupleConstr:
        for i in 0..<node.len:
            transform(node[i], args)
    of nnkCurly:
        for i in 0..<node.len:
            transform(node[i], args)
            args.add(newLit(FIELDMARK))
    of nnkPrefix:
        args.add(newLit(node[0].strVal))
        transform(node[1], args)
    of nnkIdent:
        if args.len > 0 and args[0].strVal == INDIRECTION:
            args.add(node)
        else:
            args.add(newLit(node.strVal))
    of nnkCall:
        args.add(newLit(node[0].strVal))
        for i in 1..<node.len:
            transformCallNode(node[i], args)
    of nnkAsgn:
        transform(node[0], args) # resolve lhs
        args.add(newCall(ident"$", node[1])) # add value
        args.add(newLit(VALUEMARK))
    of nnkIntLit, nnkStrLit, nnkFloatLit:
        args.add(newCall(ident"$", node))
    of nnkExprEqExpr, nnkDiscardStmt:   # by=, timeout=,... handeled by findAttributes
        discard
    of nnkDotExpr:
        transform(node[0], args)
        args.add(newLit(TYPEDESC))
        args.add(newCall(ident"$", node[1]))
    of nnkInfix:
        raise newException(Exception, "Illegal variable name name:" & repr(node))
    else:
        raise newException(Exception, "Unsupported node.kind:" & $node.kind)

proc processStmtList(body: NimNode): seq[NimNode] =
    if body.kind == nnkStmtList:
        for i in 0..<body.len:
            transform(body[i], result)
            result.add(newLit(FIELDMARK))
    else:
        raise newException(Exception, "Statement list needs ':' g.e. delnode: ^xxx(...)")


# ------------------
# Macros
# ------------------

macro get*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
        
    # check for type conversion
    if args.len > 2 and repr(args[^2]).contains(TYPEDESC):
        let s = repr(args[^1])
        let openPar = s.find('(') # any subscripts 
        if openPar != -1:
            let closePar = s.find(')', openPar)
            let typename = s[openPar + 1 ..< closePar]
            return newCall(ident("getxxx" & typename), args[0..^3])
    return newCall(ident"getxxx", args)    

macro data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    return newCall(ident"dataxxx", args)    

macro delnode*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"delnodexxx", args)

macro deltree*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"deltreexxx", args)

macro delexcl*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"delexclxxx", args)

macro increment*(body: untyped): untyped =
    var args: seq[NimNode]
    var kv: Table[string, NimNode]
    findAttributes(body, kv)
    transform(body, args)
    if kv.hasKey("by"):
        args.add(newLit(DATAVAL))
        args.add(newCall(ident"$", kv["by"]))
    return newCall(ident"incrementxxx", args)

macro lock*(body: untyped): untyped =
    var args = processStmtList(body)
    var kv: Table[string, NimNode]
    findAttributes(body, kv)
    if kv.hasKey("timeout"):
        args.add(newLit(DATAVAL))
        args.add(newCall(ident"$", kv["timeout"]))
    return newCall(ident"lockxxx", args)

macro nextnode*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    return newCall(ident"nextnodexxx", args)    

macro nextsubscript*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    return newCall(ident"nextsubscriptxxx", args)    

macro prevnode*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    return newCall(ident"prevnodexxx", args)    

macro prevsubscript*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    return newCall(ident"prevsubscriptxxx", args)    

macro setvar*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"setxxx", args)


# ----------------------------
# proc related helper proc's
# ----------------------------
proc stringToSeq(s: string): Subscripts =
    var str: string = newString(s.len)
    var idx: Natural = 0
    for c in s:
        if c == ',':
            str[idx] = c
            str.setLen(idx)
            result.add(str)
            str.setLen(str.capacity)
            idx = 0
            continue
        if c in {'@', '[', ']', '\\', ' ', '"'} :            
            continue
        str[idx] = c
        inc idx

    if idx > 0:
        str.setLen(idx)
        result.add(str)

proc argsToSeq(args: varargs[string]): seq[string] =
  for arg in args:
    if arg.startsWith("@["):
      result.add(stringToSeq(arg))
    else:
      result.add(arg)

proc seqToYdbVars(args: varargs[string]): seq[YdbVar] =
  var
    resultVars: seq[YdbVar]
    ydbvar: YdbVar
    subs: Subscripts

  var lastArg: string
  for arg in args:
    if arg == FIELDMARK:
      # End of one YdbVar group
      if ydbvar.name.len > 0:
        if ydbvar.subscripts.len == 0:
          ydbvar.subscripts = subs
        resultVars.add(ydbvar)
      # Reset for next
      ydbvar = YdbVar()
      subs = @[]
      continue

    if arg == VALUEMARK:
      # End of value-based YdbVar
      ydbvar.value = lastArg
      subs.delete(subs.len - 1)
      #if subs.len > 0: subs.setLen(subs.len - 1) # Remove last sub if it's the value
      if ydbvar.subscripts.len == 0: ydbvar.subscripts = subs
      resultVars.add(ydbvar)
      ydbvar = YdbVar()
      subs = @[]
      continue

    # Handle prefix at the start
    if ydbvar.name.len == 0 and ydbvar.prefix.len == 0:
      if arg.len == 1 and arg[0] in PREFIX_CHARS:
        ydbvar.prefix = arg
        continue
      elif arg.len == 2 and arg[0] in PREFIX_CHARS and arg[1] in PREFIX_CHARS:
        ydbvar.prefix = arg
        continue

    # Name assignment
    if ydbvar.name.len == 0:
      if ydbvar.prefix == INDIRECTION:
        let openPar = arg.find('(')
        if openPar != -1:
          let closePar = arg.find(')', openPar)
          let subsStr = arg[openPar + 1 ..< closePar]
          for idx in subsStr.split(','):
            ydbvar.subscripts.add(idx.strip())
          ydbvar.name = arg[0..<openPar]
        else:
          ydbvar.name = arg
      else:
        if ydbvar.prefix.len > 0 and ydbvar.prefix[0] in {'+', '-'}:
          ydbvar.name = ydbvar.prefix[1..^1] & arg
        else:
          ydbvar.name = ydbvar.prefix & arg
    else:
      if arg.startsWith("@["):
          subs.add(stringToSeq(arg))
      else:
        subs.add(arg)
      lastArg = arg

  # Final flush if any
  if ydbvar.name.len > 0:
    if ydbvar.subscripts.len == 0:
      ydbvar.subscripts = subs
    resultVars.add(ydbvar)
  return resultVars



proc seqToYdbVar(args: varargs[string]): YdbVar =
    if args[0].len > 0 and args[0][0] in PREFIX_CHARS:
        result.prefix = args[0]
        let arg = args[1]
        # Handle indirection
        if result.prefix == INDIRECTION:
            let openPar = arg.find('(') # handle subscripts
            if openPar != -1:
                let closePar = arg.find(')', openPar)
                let index = arg[openPar + 1 ..< closePar]
                for idx in split(index, ','):
                    result.subscripts.add(idx.strip())
                result.name = arg[0..<openPar]
            else:
                result.name = arg
        else:
            result.name = result.prefix & arg

        # handle typedesc "int16", ...
        if args.len > 2 and args[^2] == TYPEDESC:
            result.typdesc = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[2..^3]
        elif args.len > 2 and args[^2] == DATAVAL:
            result.value = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[2..^3]
        else:
            if result.subscripts.len == 0: result.subscripts = args[2..^1]
            if result.subscripts.len > 0 and result.subscripts[0].startsWith("@["):
                result.subscripts = stringToSeq(result.subscripts[0])

    else: # no prefix
        result.name = args[0] # local var
        result.subscripts = args[1..^1]


proc getTimeout(arg: string): int =
    result = YDB_LOCK_TIMEOUT
    if arg.contains('.'):
      try: # float numeric timeout value?
        let f = parseFloat(arg)
        if f <= 2.147:
          result = (f * 1000000000).int
      except:
        discard
    else:
      try:  # int numeric timeout value?
        let i = parseInt(arg)
        if i <= YDB_LOCK_TIMEOUT:
          result = i
      except:
        discard
    if result == 0: result = YDB_LOCK_TIMEOUT

# ----------------------------------------
# macros call's one of this for each macro
# ----------------------------------------

proc dataxxx*(args: varargs[string]): int =
    let ydbvar = seqToYdbVar(args)
    ydb_data(ydbvar.name, ydbvar.subscripts)

proc delnodexxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_node(ydbvar.name, ydbvar.subscripts)

proc delexclxxx*(args: varargs[string]) =
    var names: seq[string]
    for ydbvar in seqToYdbVars(args):
        names.add(ydbvar.name)
    ydb_delete_excl(names)

proc deltreexxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_tree(ydbvar.name, ydbvar.subscripts)

proc getxxx*(args: varargs[string]): string =
    let ydbvar = seqToYdbVar(args)
    ydb_get(ydbvar.name, ydbvar.subscripts)

proc getxxxbinary*(args: varargs[string]): string =
    let ydbvar = seqToYdbVar(args)
    ydb_getblob(ydbvar.name, ydbvar.subscripts)

proc getxxxfloat*(args: varargs[string]): float =
    parseFloat(getxxx(args))

proc getxxxfloat32*(args: varargs[string]): float32 =
  parseFloat(getxxx(args)).float32

proc getxxxint*(args: varargs[string]): int =
    parseInt(getxxx(args)).int

proc getxxxint8*(args: varargs[string]): int8 =
    let value = parseInt(getxxx(args)).int
    if value > int8.high or value < int8.low:
        raise newException(ValueError, "Not in " & $int8.low & " .. " & $int8.high)
    else:
        return value.int8

proc getxxxint16*(args: varargs[string]): int16 =
    let value = parseInt(getxxx(args)).int
    if value > int16.high or value < int16.low:
        raise newException(ValueError, "Not in " & $int16.low & " .. " & $int16.high)
    else:
        return value.int16

proc getxxxint32*(args: varargs[string]): int32 =
    let value = parseInt(getxxx(args)).int
    if value > int32.high or value < int32.low:
        raise newException(ValueError, "Not in " & $int32.low & " .. " & $int32.high)
    else:
        return value.int32

proc getxxxint64*(args: varargs[string]): int64 =
    let value = parseInt(getxxx(args)).int
    if value > int64.high or value < int64.low:
        raise newException(ValueError, "Not in " & $int64.low & " .. " & $int64.high)
    else:
        return value.int64

proc getxxxuint*(args: varargs[string]): uint =
    parseUInt(getxxx(args)).uint

proc getxxxuint8*(args: varargs[string]): uint8 =
    let value = parseUInt(getxxx(args)).uint
    if value > uint8.high or value < 0:
        raise newException(ValueError, "Not in " & $uint8.low & " .. " & $uint8.high)
    else:
        return value.uint8

proc getxxxuint16*(args: varargs[string]): uint16 =
  let value = parseUInt(getxxx(args)).uint
  if value > uint16.high or value < 0:
    raise newException(ValueError, "Not in " & $uint16.low & " .. " & $uint16.high)
  else:
    return value.uint16

proc getxxxuint32*(args: varargs[string]): uint32 =
  let value = parseUInt(getxxx(args)).uint
  if value > uint32.high or value < 0:
    raise newException(ValueError, "Not in " & $uint32.low & " .. " & $uint32.high)
  else:
    return value.uint32

proc getxxxuint64*(args: varargs[string]): uint64 =
  let value = parseUInt(getxxx(args)).uint
  if value > uint64.high or value < 0:
    raise newException(ValueError, "Not in " & $uint64.low & " .. " & $uint64.high)
  else:
    return value.uint64

proc getxxxOrderedSet*(args: varargs[string]): OrderedSet[int] =
    let str = getxxx(args)

    result = initOrderedSet[int]()
    if str[0] == '{' and str[^1] == '}':
        for s in split(str[1 .. ^2], ","):
            result.incl(parseInt(strip(s)))
    else:
        for s in split(str, ","):
            result.incl(parseInt(strip(s)))

proc incrementxxx*(args: varargs[string]): int =
    var ydbvar = seqToYdbVar(args)
    if ydbvar.value == "": ydbvar.value = "1"
    ydb_increment(ydbvar.name, ydbvar.subscripts, parseInt(ydbvar.value))

proc lockdecrxxx(timeout: int, ydbvars: seq[YdbVar]) =
  # Decrement lock count for variable
  for ydbvar in ydbvars:
    ydb_lock_decr(ydbvar.name, ydbvar.subscripts)

proc lockincrxxx(timeout: int, ydbvars: seq[YdbVar]) =
    # Increment lock count for variable(s)
    for ydbvar in ydbvars:
        ydb_lock_incr(timeout, ydbvar.name, ydbvar.subscripts)

proc lockxxx*(args: varargs[string]) =
    # timeout from lock: { ^GBL, timeout=12345 }
    var timeout = YDB_LOCK_TIMEOUT
    if args.len > 2 and args[^2] == DATAVAL:
        timeout = getTimeout(args[^1])

    let ydbvars = seqToYdbVars(args)
    var vars: seq[Subscripts]
    var incvars: seq[YdbVar]
    var decvars: seq[YdbVar]
    # create seq of subscripts for each var
    # @[@["^XXX", ""], @["^GBL", "2"], @["^GBL", "2", "3"], @["^GBL", "2", "3", "abc"]]
    for ydbvar in ydbvars:
        # timeout from lock: ^GBL, timeout=12345
        if ydbvar.name == DATAVAL: continue
        if ydbvar.name == "timeout" and ydbvar.value != "":
            timeout = getTimeout(ydbvar.value)
            continue
        if ydbvar.prefix.len > 0:
            if ydbvar.prefix[0] == '+':
                incvars.add(ydbvar)
                continue
            elif ydbvar.prefix[0] == '-':
                decvars.add(ydbvar)
                continue

        var subs: seq[string]
        subs.add(ydbvar.name)
        for sub in ydbvar.subscripts:
            subs.add(sub)
        if subs.len == 1: subs.add("") # lock only on variable add empty subscripts
        vars.add(subs)

    # set locks, or release all
    if vars.len > 0 or (vars.len == 0 and incvars.len == 0 and decvars.len == 0):
        ydb_lock(timeout, vars)

    # Increment / Decrement locks?
    if incvars.len > 0:
        lockincrxxx(timeout, incvars)
    if decvars.len > 0:
        lockdecrxxx(timeout, decvars)

proc nextnodexxx*(args: varargs[string]): (int, string) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_node_next(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, keysToString(ydbvar.name, subs))
    elif rc == YDB_ERR_NODEEND:
        return (rc, "")
    else:
        let message = ydbMessage(rc.cint)
        raise newException(YdbError, fmt"{message}, Names: {ydbvar.name}({ydbvar.subscripts})")

proc nextsubscriptxxx*(args: varargs[string]): (int, string) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_subscript_next(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, keysToString(ydbvar.name, subs))
    elif rc == YDB_ERR_NODEEND:
        return (rc, "")
    else:
        let message = ydbMessage(rc.cint)
        raise newException(YdbError, fmt"{message}, Names: {ydbvar.name}({ydbvar.subscripts})")

proc prevnodexxx*(args: varargs[string]): (int, string) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_node_previous(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, keysToString(ydbvar.name, subs))
    elif rc == YDB_ERR_NODEEND:
        return (rc, "")
    else:
        let message = ydbMessage(rc.cint)
        raise newException(YdbError, fmt"{message}, Names: {ydbvar.name}({ydbvar.subscripts})")

proc prevsubscriptxxx*(args: varargs[string]): (int, string) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_subscript_previous(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, keysToString(ydbvar.name, subs))
    elif rc == YDB_ERR_NODEEND:
        return (rc, "")
    else:
        let message = ydbMessage(rc.cint)
        raise newException(YdbError, fmt"{message}, Names: {ydbvar.name}({ydbvar.subscripts})")

proc setxxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value)

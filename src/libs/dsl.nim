import macros
import std/strutils
import std/strformat
import std/sets
import std/tables
import libs/ydbtypes
import libs/ydbapi
when compileOption("profiler"):
  import std/nimprof

const 
    PREFIX_CHARS = {'^', '+', '-', '$', '@'}
    INDIRECTION = "@"
    INDIRECTION_SEQ = "@["
    VALUEMARK = "!"
    TYPEDESC = "|TD|"
    DATAVAL = "|VAL|"
    FIELDMARK = "|"
    DEFAULT="default"
    BY = "by"

# ------------------
# Macro procs
# ------------------
proc exploreNode(node: NimNode) =
    echo "'", repr(node), "' (", node.kind,")"
    for n in node:
        echo "  ", repr(n), "' (", n.kind,")"
        if n.len > 0:
            for nn in n:
                echo "     ", repr(nn), "' (", nn.kind,")"


proc findAttributes(node: NimNode, kv: var Table[string, NimNode]) =
    case node.kind
    of nnkStmtList, nnkCall, nnkCurly, nnkTupleConstr, nnkDotExpr:
        for i in 0..<node.len:
            findAttributes(node[i], kv)
    of nnkExprEqExpr:   # by=, timeout=,...
        kv[repr(node[0])] = node[1]
    else:
        discard

proc transformCallNode(node: NimNode, args: var seq[NimNode]) =
    case node.kind
    of nnkIdent, nnkInfix:
        args.add(newCall(ident"$", node))
    of nnkStrLit, nnkPrefix:  # "abc" / let id=4711; getvar ^gbl($id)
        args.add(node)
    of nnkIntLit, nnkFloatLit, nnkCharLit:
        args.add(newCall(ident"$", node))
    else:
        raise newException(Exception, "transformCallNode: node.kind:" & $node.kind & " not supported! node=" & repr(node))

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
        if node[0].strVal == INDIRECTION and node.len > 1 and node[1].kind == nnkBracket:
            # special handling when sequence in call.  ^gbl(@["abc",4711])
            discard
        else:
            args.add(newLit(node[0].strVal))
        transform(node[1], args)
    of nnkIdent, nnkInfix:
        if args.len > 0 and args[0].strVal == INDIRECTION:
            args.add(node)
        else:
            args.add(newLit(node.strVal))
    of nnkCall:
        if node.len > 1 and node[0].kind == nnkPrefix and repr(node[0])[0] == '@': # getvar @gbl("field") extend index
            for i in 0..<node.len:
                if node[i].kind == nnkPrefix:
                    let lhs = node[i][0]
                    let rhs = node[i][1]
                    if lhs.strVal == "$":
                        args.add(newCall(ident"$", rhs)) # add variable ($id)
                    else:
                        transform(node[i], args)    
                else:
                    transformCallNode(node[i], args)
        elif node.len > 1 and node[1].kind == nnkPrefix and repr(node[1])[0] == '@': # seq[]
            args.add(newLit(node[0].strVal)) # the variable name
            for i in 1..<node.len:
                transform(node[i], args)
        else:
            args.add(newLit(node[0].strVal)) # the variable name
            for i in 1..<node.len:
                transformCallNode(node[i], args)
    of nnkAsgn:
        transform(node[0], args) # resolve lhs
        args.add(newCall(ident"$", node[1])) # add value
        args.add(newLit(VALUEMARK))
    of nnkIntLit, nnkFloatLit, nnkCharLit:
        args.add(newCall(ident"$", node))
    of nnkStrLit:
        args.add(node)
    of nnkExprEqExpr, nnkDiscardStmt:   # by=, timeout=,... handeled by findAttributes
        discard
    of nnkDotExpr:
        transform(node[0], args)
        args.add(newLit(TYPEDESC))
        args.add(newCall(ident"$", node[1]))
    of nnkBracket:
        for i in 0..<node.len:
            case node[i].kind
            of nnkPrefix: # [$varname, "x", 4711
                args.add(newCall(ident"$", node[i][1]))
            of nnkIdent, nnkInfix:
                args.add(newCall(ident"$", node[i]))
            else:
                transform(node[i], args)
    else:
        raise newException(Exception, "Unsupported node.kind:" & $node.kind)

proc processStmtList(body: NimNode): seq[NimNode] =
    if body.kind == nnkStmtList:
        for i in 0..<body.len:
            transform(body[i], result)
            result.add(newLit(FIELDMARK))
    else:
        raise newException(Exception, "Statement list needs ':' g.e. killnode: ^xxx(...) body.kind=" & $body.kind)

func hasTypeConversion(typename: string, args: seq[NimNode]): bool =
    if args.len > 2 and repr(args[^2]).contains(TYPEDESC):    
        let s = repr(args[^1])
        let openPar = s.find('(') # any subscripts 
        if openPar != -1:
            let closePar = s.find(')', openPar)
            let tname = s[openPar + 1 ..< closePar]
            if typename == tname:
                return true
            else:
                raise newException(Exception, "Only '" & typename & "' is supported. error=" & typename)
    false

# ------------------
# Macros
# ------------------

macro getvar*(body: untyped): untyped =
    var args: seq[NimNode]
    var kv: Table[string, NimNode]
    findAttributes(body, kv)
    transform(body, args)

    # check for type conversion
    var typename = "getxxx"
    if args.len > 2 and repr(args[^2]).contains(TYPEDESC):
        let s = repr(args[^1])
        let openPar = s.find('(') # any subscripts 
        if openPar != -1:
            let closePar = s.find(')', openPar)
            typename.add(s[openPar + 1 ..< closePar])
            args = args[0..^3] # remove TD,int

    if kv.hasKey(DEFAULT):
        args.add(newLit(DATAVAL))
        args.add(newCall(ident"$", kv[DEFAULT]))

    return newCall(ident(typename), args)


macro data*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)
    newCall(ident"dataxxx", args)    

macro killnode*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"killnodexxx", args)

macro kill*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"killxxx", args)

macro delexcl*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"delexclxxx", args)

macro increment*(body: untyped): untyped =
    var args: seq[NimNode]
    var kv: Table[string, NimNode]
    findAttributes(body, kv)
    transform(body, args)
    if kv.hasKey(BY):
        args.add(newLit(DATAVAL))
        args.add(newCall(ident"$", kv[BY]))
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
    if hasTypeConversion("seq", args):
        return newCall(ident("nextnodexxxseq"), args[0..^3])        
    else:
        return newCall(ident"nextnodexxx", args)

macro nextsubscript*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)

    # check for type conversion
    if hasTypeConversion("seq", args):
        return newCall(ident("nextsubscriptxxxseq"), args[0..^3])
    else:
        return newCall(ident"nextsubscriptxxx", args)

macro prevnode*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)

    # check for type conversion
    if hasTypeConversion("seq", args):
        return newCall(ident("prevnodexxxseq"), args[0..^3])
    else:
        return newCall(ident"prevnodexxx", args)

macro prevsubscript*(body: untyped): untyped =
    var args: seq[NimNode]
    transform(body, args)

    # check for type conversion
    if hasTypeConversion("seq", args):
        return newCall(ident("prevsubscriptxxxseq"), args[0..^3])        
    else:
        return newCall(ident"prevsubscriptxxx", args)

macro setvar*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"setxxx", args)


# ----------------------------
# proc related helper proc's
# ----------------------------

proc seqToYdbVars(args: varargs[string]): seq[YdbVar] =
  var
    resultVars: seq[YdbVar]
    ydbvar: YdbVar
    subs: Subscripts

  var lastArg: string
  for arg in args:
    case arg 
    of FIELDMARK:
      # End of one YdbVar group
      if ydbvar.name.len > 0:
        if ydbvar.subscripts.len == 0:
          ydbvar.subscripts = subs
        resultVars.add(ydbvar)
      # Reset for next
      ydbvar = YdbVar()
      subs = @[]
      continue
    of VALUEMARK:
      # End of value-based YdbVar
      ydbvar.value = lastArg
      ydbvar.subscripts.add(subs[0..^2])
      resultVars.add(ydbvar)
      ydbvar = YdbVar()
      subs = @[]
      continue

    # Set the prefix field (1..2 bytes)
    if ydbvar.name.len == 0 and ydbvar.prefix.len == 0: # single @,$,.
      if arg.len == 1 and arg[0] in PREFIX_CHARS:
        ydbvar.prefix = arg
        continue
      elif arg.len == 2 and arg[0] in PREFIX_CHARS and arg[1] in PREFIX_CHARS: # +@
        ydbvar.prefix = arg
        continue

    # Name assignment
    if ydbvar.name.len == 0:
      if ydbvar.prefix == INDIRECTION:
        let openPar = arg.find('(')
        if openPar != -1:
          let closePar = arg.find(')', openPar)
          let subsStr = arg[openPar + 1 ..< closePar]
          ydbvar.subscripts.add(stringToSeq(subsStr))
          ydbvar.name = arg[0..<openPar]
        else:
          ydbvar.name = arg
      else:
        if ydbvar.prefix.len > 0 and ydbvar.prefix[0] in {'+', '-'}:
          ydbvar.name = ydbvar.prefix[1..^1] & arg
        else:
          ydbvar.name = ydbvar.prefix & arg
    else:
      if arg.startsWith(INDIRECTION_SEQ):
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
    if args.len >= 2 and args[0] == INDIRECTION:
        if args[1].len > 0 and args[1][^1] == ')':            
            var subs: Subscripts
            let open = args[1].find("(")
            if open > 0:
                subs.add(args[0])
                subs.add(args[1][0..open-1]) # the varname 
                subs.add(args[1][open+1..^2]) # the idx part(s)
                subs.add(args[2..^1]) # the restly key parts

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
                    var s = idx.strip()
                    if s.len > 0:
                        if s[0] == '\"' and s[^1] == '\"': # remove \" (let gbl = "^GBL(\"os\")"
                            s = s[1..^2]
                    result.subscripts.add(s)
                    result.subscripts.add(args[2..^1]) # add the restly keyparts if any (getvar @gbl(1,2,3))
                result.name = arg[0..<openPar]
            else:
                result.name = arg
        else:
            result.name = result.prefix & arg

        # handle typedesc "int16", ...
        if args.len > 2 and args[^2] == TYPEDESC:
            result.typdesc = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[2..^3]
        # handle attribute values (by=20, timeout=1111,)
        elif args.len > 2 and args[^2] == DATAVAL:
            result.value = args[^1]
            if result.subscripts.len == 0:
                result.subscripts = args[2..^3]
            else:
                result.subscripts = result.subscripts[0..^3]
        else:
            if result.subscripts.len == 0: result.subscripts = args[2..^1]

    else: # no prefix
        result.name = args[0] # local var
        if args.len > 2 and args[^2] == DATAVAL:
            result.value = args[^1]
            if result.subscripts.len == 0: result.subscripts = args[1..^3]
        else:
            result.subscripts = args[1..^1]

    if result.subscripts.len > 0 and result.subscripts[0].startsWith(INDIRECTION_SEQ):
        result.subscripts = stringToSeq(result.subscripts)


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

proc killnodexxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_node(ydbvar.name, ydbvar.subscripts)

proc delexclxxx*(args: varargs[string]) =
    var names: seq[string]
    for ydbvar in seqToYdbVars(args):
        names.add(ydbvar.name)
    ydb_delete_excl(names)

proc killxxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_tree(ydbvar.name, ydbvar.subscripts)

proc getxxx*(args: varargs[string]): string =
    let ydbvar = seqToYdbVar(args)
    result = ydb_get(ydbvar.name, ydbvar.subscripts)
    if ydbvar.value.len > 0 and result.len == 0:
        return ydbvar.value

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
    parseInt(getxxx(args)).int8
proc getxxxint16*(args: varargs[string]): int16 =
    parseInt(getxxx(args)).int16
proc getxxxint32*(args: varargs[string]): int32 =
    parseInt(getxxx(args)).int32
proc getxxxint64*(args: varargs[string]): int64 =
    parseInt(getxxx(args)).int64
proc getxxxuint*(args: varargs[string]): uint =
    parseUInt(getxxx(args)).uint

proc getxxxuint8*(args: varargs[string]): uint8 =
    parseUInt(getxxx(args)).uint8
proc getxxxuint16*(args: varargs[string]): uint16 =
    parseUInt(getxxx(args)).uint16
proc getxxxuint32*(args: varargs[string]): uint32 =
    parseUInt(getxxx(args)).uint32
proc getxxxuint64*(args: varargs[string]): uint64 =
    parseUInt(getxxx(args)).uint64

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
    if ydbvar.value.len == 0:
        ydb_increment(ydbvar.name, ydbvar.subscripts, 1)
    else:
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

proc nextnodexxxseq*(args: varargs[string]): (int, seq[string]) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_node_next(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, subs)
    elif rc == YDB_ERR_NODEEND:
        return (rc, @[])
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

proc nextsubscriptxxxseq*(args: varargs[string]): (int, seq[string]) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_subscript_next(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, subs)
    elif rc == YDB_ERR_NODEEND:
        return (rc, @[])
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

proc prevnodexxxseq*(args: varargs[string]): (int, seq[string]) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_node_previous(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, subs)
    elif rc == YDB_ERR_NODEEND:
        return (rc, @[])
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

proc prevsubscriptxxxseq*(args: varargs[string]): (int, seq[string]) =
    var ydbvar = seqToYdbVar(args)
    let (rc, subs) = ydb_subscript_previous(ydbvar.name, ydbvar.subscripts)
    if rc == YDB_OK:
        return (rc, subs)
    elif rc == YDB_ERR_NODEEND:
        return (rc, @[])
    else:
        let message = ydbMessage(rc.cint)
        raise newException(YdbError, fmt"{message}, Names: {ydbvar.name}({ydbvar.subscripts})")

proc setxxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value)


# --------------------------------
# Transaction Macros / Templates
# --------------------------------
macro tximpl*(name: string, body: untyped): untyped =
  let nameStr =
    if name.kind == nnkStrLit: name.strVal else: $name
  let procName = newIdentNode("" & nameStr)

  # Build the procedure definition
  result = nnkStmtList.newTree(
    nnkProcDef.newTree(
      procName,
      newEmptyNode(),
      newEmptyNode(),
      nnkFormalParams.newTree(
        newIdentNode("cint"),
        nnkIdentDefs.newTree(
          newIdentNode("param"),
          newIdentNode("pointer"),
          newEmptyNode()
        )
      ),
      nnkPragma.newTree(newIdentNode("cdecl")),
      newEmptyNode(),
      nnkStmtList.newTree(
        quote do:
          try:
            `body`
          except:
            return YDB_TP_RESTART
          return YDB_OK
      )
    ),
  )

template Transaction*(body: untyped): untyped =
  tximpl("TX"):
    body
  ydb_tp(TX, "")
template Transaction*(param: string = "", body: untyped): untyped =
  tximpl("TXP"):
    body
  ydb_tp(TXP, param)
template Transaction1*(body: untyped): untyped =
  tximpl("TX1"):
    body
  ydb_tp(TX1, "")
template Transaction1*(param: string = "", body: untyped): untyped =
  tximpl("TX1P"):
    body
  ydb_tp(TX1P, param)
template Transaction2*(body: untyped): untyped =
  tximpl("TX2"):
    body
  ydb_tp(TX2, "")
template Transaction2*(param: string = "", body: untyped): untyped =
  tximpl("TX2P"):
    body
  ydb_tp(TX2P, param)
template Transaction3*(body: untyped): untyped =
  tximpl("TX3"):
    body
  ydb_tp(TX3, "")
template Transaction3*(param: string = "", body: untyped): untyped =
  tximpl("TX3P"):
    body
  ydb_tp(TX3P, param)
template Transaction4*(body: untyped): untyped =
  tximpl("TX4"):
    body
  ydb_tp(TX4, "")
template Transaction4*(param: string = "", body: untyped): untyped =
  tximpl("TX4P"):
    body
  ydb_tp(TX4P, param)
template Transaction5*(body: untyped): untyped =
  tximpl("TX5"):
    body
  ydb_tp(TX5, "")
template Transaction5*(param: string = "", body: untyped): untyped =
  tximpl("TX5P"):
    body
  ydb_tp(TX5P, param)



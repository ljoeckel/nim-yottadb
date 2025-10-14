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
    PREFIX_CHARS = {'^', '$', '@'}
    INDIRECTION = "@"
    VALUEMARK = "!"
    TYPEDESC = "|TD|"
    DATAVAL = "|VAL|"
    FIELDMARK = "|"

proc transformCallNode(node: NimNode, args: var seq[NimNode]) =
    if node.kind in [nnkStrLit, nnkIntLit, nnkIdent]:
        args.add(newCall(ident"$", node))
    else:
        discard

proc findAttributes(node: NimNode, kv: var Table[string, NimNode]) =
    case node.kind
    of nnkStmtList, nnkCall, nnkCurly, nnkTupleConstr:
        for i in 0..<node.len:
            findAttributes(node[i], kv)
    of nnkExprEqExpr:   # by=, timeout=,...
        kv[repr(node[0])] = node[1]
    else:
        discard


proc transform(node: NimNode, args: var seq[NimNode]) =
    case node.kind
    of nnkStmtList, nnkCurly, nnkTupleConstr:
        for i in 0..<node.len:
            transform(node[i], args)
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
    of nnkExprEqExpr:   # by=, timeout=,... handeled by findAttributes
        discard
    of nnkDotExpr:
        transform(node[0], args)
        args.add(newLit(TYPEDESC))
        args.add(newCall(ident"$", node[1]))
    else:
        echo "transform Invalid kind: ", node.kind

proc processStmtList(body: NimNode): seq[NimNode] =
    for i in 0..<body.len:
        transform(body[i], result)
        result.add(newLit(FIELDMARK))
    
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

macro setvar*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"setxxx", args)

macro delnode*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"delnodexxx", args)

macro deltree*(body: untyped): untyped =
    let args = processStmtList(body)
    return newCall(ident"deltreexxx", args)

macro increment*(body: untyped): untyped =
    var args: seq[NimNode]
    var kv: Table[string, NimNode]
    findAttributes(body, kv)
    transform(body, args)
    if kv.hasKey("by"):
        args.add(newLit(DATAVAL))
        args.add(newCall(ident"$", kv["by"]))
    return newCall(ident"incrementxxx", args)


# ----------------------------
# proc related helper proc's
# ----------------------------

proc seqToYdbVars(args: varargs[string]): seq[YdbVar] =
    var subs: Subscripts
    var ydbvar: YdbVar

    var transargs: seq[Subscripts]
    # Remove terminator arg
    for arg in args:
        if arg != FIELDMARK:
            subs.add(arg)
        else:
            transargs.add(subs)
            subs = @[]
    
    # process all transargs
    for trans in transargs:
        for i in 0..<trans.len:
            let arg = trans[i]
            if arg == VALUEMARK: # a value terminator (setvar)
                ydbvar.value = trans[i - 1]
                if subs.len > 0: subs.delete(subs.len - 1)
                if ydbvar.subscripts.len == 0: ydbvar.subscripts = subs # dont overwrite @indirektions
                result.add(ydbvar)
                subs = @[]
                ydbvar = YdbVar()
            else:
                if subs.len == 0 and arg.len == 1 and arg[0] in PREFIX_CHARS:
                    ydbvar.prefix = arg
                    continue
                if ydbvar.name == "":
                    if ydbvar.prefix == INDIRECTION: # indirection
                        let openPar = arg.find('(') # handle subscripts
                        if openPar != -1:
                            let closePar = arg.find(')', openPar)
                            let index = arg[openPar + 1 ..< closePar]
                            for idx in split(index, ','):
                                ydbvar.subscripts.add(idx.strip())
                            ydbvar.name = arg[0..<openPar]
                        else:
                            ydbvar.name = arg
                    else:
                        ydbvar.name = ydbvar.prefix & arg
                else:
                    subs.add(arg)
    
        # something other than with value terminator (delnode, deltree, etc.)
        if ydbvar.name != "":
            if ydbvar.subscripts.len == 0: ydbvar.subscripts = subs
            result.add(ydbvar)
            subs = @[]
            ydbvar = YdbVar()


proc seqToYdbVar(args: varargs[string]): YdbVar =
    if args[0].len == 1 and args[0][0] in PREFIX_CHARS:
    #if "^$@".find(args[0]) >= 0:   # have prefix?
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
    else: # no prefix
        result.name = args[0] # local var
        result.subscripts = args[1..^1]


proc setxxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_set(ydbvar.name, ydbvar.subscripts, ydbvar.value)

proc delnodexxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_node(ydbvar.name, ydbvar.subscripts)

proc deltreexxx*(args: varargs[string]) =
    for ydbvar in seqToYdbVars(args):
        ydb_delete_tree(ydbvar.name, ydbvar.subscripts)

proc getxxx*(args: varargs[string]): string =
    let ydbvar = seqToYdbVar(args)
    ydb_get(ydbvar.name, ydbvar.subscripts)

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

proc getxxxfloat*(args: varargs[string]): float =
    parseFloat(getxxx(args))

proc getxxxfloat32*(args: varargs[string]): float32 =
  parseFloat(getxxx(args)).float32

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

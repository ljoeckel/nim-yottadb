import macros
import std/strutils
import std/strformat
import std/sets
import std/unittest
import utils
import libs/libydb
import libs/ydbtypes
import libs/ydbapi
import serialization/bingoser

proc transformCallNode(node: NimNode, args: var seq[NimNode]) =
    if node.kind in [nnkStrLit, nnkIntLit, nnkIdent]:
        args.add(newCall(ident"$", node))
    else:
        echo "transformCallNode Invalid kind: ", node.kind

proc transform(node: NimNode, args: var seq[NimNode]) =
    #echo "kind:", node.kind, " node:", repr(node)
    case node.kind
    of nnkStmtList:
        for i in 0..<node.len:
            transform(node[i], args)
    of nnkPrefix:
        args.add(newLit(node[0].strVal))
        transform(node[1], args)
    of nnkIdent:
        if args.len > 0 and args[0].strVal == "@": # indirektion
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
        args.add(newLit("!")) # value marker
    of nnkIntLit, nnkStrLit, nnkFloatLit:
        args.add(newCall(ident"$", node))
    of nnkDotExpr:
        transform(node[0], args)
        args.add(newLit("|TD|"))
        args.add(newCall(ident"$", node[1]))
    of nnkCurly, nnkTupleConstr:
        for i in 0..<node.len:
            transform(node[i], args)
    else:
        echo "transform Invalid kind: ", node.kind
    
macro get*(body: untyped): untyped =
    var args: seq[NimNode]
    if body.kind == nnkStmtList and body.len == 1:
        transform(body[0], args)
    else:
        transform(body, args)
    # check for type conversion
    if args.len > 2 and repr(args[^2]).contains("|TD|"):
        let s = repr(args[^1])
        var typename = s[s.find('(')+1..s.find(')')-1]
        return newCall(ident("getxxx" & typename), args[0..^3])
    else:
        return newCall(ident"getxxx", args)    

macro setvar*(body: untyped): untyped =
    var args: seq[NimNode]
    for i in 0..<body.len:
        transform(body[i], args)
        args.add(newLit("|"))
    return newCall(ident"setxxx", args)

macro delnode*(body: untyped): untyped =
    var args: seq[NimNode]
    for i in 0..<body.len:
        transform(body[i], args)
        args.add(newLit("|"))
    return newCall(ident"delnodexxx", args)

proc seqToYdbVars(args: varargs[string]): seq[YdbVar] =
    var subs: Subscripts
    var ydbvar: YdbVar

    var transargs: seq[Subscripts]
    # Remove terminator arg
    for arg in args:
        if arg != "|":
            subs.add(arg)
        else:
            transargs.add(subs)
            subs = @[]
    
    # process all transargs
    for trans in transargs:
        for i in 0..<trans.len:
            let arg = trans[i]
            if arg == "!": # a value terminator (setvar)
                ydbvar.value = trans[i - 1]
                if subs.len > 0: subs.delete(subs.len - 1)
                if ydbvar.subscripts.len == 0: ydbvar.subscripts = subs # dont overwrite @indirektions
                result.add(ydbvar)
                subs = @[]
                ydbvar = YdbVar()
            else:
                if subs.len == 0 and "^$@".find(arg) >= 0:
                    ydbvar.prefix = arg
                    continue
                if ydbvar.name == "":
                    if ydbvar.prefix == "@":
                        if arg.contains('('):
                            let index = arg[arg.find('(')+1..arg.find(')')-1]
                            for idx in split(index, ','):
                                ydbvar.subscripts.add(idx.strip())
                            ydbvar.name = arg[0..arg.find('(')-1]
                        else:
                            ydbvar.name = arg
                    else:
                        ydbvar.name = ydbvar.prefix & arg
                else:
                    subs.add(arg)
    
        # something other than with value terminator (delnode, deltree, etc.)
        if ydbvar.name.len > 0:
            if ydbvar.subscripts.len == 0: ydbvar.subscripts = subs
            result.add(ydbvar)
            subs = @[]
            ydbvar = YdbVar()


proc seqToYdbVar(args: varargs[string]): YdbVar =
    if "^$@".find(args[0]) >= 0:   # have prefix?
        result.prefix = args[0]
        let arg = args[1]
        # Handle indirection
        if result.prefix == "@":
            if arg.contains('('):
                let index = arg[arg.find('(')+1..arg.find(')')-1]
                for idx in split(index, ','):
                    result.subscripts.add(idx.strip())
                result.name = arg[0..arg.find('(')-1]
            else:
                result.name = arg
        else:
            result.name = result.prefix & arg

        # handle typedesc "int16", ...
        if args.len > 2 and args[^2] == "|TD|":
            result.typdesc = args[^1]
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

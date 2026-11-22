import yottadb
import std/unittest
import std/random
import ydbutils


const MAX_ELEMENTS = 1_00_000
var hugeInt = newSeqOfCap[int](MAX_ELEMENTS) # seq[int]
var hugeStr = newSeqOfCap[string](MAX_ELEMENTS) # seq[int]
var hugeFloat = newSeqOfCap[float](MAX_ELEMENTS) # seq[int]
var hugeBool = newSeqOfCap[bool](MAX_ELEMENTS) # seq[int]
for i in 0..MAX_ELEMENTS:
    hugeInt.add(rand(0..int.high))
    let txtlen = rand(1..30)
    var word: string
    for i in 0..txtlen:
        word.add(rand(65..90).char)
    hugeStr.add(word)
    let r = rand(0..int.high)
    hugeFloat.add((r/2).float * 1.25)
    hugeBool.add(if i mod 3 == 0: true else: false)


proc calcRatio(ms: int, bytes: int) =
    # like in binary.nim: measure compressed DB size to compute the ratio
    let compressedSize = calcSpace("^Sequence", false)
    let bps = bytes / (ms div 4) * 1000 # 4 sequences are writen/read in a test
    let ratio = bytes.float / compressedSize.float
    echo "App. Size: ", bytes, "b, Compressed Size: ", compressedSize,
         "b in ", ms, " ms. MB/sec=", bps / 1024 / 1024, "  Ratio=", ratio


template defineTest(typeName; compressed: bool = true): untyped =
    proc `testSeq typename compressed`(): int =
        Kill ^Sequence

        let algo = if compressed: astToStr(typeName) else: "raw"
        echo "Running test for '", algo, "'"

        # Return a typed value (uncompressed "app size") for timed_rc
        result = len($hugeStr) + len($hugeInt) + len($hugeFloat) + len($hugeBool)

        when compressed:
            Set: ^Sequence("hugeStr") = hugeStr.`typename`
            assert hugeStr == Get ^Sequence("hugeStr").seqString.`typename`

            Set: ^Sequence("hugeInt") = hugeInt.`typename`
            assert hugeInt == Get ^Sequence("hugeInt").seqInt.`typename`

            Set: ^Sequence("hugeFloat") = hugeFloat.`typename`
            assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat.`typename`

            Set: ^Sequence("hugeBool") = hugeBool.`typename`
            assert hugeBool == Get ^Sequence("hugeBool").seqBool.`typename`
        else:
            # raw baseline: store/read without any compression postfix
            Set: ^Sequence("hugeStr") = hugeStr
            assert hugeStr == Get ^Sequence("hugeStr").seqString

            Set: ^Sequence("hugeInt") = hugeInt
            assert hugeInt == Get ^Sequence("hugeInt").seqInt

            Set: ^Sequence("hugeFloat") = hugeFloat
            assert hugeFloat == Get ^Sequence("hugeFloat").seqFloat

            Set: ^Sequence("hugeBool") = hugeBool
            assert hugeBool == Get ^Sequence("hugeBool").seqBool
        

defineTest(raw, false)        # raw baseline: no compression
defineTest(gzip)
defineTest(zlib)
defineTest(lz4)
defineTest(zstd)


template runTest(typeName; compressed: bool = true): untyped =
    var (ms, bytes) = timed_rc:
        `testSeq typeName compressed`()
    calcRatio(ms, bytes)


when isMainModule:
    echo "Running tests for ", MAX_ELEMENTS, " random elements in a sequence"
    Kill ^Sequence

    test "raw (no compression)": runTest(raw, false)
    test "gzip": runTest(gzip)
    test "zlib": runTest(zlib)
    test "lz4": runTest(lz4)
    test "Zstd": runTest(zstd)

    test "value formats":
        Kill ^SeqFmt

        # plain format: `join(seq, ",")`
        Set: ^SeqFmt("ints") = "1,2,3"
        check @[1, 2, 3] == Get ^SeqFmt("ints").seqInt

        # spaces are accepted in both formats now (plain used to give @[1, 0, 0])
        Set: ^SeqFmt("intsSpaced") = "1, 2, 3"
        check @[1, 2, 3] == Get ^SeqFmt("intsSpaced").seqInt
        Set: ^SeqFmt("intsNeg") = " -7, 0, 42 "
        check @[-7, 0, 42] == Get ^SeqFmt("intsNeg").seqInt

        # `@[..]` format: what `Set: ^x(1) = seq` stores via `$seq`
        Set: ^SeqFmt("intsAt") = "@[1, 2, 3]"
        check @[1, 2, 3] == Get ^SeqFmt("intsAt").seqInt
        Set: ^SeqFmt("intsQuoted") = "@[\"1\", \"2\"]"
        check @[1, 2] == Get ^SeqFmt("intsQuoted").seqInt

        # boundary values must stay on the fast path
        Set: ^SeqFmt("intsEdge") = $high(int) & "," & $low(int) & ",0"
        check @[high(int), low(int), 0] == Get ^SeqFmt("intsEdge").seqInt

        # floats
        Set: ^SeqFmt("floats") = "1.5, -2.25, .5, 3."
        check @[1.5, -2.25, 0.5, 3.0] == Get ^SeqFmt("floats").seqFloat
        Set: ^SeqFmt("floatsAt") = "@[1.5, -2.25]"
        check @[1.5, -2.25] == Get ^SeqFmt("floatsAt").seqFloat
        Set: ^SeqFmt("floatsExp") = "1e3, 2.5"
        check @[1000.0, 2.5] == Get ^SeqFmt("floatsExp").seqFloat

        # bools
        Set: ^SeqFmt("bools") = "1, 0, T, F"
        check @[true, false, true, false] == Get ^SeqFmt("bools").seqBool
        Set: ^SeqFmt("boolsAt") = "@[true, FALSE, 1]"
        check @[true, false, true] == Get ^SeqFmt("boolsAt").seqBool

        # strings: the `@[..]` format is trimmed, the plain one is not
        Set: ^SeqFmt("strs") = "@[\"a\", \"bb\", \"\"]"
        check @["a", "bb", ""] == Get ^SeqFmt("strs").seqString
        Set: ^SeqFmt("strsPlain") = "a,b ,c"
        check @["a", "b ", "c"] == Get ^SeqFmt("strsPlain").seqString

        # round trip through `$seq`
        let ints = @[5, -6, 70_000]
        Set: ^SeqFmt("rtInts") = ints
        check ints == Get ^SeqFmt("rtInts").seqInt
        let strs = @["x", "y z", "q"]
        Set: ^SeqFmt("rtStrs") = strs
        check strs == Get ^SeqFmt("rtStrs").seqString

        # a large value in the plain format (not covered by the tests above)
        var joined = newStringOfCap(hugeInt.len * 8)
        for i, v in hugeInt:
            if i > 0: joined.add ','
            joined.add $v
        Set: ^SeqFmt("hugeJoined") = joined
        check hugeInt == Get ^SeqFmt("hugeJoined").seqInt

        # values the fast scanners reject keep their historical result
        # (fallback to the token parser, which swallows the parse error)
        Set: ^SeqFmt("intsTrailingComma") = "1,2,"
        check @[1, 2, 0] == Get ^SeqFmt("intsTrailingComma").seqInt
        Set: ^SeqFmt("emptyString") = ""
        check @[""] == Get ^SeqFmt("emptyString").seqString

        Kill ^SeqFmt

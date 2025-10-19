template processStmtList(body: untyped): untyped =
    if body.kind == nnkStmtList:
        result = newStmtList()
        for i in 0..<body.len:
            transform(body[i], result)
            result.add(newLit(FIELDMARK))
            echo "processStmtList args=", repr(result)
    else:
        raise newException(Exception, "Statement list needed, got ", body.kind)

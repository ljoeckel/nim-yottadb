import macros
import yottadb

# dumpTree:
#     lock: {^LL(4711), 
#     ^LL(1), timeout=774455
#     }

# Call
#     Ident "lock"
#     ExprEqExpr
#       Ident "timeout"
#       IntLit 1000
#     StmtList
#       Curly
#         Prefix
#           Ident "^"
#           Call
#             Ident "LL"
#             StrLit "HAUS"
#             StrLit "11"


let id = "0815"
lock: {^ll(4711), ^xyz("ABC"), ^abc(id), timeout=774455}
echo "locks.set=", getLocksFromYottaDb()

lock: {} # release all locks
echo "locks.set after release=", getLocksFromYottaDb()
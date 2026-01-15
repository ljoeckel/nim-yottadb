import yottadb
import std/sets 
import std/strutils
import std/cmdline
import ydbutils

# First draft for the 3n+1 problem
var 
    numbers_found, numbers_solved, dbwrites, dbdata, dbnext, verifyread: int

func calc(n: int): int =
    # Calculate 3n+1
    if n mod 2 == 0:
        n div 2
    else:
        3*n + 1

proc verify(n: int): seq[int] =
    # Calculate a full sequence
    result.add(n)
    if n == 1: return

    var s = calc(n)
    while not result.contains(s):
        result.add(s)
        if s == 1: break
        s = calc(s)

proc solve(n: int): seq[int]  =
    result.add(n)
    if n == 1: return

    var s = calc(n)
    while s > 0:
        result.add(s)
        inc dbdata
        if data(^solver(s)) == 1: # Already solved?
            inc numbers_solved
            break

        s = calc(s)

proc generate(fromN: int, toN: int) =
    # Generate the sequence and save on db
    for n in fromN..toN:
        if n mod 100_000 == 0: echo n
        inc dbdata
        if data(^solver(n)) == 1:
            inc numbers_found
        else:
            setvar: ^solver(n) = join(solve(n), ",")
            inc dbwrites

proc reconstruct(n: int): seq[int] =
    # Reconstruct the sequence from the db to the full sequence
    inc verifyread
    for num in getvar ^solver(n).OrderedSet:
        result.add(num)
    let lastnum = result[^1]
    if lastnum > 1:
        result.add(reconstruct(lastnum)[1..^1])

proc check(fromN: int, toN: int) =
    # Compute 3n+1 again and verify the calculated with the truncated results on the db.
    for subs in queryItr ^solver.keys:
        inc dbnext
        let n = parseInt(subs[0])
        if n < fromN or n > toN: continue
        if n mod 100000 == 0: echo "Verify ", n
        assert reconstruct(n) == verify(n)

proc cleanDb() =
    kill: ^solver

proc statistics(fromN: int, toN: int) =
    echo "solver from: ", fromN, " to: ", toN
    echo "Found : ", numbers_found, " Solved: ", numbers_solved
    echo "dbwrites: ", dbwrites, ", dbdata: ", dbdata, ", dbnext: ", dbnext, " verifyread: ", verifyread


when isMainModule:
    # get from cmdline
    var (fromN, toN) = (1, 1_000_000)
    var clean = true
    var verifycheck = false
    for param in commandLineParams():
        if param.contains("-from="): fromN = parseInt(param.split("=")[1])
        if param.contains("-to="): toN = parseInt(param.split("=")[1])
        if param.contains("-clean="): clean = if param.split("=")[1] == "true": true else: false
        if param.contains("-verify="): verifycheck = if param.split("=")[1] == "true": true else: false

    if clean:
        timed("cleanDb")   : cleanDb()
    if not verifycheck:
        timed("generate"):
            generate(max(1, fromN), toN)
            statistics(fromN, toN)
    if verifycheck:
        timed("verify"):
            check(max(1, fromN), toN)
            statistics(fromN, toN)

    quit(0)
# TODO: 
#       Locks
#       Transaction?
#       Statistics

# nim c -r --threads:off -d:release -d:danger solver
# 1..100_000 setup: 2 ms.
#            generate: 264 ms.
#            verify: < 1 ms.
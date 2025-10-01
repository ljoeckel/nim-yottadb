import yottadb
import std/sets 
import std/strutils
import std/cmdline
import utils

# First draft for the 3n+1 problem
var 
    numbers_saved = 0
    numbers_found = 0
    numbers_solved = 0

func calc(n: int): int =
    # Calculate 3n+1
    if n == 2: result = 1
    elif n mod 2 == 0: result = n div 2
    else: result = 3*n + 1

proc verify(n: int): OrderedSet[int] =
    # Calculate a full sequence
    result = initOrderedSet[int]()
    result.incl(n)
    if n == 1: return

    var s = calc(n)
    while not result.contains(s):
        result.incl(s)
        s = calc(s)

proc solve(n: int): OrderedSet[int]  =
    # Solve the 3n+1 problem and mark the sequence that already calculated sequences on the db exists.
    result = initOrderedSet[int]()
    result.incl(n)
    if n == 1: return

    var s = calc(n)
    while s >= 0:
        if data(^solver(s)) == 1: # lookup in db
            result.incl(s * -1)
            inc numbers_solved
            break

        result.incl(s)
        s = calc(s)

proc generate(fromN: int, toN: int) =
    # Generate the sequence and save on db
    for n in fromN..toN:
        if n mod 100_000 == 0: echo n
        if data(^solver(n)) == 1:
            inc numbers_found
        else:
            let result = solve(n) # calculate and save on db
            var str = ($result)[1..^2] # remove {}
            set: ^solver(n) = str.replace(" ","") # trim spaces
            inc numbers_saved

proc reconstruct(n: int): OrderedSet[int] =
    # Reconstruct the sequence from the db to the full sequence
    result = initOrderedSet[int]()
    for n in get(^solver(n).OrderedSet):
        if n < 0:
            result.incl(n * - 1)
            let subset = reconstruct(n * -1)
            for element in subset:
                result.incl(element)
        else:
            result.incl(n)

proc check() =
    # Compute 3n+1 again and verify the calculated with the truncated results on the db.
    for subs in ydb_node_next_iter("^solver"):
        let n = parseInt(subs[0])
        if n < 3: continue # start processing from 3 on
        assert reconstruct(n) == verify(n)

proc cleanDb() =
    if not deleteGlobal("^solver"):
        raise newException(YdbError, "Could not delete global ^solver")
    set:
        ^solver(1)=1
        ^solver(2)="2,-1"
        ^solver(4)="4,-2"

proc statistics(fromN: int, toN: int) =
    echo "solver from: ", fromN, " to: ", toN
    echo "Found : ", numbers_found
    echo "Solved: ", numbers_solved
    echo "Saved : ", numbers_saved


when isMainModule:
    # get from cmdline
    var (fromN, toN) = (1, 100_000)
    var clean = true
    for param in commandLineParams():
        if param.contains("-from="): fromN = parseInt(param.split("=")[1])
        if param.contains("-to="): toN = parseInt(param.split("=")[1])
        if param.contains("-clean="): clean = if param.split("=")[1] == "true": true else: false

    if clean: timed("cleanDb")   : cleanDb()
    timed("generate"): generate(fromN, toN)
    timed("verify")  : check()
    statistics(fromN, toN)

# TODO: 
#       Locks
#       Transaction?
#       Statistics

# nim c -r --threads:off -d:release -d:danger solver
# 1..100_000 setup: 43 ms.
#            generate: 325 ms.
#            verify: 16 ms.
import std/[strutils, os, osproc]
import malebolgia
import utils

proc runSolver*(fromN:int, toN:int, clean:bool) =
    let solver = findExe("./solver")
    if solver.isEmptyOrWhitespace():
        raise newException(IOError, "'solver' binary not found")
    else:
        if execCmd("./solver --from=" & $fromN & " --to=" & $toN &  " --clean=" & $clean) != 0:
            raise newException(IOError, "'solver' had a problem")


when isMainModule:
    var m = createMaster()
    var (fromN, toN, step) = (1, 10_000_000, 1_250_000)

    timed:
        m.awaitAll:
            while fromN <= toN:
                echo "spawn ", fromN, " to ", fromN + step
                m.spawn runSolver(fromN, fromN + step, false)
                inc(fromN, step)
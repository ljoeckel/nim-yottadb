when not compileOption("threads"):
  {.fatal: "Must be compiled with --threads:on".}

import std/[strutils, os, osproc]
import malebolgia
import ydbutils


proc runSolver*(fromN: int, toN: int, clean: bool = false, verify: bool = false) =
    let solver = findExe("./solver")
    if solver.len == 0:
        raise newException(IOError, "'solver' binary not found")
    else:
        if execCmd("./solver --from=" & $fromN & " --to=" & $toN &  " --clean=" & $clean & " --verify=" & $verify) != 0:
            raise newException(IOError, "'solver' had a problem")


when isMainModule:
    var m = createMaster()
    var (fromN, toN, step) = (1, 10_000_000, 1_250_000)

    timed:
        m.awaitAll:
            while fromN <= toN:
                echo "spawn ", fromN, " to ", fromN + step
                m.spawn runSolver(fromN, fromN + step)
                inc(fromN, step)

    echo "-------- VERIFY --------"
    (fromN, toN, step) = (1, 10_000_000, 1_250_000)
    timed:
        m.awaitAll:
            while fromN <= toN:
                echo "spawn verify ", fromN, " to ", fromN + step
                m.spawn runSolver(fromN, fromN + step, clean=false, verify=true)
                inc(fromN, step)

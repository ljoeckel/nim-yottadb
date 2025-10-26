import yottadb
import std/[cmdline, strutils, strformat, math, times, random, terminal]
import ydbutils

const
    bidders = 2   # Contention (26 optimum on macmini m4)
    duration = 5  # Seconds

let pid = getvar: $JOB
let auction = "^Auction(1)"

proc bidTx(p0: pointer): cint {.cdecl.} =
    try:
        let first = (pid == getvar @auction("Leader"))
        if not first:
            let price = getvar @auction("Price").int
            let raisedBy = rand(1..10)
            let newprice = price + raisedBy
            setvar:
                @auction("Leader") = pid
                @auction("Price") = newprice
        discard increment @auction("Total")
    except:
        return YDB_TP_RESTART
    YDB_OK

proc incrementBidderTx(p0: pointer): cint {.cdecl.} =
    try:
        setvar: BIDDER = increment @auction("Bidders")
    except:
        return YDB_TP_RESTART
    YDB_OK

proc decrementBidderTx(p0: pointer): cint {.cdecl.} =
    try:
        discard increment (@auction("Bidders"), by=(-1))
    except:
        return YDB_TP_RESTART
    YDB_OK


proc Auction() =
    kill: ^Auction
    setvar:
        @auction = "R2D2"        # Astromech droid up for sale
        @auction("Active") = ""  # Begun, the auction has not
        @auction("Bidders") = 0  # No registered bidders
        @auction("Price") = 0    # Galactic Credits
        @auction("Leader") = 0   # No auction leader

    eraseScreen()
    setCursorPos(0,0)

    echo "Launching all ", bidders, " bidder processes"
    for i in 1..bidders:
        let processId = job("./bidwars", @["Bidder"])
    
    echo "Waiting for bidder registration"
    while (getvar @auction("Bidders").int) != bidders: nimSleep(50)
    echo "Start Auction"
    let start = getTime()
    setvar: @auction("Active") = "Yes"

    for i in 0..duration*10: 
        var sum, avgcnt = 0

        setCursorPos(0,3)
        echo "Bid:       ", getvar @auction("Total")
        echo "Price:     ", getvar @auction("Price")

        var (rc, gbl) = nextsubscript @auction("Bidders", "Average", "")
        while rc == YDB_OK:
            inc avgcnt
            inc(sum, getvar @gbl.int)
            (rc, gbl) = nextsubscript @gbl
        if sum > 0:
            echo "Stats:     ", (sum div avgcnt), " microseconds per bid"
        nimSleep(100)

    # Stop auction
    echo "Waiting for final bids"
    setvar: @auction("Active") = "No"
    var cnt = 10
    while (getvar @auction("Bidders").int) > 0: 
        nimSleep(100)
        dec cnt
        if cnt == 0: 
            echo "Timeout while waiting for Bidders to quit"
            break
        
    # show results
    let millis = (getTime() - start).inMilliseconds
    let total = getvar @auction("Total").int
    let bidsps = total / millis * 1000
    echo fmt"{(getvar @auction)} sold to id={getvar @auction(""Leader"")} for {getvar @auction(""Price"")} galactic credits"
    echo fmt"We received {total} bids in {(millis / 1000):<.2f} seconds."
    echo fmt"That's an epic {bidsps.int} bids per second"


proc Bidder() =
    let start = getTime()
    var avg, count = 0
    let rc = ydb_tp(incrementBidderTx, "") # sets the BIDDER variable
    #let bidder = getvar BIDDER
    setvar: @auction("Bidders", pid) = getvar BIDDER # Register linux process id

    # Wait until auction is started
    while ("Yes" != getvar @auction("Active")): nimSleep(50)

    var then = getTime()
    while (getvar @auction("Active")) == "Yes":
        var rc = ydb_tp(bidTx, "") # check / place Bid
        let now = getTime()
        if (now - start).inSeconds > 10: # end process after 10 seconds
            echo "Auction > 10 seconds. Quit Bidder process"
            break

        let duration = (now - then).inMicroseconds()
        inc count
        avg = avg + ((duration - avg) div count)
        then = now
        setvar: @auction("Bidders", "Average", pid) = avg

    discard ydb_tp(decrementBidderTx, "")

if isMainModule:
    if commandLineParams().len == 0:
        Auction()
        stdout.resetAttributes()
    else:
        Bidder()

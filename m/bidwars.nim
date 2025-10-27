import yottadb
import std/[cmdline, strformat, math, times, random, terminal]
import ydbutils
when compileOption("profiler"):  # --profiler:on
    import std/nimprof

#      bids per second /Journal disabled     enabled
# Bidders  BidWars M       bidwars   Nim      M   Nim            -d:danger   %
# 1             1_270_656        630_707   8742  9195       643_648   101  
# 2             1_090_261        585_681   7876  7795                  86
# 3               877_282        470_950   7514  7383                  86
# 4               715_913        412_281   7861  7599       437_914    73
# 5               570_259        314_969   8299  8049                  81
# 6               448_086        251_005   8742  8548                  78
# 7               347_133        200_871                               73
# 8               276_849        161_364                    187_017    71
# 9               230_721        133_468                               72
# 10              199_629        120_095                               65
# 11              170_037        104_188                               63
# 12              147_451         84_809                     91_256    75
# 13              129_125         76_935                               69
# 14              122_269         75_298                               62
# 15              118_260         66_446                     69_305    78
# 16              103_106         63_957                     68_780    63
# 20               88_032         54_323                               62
# 30               77_879         46_762                     47_359    67

const
    bidders = 4   # Contention (26 optimum on macmini m4)
    duration = 5  # Seconds

let pid = getvar: $JOB
let auction = "^Auction(1)"

# -----------------
# The Auctionator
# -----------------

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


# ---------------
# The Bidder
# ---------------

proc Bidder() =
    var rc = Transaction:
        # Register linux process id
        setvar: @auction("Bidders", pid) = increment @auction("Bidders")

    # Wait until auction is started
    while ("Yes" != getvar @auction("Active")): nimSleep(50)

    var count, avg = 0
    var then = getTime()
    while (getvar @auction("Active")) == "Yes":
        let rc = Transaction2: # place bid
            let first = (pid == getvar @auction("Leader"))
            if not first:
                let price = getvar @auction("Price").int
                let raisedBy = rand(1..10)
                let newprice = price + raisedBy
                setvar:
                    @auction("Leader") = pid
                    @auction("Price") = newprice
            discard increment @auction("Total")

        inc(count)
        let now = getTime()
        let duration = (now - then).inMicroseconds()
        avg = avg + ((duration - avg) div count)
        setvar: @auction("Bidders", "Average", pid) = avg    
        then = now

    rc = Transaction3:
        discard increment (@auction("Bidders"), by=(-1))

if isMainModule:
    if commandLineParams().len == 0:
        Auction()
    else:
        Bidder()

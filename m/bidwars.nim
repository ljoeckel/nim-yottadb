import yottadb
import std/[cmdline, strformat, math, times, random, terminal, strutils]
import ydbutils
when compileOption("profiler"):  # --profiler:on
    import std/nimprof

# YottaDB r2.02
#      bids per second /Journal disabled     enabled
# Bidders  BidWars M         bidwars  Nim    M    Nim 
# 1             1_270_656        643_648    8742  9195
# 2             1_090_261        585_681    7876  7795              
# 3               877_282        470_950    7514  7383              
# 4               715_913        437_914    7861  7599
# 6               448_086        251_005    8742  8548              
# 8               276_849        187_017    9802  9738
# 12              147_451         91_256   12287 12298
# 16              103_106         68_780   15415 15007
# 20               88_032         54_323   18153 17891                       
# 30               77_879         47_359   23210 23158


# YottaDB r2.03 / nim 2.2.4 / nim-yottadb 0.3.3
#      bids per second /Journal disabled       enabled
# Bidders  BidWars M       bidwars Nim        M     Nim     
# 1       1_265_267          706_911         8827   9680    
# 2         966_431          581_365         7391   7057
# 4         839_104          547_503         6639   6732
# 6         791_358          544_605         9789   8836
# 8         739_193          553_806         9363   9886
# 12        530_986          528_193        11897  12044
# 16        644_320          529_181        14483  14429
# 20        442_320          519_030        16544  16120
# 30        491_321          489_991        19288  19117

# YottaDB r2.03 / nim 2.2.6 / nim-yottadb 0.3.4
#      bids per second /Journal disabled       enabled
# Bidders  BidWars M       bidwars Nim        M      Nim     
# 1       1_292_594         755_645          8811    9953
# 2                         659_638          7931    8174
# 4         823_167         634_635          7968    7943
# 6                         621_603          8939    8873
# 8         787_437         617_343          9860    9822
# 12                        613_502         12452   12313
# 16        643_781         611_529         15131   15236
# 20                        594_183         17750   17846
# 30        502_460         572_914         21476   21577

const
    bidders = 30
    duration = 5  # Seconds

let pid = Get: $JOB
const auction = "^Auction(1)"

# -----------------
# The Auctionator
# -----------------

proc Auction() =
    Kill: ^Auction
    Set:
        @auction = "R2D2"        # Astromech droid up for sale
        @auction("Active") = ""  # Begun, the auction has not
        @auction("Bidders") = 0  # No registered bidders
        @auction("Price") = 0    # Galactic Credits
        @auction("Leader") = 0   # No auction leader

    eraseScreen()
    setCursorPos(0,0)

    echo "Launching all ", bidders, " bidder processes"
    for i in 1..bidders:
        discard job("./bidwars", @["Bidder"])
    
    echo "Waiting for bidder registration"
    while (Get @auction("Bidders").int) != bidders: nimSleep(50)
    
    echo "Start Auction"
    let start = getTime()
    Set: @auction("Active") = "Yes"

    for i in 0..duration*10: 
        setCursorPos(0,3)
        echo "Bid:       ", Get @auction("Total")
        echo "Price:     ", Get @auction("Price")

        # show average bid time for all bidders
        var sum, avgcnt = 0
        for pid in OrderItr @auction("Bidders","Average",""):
            let avg = Get @auction("Bidders","Average",pid).int
            if avg > 0:
                inc avgcnt
                inc(sum, avg)
        if sum > 0:
            echo "Stats:     ", (sum div avgcnt), " microseconds per bid"

        nimSleep(100)

    # Stop auction
    echo "Waiting for final bids"
    Set: @auction("Active") = "No"
    var cnt = 10
    while (Get @auction("Bidders").int) > 0: 
        nimSleep(100)
        dec cnt
        if cnt == 0: 
            echo "Timeout while waiting for Bidders to quit"
            break
        
    # show results
    let millis = (getTime() - start).inMilliseconds
    let total = Get @auction("Total").int
    let bidsps = total / millis * 1000
    echo fmt"{(Get @auction)} sold to id={Get @auction(""Leader"")} for {Get @auction(""Price"")} galactic credits"
    echo fmt"We received {total} bids in {(millis / 1000):<.2f} seconds."
    echo fmt"That's an epic {bidsps.int} bids per second"


# ---------------
# The Bidder
# ---------------

proc Bidder() =
    var rc = Transaction:
        Set: @auction("Bidders", pid) = Increment @auction("Bidders")

    # Wait until auction is started
    while ("Yes" != Get @auction("Active")): nimSleep(50)

    var count, avg = 0
    var then = getTime()
    while (Get @auction("Active")) == "Yes":
        rc = Transaction: # place bid
            if pid != Get @auction("Leader"):
                let price = Get @auction("Price").int
                let raisedBy = rand(1..10)
                let newprice = price + raisedBy
                Set:
                    @auction("Leader") = pid
                    @auction("Price") = newprice
            discard Increment @auction("Total")

        inc(count)
        let now = getTime()
        let duration = (now - then).inMicroseconds()
        avg = avg + ((duration - avg) div count)
        Set: @auction("Bidders", "Average", pid) = avg    
        then = now

    rc = Transaction:
        discard Increment (@auction("Bidders"), by=(-1))

if isMainModule:
    if commandLineParams().len == 0:
        Auction()
    else:
        Bidder()

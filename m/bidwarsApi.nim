import yottadb
import std/[cmdline, strformat, strutils, math, times, random, terminal]
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


# YottaDB r2.03
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

const
    bidders = 30   # Contention (26 optimum on macmini m4)
    duration = 5  # Seconds

let pid = Get $JOB
let auction = "^Auction"

# -----------------
# The Auctionator
# -----------------

proc Auction() =
    Kill: ^Auction
    var rootKey = initYdbKey(auction, "1")
    ydb_set(rootKey, "R2D2") # Astromech droid up for sale
    var activeKey = initYdbKey(auction, "1", "Active")
    ydb_set(activeKey, "")
    var biddersKey = initYdbKey(auction, "1", "Bidders")
    ydb_set(biddersKey, "0")
    var priceKey = initYdbKey(auction, "1", "Price")
    ydb_set(priceKey, "0")
    var leaderKey = initYdbKey(auction, "1", "Leader")
    ydb_set(leaderKey, "0")
    var totalKey = initYdbKey(auction, "1", "Total")
    
    eraseScreen()
    setCursorPos(0,0)

    echo "Launching all ", bidders, " bidder processes"
    for i in 1..bidders:
        let processId = job("./bidwars", @["Bidder"])
    
    echo "Waiting for bidder registration"
    while (parseInt(ydb_get(biddersKey))) != bidders: nimSleep(50)
    
    echo "Start Auction"
    let start = getTime()
    ydb_set(activeKey, "Yes")

    for i in 0..duration*10: 
        var sum, avgcnt = 0
        setCursorPos(0,3)
        echo "Bid:       ", ydb_get(totalKey)
        echo "Price:     ", ydb_get(priceKey)

        var avgKey = initYdbKey(auction, "1", "Bidders", "Average", "")
        var pid = ydb_subscript_next(avgKey)
        while pid != "":
            inc avgcnt 
            inc(sum, parseInt(ydb_get(avgKey)))
            pid = ydb_subscript_next(avgKey)
        if sum > 0:
            echo "Stats:     ", (sum div avgcnt), " microseconds per bid"
        nimSleep(100)

    # Stop auction
    echo "Waiting for final bids"
    ydb_set(activeKey, "No")
    var cnt = 10
    while (parseInt(ydb_get(biddersKey)))  > 0: 
        nimSleep(100)
        dec cnt
        if cnt == 0: 
            echo "Timeout while waiting for Bidders to quit"
            break
        
    # show results
    let total = parseInt(ydb_get(totalKey))
    let good = ydb_get(rootKey)
    let soldTo = ydb_get(leaderKey)
    let price = ydb_get(priceKey)

    let millis = (getTime() - start).inMilliseconds
    let bidsps = total / millis * 1000

    echo fmt"{good} sold to id={soldTo} for {price} galactic credits"
    echo fmt"We received {total} bids in {(millis / 1000):<.2f} seconds."
    echo fmt"That's an epic {bidsps.int} bids per second"


# ---------------
# The Bidder
# ---------------

proc Bidder() =
    var activeKey = initYdbKey(auction, "1", "Active")
    var avgKey = initYdbKey(auction, "1", "Bidders", "Average", $pid)

    var rc = Transaction:
        # Register linux process id
        Set: @auction("Bidders", pid) = Increment @auction("Bidders")
        var biddersKey = initYdbKey(auction, "1", "Bidders")
        let bidder = ydb_increment(biddersKey)
        biddersKey.addSub($pid)
        ydb_set(biddersKey, $bidder)

    # Wait until auction is started
    while ("Yes" != ydb_get(activeKey)): nimSleep(50)

    var count, avg = 0
    var then = getTime()
    while (ydb_get(activeKey) == "Yes"):
        let rc = Transaction: # place bid
            var leaderKey = initYdbKey(auction, "1", "Leader")
            var priceKey = initYdbKey(auction, "1", "Price")
            var totalKey = initYdbKey(auction, "1", "Total")
            let first = (pid == ydb_get(leaderKey))
            if not first:
                let price = parseInt(ydb_get(priceKey))
                let raisedBy = rand(1..10)
                let newprice = price + raisedBy
                ydb_set(leaderKey, $pid)
                ydb_set(priceKey, $newprice)
            discard ydb_increment(totalKey)

        inc(count)
        let now = getTime()
        let duration = (now - then).inMicroseconds()
        avg = avg + ((duration - avg) div count)
        ydb_set(avgKey, $avg)    
        then = now

    rc = Transaction:
        var biddersKey = initYdbKey(auction, "1", "Bidders")
        discard ydb_increment(biddersKey, -1)

if isMainModule:
    if commandLineParams().len == 0:
        Auction()
    else:
        Bidder()

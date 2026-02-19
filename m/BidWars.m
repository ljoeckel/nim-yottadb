; Bid Wars - A New Hope

	use $principal:(x=0:y=0:clear)
	Kill ^Auction
	set bidders=5                 ; Contention
	set duration=5                ; Seconds
	set ^Auction(1)="R2D2"        ; Astromech droid up for sale
	set ^Auction(1,"Active")=""   ; Begun, the auction has not
	set ^Auction(1,"Bidders")=0   ; No registered bidders
	set ^Auction(1,"Price")=0     ; Galactic Credits
	set ^Auction(1,"Leader")=0    ; No auction leader
	
	write "Launching all ",bidders," bidder processes",!
	for i=1:1:bidders do
	. job Bidder^BidWars
	
	write "Waiting for bidder registration",!
	for  quit:^Auction(1,"Bidders")=bidders  hang 0.1

	write "Auction started",!
	set ^Auction(1,"Active")="Yes"
	set start=$zut
	set x=$X,y=$Y

	for  quit:($zut-start)/1000000>=duration  do
	. tstart ()
	. set (avg,sum,count)=0
	. set i=""
	. for  set i=$Order(^Auction(1,"Bidders",i)) quit:i=""  do
	. . if $Data(^Auction(1,"Bidders",i,"Average")) do
	. . . set sum=sum+$get(^Auction(1,"Bidders",i,"Average"),0)
	. . . set count=count+1
	. set:count avg=sum/count
	. set price=$get(^Auction(1,"Price"),0)
	. set total=$get(^Auction(1,"Total"),0)
	. tcommit
	. use $principal:(x=x:y=y)
	. write "Bid:     ",$fn(total,","),!
	. write "Price:   ",$fn(price,","),!
	. write "Stats:   ",$fn(avg,",",4)," microseconds per bid ",!
	. hang 0.1

	set ^Auction(1,"Active")="No"
	set stop=$zut
	write "Waiting for final bids",!
	for  quit:^Auction(1,"Bidders")=0  hang 0.1

	set winner=^Auction(1,"Leader")
	set price=^Auction(1,"Price")
	set total=^Auction(1,"Total")
	set time=(stop-start)/1000000
	write ^Auction(1)," sold to id=",winner," for ",$fn(price,",")," galactic credits",!
	write "We recieved ",$fn(total,",")," total bids in ",$fn(time,",",2)," seconds",!
	write "That's an epic ",$fn(total\time,",")," bids per second.",!
	quit
	
Bidder
	tstart ()
	set i=$Increment(^Auction(1,"Bidders")) ; +1
	set ^Auction(1,"Bidders",$job)=i     	; Register linux process id
	tcommit

	for  quit:^Auction(1,"Active")'=""  hang 0.1
	
	set (avg,count)=0
	set then=$zut

	for  quit:^Auction(1,"Active")="No"  do
	. tstart (avg,count)
	. set first=(^Auction(1,"Leader")=$job)	  ; Is this process our auction leader?
	. if 'first do 							  ; Place another bid only when losing
	. . set price=^Auction(1,"Price")		  ; Retrieve current auction price
	. . set raise=$random(10)+1				  ; Raise bid by a minimum of one
	. . set ^Auction(1,"Leader")=$job		  ; Process becomes leader on commit
	. . set ^Auction(1,"Price")=price+raise
	. if $Increment(^Auction(1,"Total"))
	. set now=$zut
	. set avg=avg+(((now-then)-avg)/$Increment(count))
	. set ^Auction(1,"Bidders",$job,"Average")=avg
	. tcommit
	. set then=now

	if $Increment(^Auction(1,"Bidders"),-1)
	quit

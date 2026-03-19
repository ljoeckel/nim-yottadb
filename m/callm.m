callm   ;
        quit

method1 ; Echo back CTX set by Nim program
	; Use this form if 'Nim macro CallM' is used
  	set key="CTX"
	set i=0
	set RESULT="Traverse RESULT with QueryItr"
  	for  set key=$query(@key) quit:key=""  do
  	. set value=$get(@key)
	. set RESULT(i)=value
	. set i=i+1
        quit

method2 ; echo back some text with CTX (single argument)
        set RESULT="TheResultFrom YDB CTX="_CTX
        quit

method3 ; echo back some text with CTX (multiple arguments)
        set RESULT="From callin: CTX(1..4)="_CTX(1)_","_CTX(2)_","_CTX(3)_","_CTX(4)
	quit

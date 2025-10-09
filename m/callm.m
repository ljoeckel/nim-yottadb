callm   ;
        quit

method1 ; Echo back VAR1 set by Nim program
        set RESULT=VAR1
        quit

method2 ; make something with VAR1 set by Nim program
        write VAR1
        ; ....
        set RESULT="TheResultFrom YDB"
        quit
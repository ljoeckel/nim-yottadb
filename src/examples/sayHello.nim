import yottadb
import std/strutils
import std/strformat

let msg = "Hallo von 'Nim', Grüezi [ˈɡ̊ryə̯t͡sɪ], Hola, cómo estás"
Set: ^hello("Nim") = msg
echo Get ^hello("Nim")

proc normalized(s: string): string =
    echo "A: ", s
    result = fasttrim(s).replace(' ','.')
    echo "B: ", result

# With ydb: scope
ydb:
  Kill ^hello

  ^hello("NimLang") = msg & " from ydb: scope"
  echo ^hello("NimLang")
  var s = ^hello("NimLang")
  echo "s.len=", s.len

  let len = len(^hello("NimLang"))
  echo "len=", len

  # 'len' call without argument works
  echo ^hello("NimLang").len

  # extract chars
  echo (^hello("NimLang"))[0..10]
  echo ^hello("NimLang")[0..10]
  echo ^hello("NimLang").toUpper()[0..10]
  echo ^hello("NimLang").substr(0,2)
  echo ^hello("NimLang").toUpper.substr(0,2)

  ^hello("int") = int.high
  echo ^hello("int")

  # calculated key
  ^hello(1+2+3) = 666
  echo "^hello(1+2+3)=", ^hello(6)
  echo "int=", ^hello(6).int
  
  ^hello("int8")=127
  echo "int8=", ^hello("int8").int8

  var f32: float32 = 3.1414
  var f64: float64 = 3.1414
  ^hello("float32") = f32
  ^hello("float64") = f64
  let x32 = ^hello("float32").float32
  let x64 = ^hello("float64").float64
  echo "x32=", x32, " x64=", x64
  assert f32 == x32
  assert f64 == x64

  ^hello("normalized") = "   &/.      this is the payload       "
  s = ^hello("normalized").normalized
  echo "normalized=", s

  echo "-------- RAW DB DATA ----------"
  for k,v in QueryItr ^hello.kv:
    echo k,"=",v
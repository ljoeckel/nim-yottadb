import yottadb
import std/strutils
import std/strformat

# sample to show proc xyz(s: string): string '.' postfix
proc normalized(s: string): string =
    result = fasttrim(s).replace(' ','.')

# With Set: / Get
let msg = "Hallo von 'Nim', Grüezi [ˈɡ̊ryə̯t͡sɪ], Hola, cómo estás"
Set: ^hello("Nim") = msg
echo "^hello('Nim')=", Get ^hello("Nim")


# Direct access to globals from inside 'ydb:' scope
ydb:
  Kill ^hello

  ^hello("NimLang") = msg
  echo "^hello('NimLang').len=", ^hello("NimLang").len

  # extract chars
  echo "^hello('NimLang')[0..10]=", ^hello("NimLang")[0..10]
  echo "^hello('NimLang').toUpper()[0..10]=", ^hello("NimLang").toUpper()[0..10]
  echo "^hello('NimLang').substr(0,4)=", ^hello("NimLang").substr(0,4)
  echo "^hello('NimLang').toUpper.substr(0,4)=", ^hello("NimLang").toUpper.substr(0,4)

  ^hello("int") = int.high
  echo "int.high=", ^hello("int")

  # calculated key
  ^hello(1+2+3) = 6
  echo "^hello(6)=", ^hello(6)
  
  ^hello("int8")=127
  echo "^hello('int8').int8=", ^hello("int8").int8

  var f32: float32 = 3.1414
  var f64: float64 = 3.1414
  ^hello("float32") = f32
  ^hello("float64") = f64
  assert f32 == ^hello("float32").float32
  assert f64 == ^hello("float64").float64

  ^hello("normalized") = "   &/.      this is the payload       "
  echo "^hello('normalized').normalized=", ^hello("normalized").normalized


import yottadb

let msg = "Hallo von 'Nim', Grüezi [ˈɡ̊ryə̯t͡sɪ], Hola, cómo estás"
Set: ^hello("Nim") = msg
echo Get ^hello("Nim")

# With ydb: scope
ydb:
  ^hello("NimLang") = msg & " from ydb: scope"
  echo ^hello("NimLang")
  let s = ^hello("NimLang")
  echo "s.len=", s.len

  let len = len(^hello("NimLang"))
  echo "len=", len

  # 'len' call without argument works
  echo ^hello("NimLang").len
import yottadb

let msg = "Hallo von 'Nim', Grüezi [ˈɡ̊ryə̯t͡sɪ], Hola, cómo estás"
setvar: ^hello("Nim") = msg
echo getvar ^hello("Nim")

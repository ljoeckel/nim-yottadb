import yottadb

let msg = "Hallo von 'Nim', Grüezi [ˈɡ̊ryə̯t͡sɪ], Hola, cómo estás"
Set: ^hello("Nim") = msg
echo Get ^hello("Nim")

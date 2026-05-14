import yottadb

type Person = object
    id: int
    name: string


var p = Person(id:1, name:"Lothar")

Set: ^Person(p.id) = p.name
echo "name1=", Get ^Person(p.id)

Set: ^Person(2) = "lothar2"
echo "name2=", Get ^Person(2)

let id = 3
Set: ^Person(id) = "lothar3"
echo "name3=", Get ^Person(id)



Object's may be serialized to the database using serialization code based on "bingo".
Currently the following types are supported:
... list of types ....
- string
- uint 8,16,32,64, int 8,16,32,64
- ranges
- float ....
- char
- bool
- enum
- seq of simple and complex types
- set's

Example:
```nim
type 
  Address* = object of RootObj
    street*: string
    zip*: uint
    city*: string
    state*: string

  CustomerSets = object of RootObj 
    setI: set[int8] # int8, int16
    setU: set[byte] # uint8, byte, uint16
    setC: set[char]
    setE: set[CustomerType]

  CustomerType = enum
    Good, Bad, Uggly, Stammkunde, Laufkundschaft, Firma, Sonstiges

  Customer* = object of RootObj
    id: int
    address: Address
    isGoodCustomer: bool
    charX: char = 'X'
    name: string
    first_name: string
    dob: int
    ct: CustomerType
    keywords: seq[string]
    int32F: int32
    float32F: float32
    setI: set[int8]
    setU: set[uint8]
    setRange: set[10.uint8..99.uint8]
    setEnum: set[CustomerType]
    hset: HashSet[string]
    custsets: CustomerSets

  Gender = enum
    male, female

  Relation = enum
    biological, step
    
  Responder = object of RootObj
    id: int
    isCustomer: bool = true
    custcode: char = 'x'
    fl64: float64 = 345.9393993
    name: string
    gender: Gender
    occupation: string
    age: int
    siblings: seq[Sibling]
    keywords: seq[string]

  Sibling = object of RootObj
    sex: Gender
    birthYear: int
    relation: Relation
    alive: bool
    keywords: seq[string]
    setI: set[int8]
    setU: set[uint8]
    setRange: set[10.uint8..99.uint8]
    setEnum: set[CustomerType]
```
Using the type is fairly simple:
```nim
proc newCustomer(id: int): Customer =
  result =
    Customer(id: id, int32F:456, float32F:3.456, isGoodCustomer: true, charX:'Y', 
    name:"Jöckel", first_name:"Lothar", dob:211258, ct:Uggly, keywords: @["Besteller", "Versender"],
    address: Address(street: "Bachstrasse 14", zip:6055, city:"Buchs", state:"AG"),
    setI:{1,9,4,127},
    setU:{11,99,245},
    setRange:{11, 99, 45},
    setEnum:{Laufkundschaft, Stammkunde},
    hset: toHashSet(["abc","xyz","asdf"]),
    custsets:CustomerSets(setI:{1,9,4,127}, setU:{11,99,245}, setC:{'z','t','e'}, setE:{Laufkundschaft, Stammkunde}),
    )

    
proc newResponder(id: int): Responder =
  result =
    Responder(id: id, name: "John Smith", gender: male, occupation: "student", age: 18, 
        siblings: @[
          Sibling(
            sex: female, birthYear: 1991, relation: biological, alive: true,
            setI:{1,9,4,127},
            setU:{11,99,245},
            setRange:{11, 99, 45},
            setEnum:{Good, Bad, Uggly, Stammkunde, Laufkundschaft, Firma, Sonstiges}
          ),
          Sibling(
            sex: male, birthYear: 1989, relation: step, alive: true, keywords: @["Stark", "Regen"],
            setI:{1,9,4,127},
            setU:{11,99,245},
            setRange:{11, 99, 45},
            setEnum:{Laufkundschaft, Stammkunde}
          )
        ],
        keywords: @["Achtung", "Gefahrt"],
        )

proc save[T](t: T) =
  store(@[$t.id], t) # proc store*[T: object](subs: seq[string]; o: T)

when isMainModule:
  for i in 1..1:
    save(newCustomer(i))
    save(newResponder(i))

  for i in 1..1:
    var customer: Customer
    load(@[$i], customer)
    echo "-- Customer --"
    echo "customer      id:", customer.id, " name:", customer.name, " first_name:", customer.first_name, " dob:", customer.dob, " ct:", $customer.ct, " isGoodCustomer:", customer.isGoodCustomer
    echo "address   street:", customer.address.street, " zip:", customer.address.zip, " city:", customer.address.city, " state:", customer.address.state
    echo "keywords        :", customer.keywords
    echo "    custset.setI:", $customer.custsets.setI
    echo "    custset.setU:", $customer.custsets.setU
    echo "setC            :", customer.custsets.setC
    echo "setE            :", $customer.custsets.setE
    echo "setI            :", customer.setI
    echo "setU            :", customer.setU
    echo "setEnum         :", customer.setEnum
    echo "setRange        :", customer.setRange
    echo "hset            :", customer.hset
    echo "int32F          :", customer.int32F
    echo "float32F        :", customer.float32F
    echo "charX           :", customer.charX

    var responder: Responder
    load(@[$i], responder)
    echo "--  Responder --" 
    echo "responder      id:", responder.id, " name:", responder.name
    for sibling in responder.siblings:
      echo "  sibling:", sibling
```
For each object type there will be one Global created.
```nim
List ^Customer
^Customer(1,"charX")="Y"
^Customer(1,"ct")=2
^Customer(1,"dob")=211258
^Customer(1,"first_name")="Lothar"
^Customer(1,"float32F")=3.456
^Customer(1,"hset",0)="abc"
^Customer(1,"hset",1)="xyz"
^Customer(1,"hset",2)="asdf"
^Customer(1,"id")=1
^Customer(1,"int32F")=456
^Customer(1,"isGoodCustomer")="true"
^Customer(1,"keywords",0)="Besteller"
^Customer(1,"keywords",1)="Versender"
^Customer(1,"name")="Jöckel"
^Customer(1,"setEnum",0)=3
^Customer(1,"setEnum",1)=4
^Customer(1,"setI",0)=1
^Customer(1,"setI",1)=4
^Customer(1,"setI",2)=9
^Customer(1,"setI",3)=127
^Customer(1,"setRange",0)=11
^Customer(1,"setRange",1)=45
^Customer(1,"setRange",2)=99
^Customer(1,"setU",0)=11
^Customer(1,"setU",1)=99
^Customer(1,"setU",2)=245
```
```nim
List ^Address
^Address(1,"city")="Buchs"
^Address(1,"state")="AG"
^Address(1,"street")="Bachstrasse 14"
^Address(1,"zip")=6033
```
```nim
List ^Responder
^Responder(1,"age")=18
^Responder(1,"custcode")="x"
^Responder(1,"fl64")=345.9393993
^Responder(1,"gender")=0
^Responder(1,"id")=1
^Responder(1,"isCustomer")="true"
^Responder(1,"keywords",0)="Achtung"
^Responder(1,"keywords",1)="Gefahrt"
^Responder(1,"name")="John Smith"
^Responder(1,"occupation")="student"
```
```nim
List ^CustomerSets
^CustomerSets(1,"setC",0)="e"
^CustomerSets(1,"setC",1)="t"
^CustomerSets(1,"setC",2)="z"
^CustomerSets(1,"setE",0)=3
^CustomerSets(1,"setE",1)=4
^CustomerSets(1,"setI",0)=1
^CustomerSets(1,"setI",1)=4
^CustomerSets(1,"setI",2)=9
^CustomerSets(1,"setI",3)=127
^CustomerSets(1,"setU",0)=11
^CustomerSets(1,"setU",1)=99
^CustomerSets(1,"setU",2)=245
```

```nim
List ^Sibling
^Sibling(1,0,"alive")="true"
^Sibling(1,0,"birthYear")=1991
^Sibling(1,0,"relation")=0
^Sibling(1,0,"setEnum",0)=0
^Sibling(1,0,"setEnum",1)=1
^Sibling(1,0,"setEnum",2)=2
^Sibling(1,0,"setEnum",3)=3
^Sibling(1,0,"setEnum",4)=4
^Sibling(1,0,"setEnum",5)=5
^Sibling(1,0,"setEnum",6)=6
^Sibling(1,0,"setI",0)=1
^Sibling(1,0,"setI",1)=4
^Sibling(1,0,"setI",2)=9
^Sibling(1,0,"setI",3)=127
^Sibling(1,0,"setRange",0)=11
^Sibling(1,0,"setRange",1)=45
^Sibling(1,0,"setRange",2)=99
^Sibling(1,0,"setU",0)=11
^Sibling(1,0,"setU",1)=99
^Sibling(1,0,"setU",2)=245
^Sibling(1,0,"sex")=1
^Sibling(1,1,"alive")="true"
^Sibling(1,1,"birthYear")=1989
^Sibling(1,1,"keywords",0)="Stark"
^Sibling(1,1,"keywords",1)="Regen"
^Sibling(1,1,"relation")=1
^Sibling(1,1,"setEnum",0)=3
^Sibling(1,1,"setEnum",1)=4
^Sibling(1,1,"setI",0)=1
^Sibling(1,1,"setI",1)=4
^Sibling(1,1,"setI",2)=9
^Sibling(1,1,"setI",3)=127
^Sibling(1,1,"setRange",0)=11
^Sibling(1,1,"setRange",1)=45
^Sibling(1,1,"setRange",2)=99
^Sibling(1,1,"setU",0)=11
^Sibling(1,1,"setU",1)=99
^Sibling(1,1,"setU",2)=245
^Sibling(1,1,"sex")=0
```
```nim

```
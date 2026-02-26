# Object Serialization
You can serialize a object tree to the database.
The code uses parts from the the [`bingo`](https://github.com/planetis-m/bingo) framework but is not dependent on.

Serialization allows to save each object class in a own global variable with the class attributes. Object's which contains other classes are then saved in a separate global with the same id as the main object. 

To save the object, simply pass the id and the object to the `saveObject` proc.
The id can be build using seq:[string].
```nim
saveObject(@[$id], obj)
````
To load the object back simply call the `loadObject` proc with the id.
```nim
var customer = loadObject[Customer](@[$id])
```
To delete a object call
```nim
deleteObject[Customer](@[$id])
```
### Supported Datatypes
Currently the following Data-types are supported:
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

## Indexing
Fields of a type can be indexed by adding the `.INDEX.` pragma where the parameter (g.E. 'id') references the id field.

The index(es) are automatically created, modified or deleted by the saveObject and deleteObject methods.

If a field changes then saveObject also handles the proper update to the index.

```nim
Registration = object of RootObj
        id: int = -1
        formId: string = "form"
        name: string
        password: string
        email {.INDEX: "id".} : string
        message: string
        country {.INDEX: "id".} : string
        plan: string = "starter"
        terms : bool
        status: string
        time: string
```
For each index a separate global is created. The field value and the primary key are part of the subscript.
```
List ^RegistrationEMAIL
^RegistrationEMAIL("lothar.joeckel@gmail.com",1)=""
^RegistrationEMAIL("lothar.joeckel@web.de",3)=""
^RegistrationEMAIL("lothar@web.de2",4)=""

List ^RegistrationCOUNTRY
^RegistrationCOUNTRY("Spain",1)=""
^RegistrationCOUNTRY("Switzerland",3)=""
^RegistrationCOUNTRY("Switzerland",4)=""
```     

### Example:
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
    hSet: HashSet[string]
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
    hSet: toHashSet(["abc","xyz","asdf"]),
    custsets:CustomerSets(setI:{1,9,4,127}, setU:{11,99,245}, setC:{'z','t','e'}, setE:{Laufkundschaft, Stammkunde}),
    )

    
var responder: Responder(id: id, name: "John Smith", gender: male, occupation: "student", age: 18, siblings: @[
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

 store(@[$id], responder)

var customer: Customer
load(@[$i], customer)
echo "customer id:", customer.id, " name:", customer.name

var responder: Responder
load(@[$i], responder)
echo "responder id:", responder.id, " name:", responder.name
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
...
```
```nim
List ^Address
^Address(1,"city")="Buchs"
^Address(1,"state")="AG"
...
```
```nim
List ^Responder
^Responder(1,"age")=18
^Responder(1,"custcode")="x"
^Responder(1,"fl64")=345.9393993
...
```
```nim
List ^CustomerSets
^CustomerSets(1,"setC",0)="e"
^CustomerSets(1,"setC",1)="t"
^CustomerSets(1,"setC",2)="z"
...
```

```nim
List ^Sibling
^Sibling(1,0,"alive")="true"
^Sibling(1,0,"birthYear")=1991
^Sibling(1,0,"relation")=0
^Sibling(1,0,"setEnum",0)=0
...
```


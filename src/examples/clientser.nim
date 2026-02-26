import std/sets
import yottadb

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


proc newCustomer(id: int): Customer =
  result =
    Customer(id: id, int32F:456, float32F:3.456, isGoodCustomer: true, charX:'Y', 
    name:"Jöckel", first_name:"Lothar", dob:211258, ct:Uggly, keywords: @["Besteller", "Versender"],
    address: Address(street: "Bachstrasse 14", zip:6033, city:"Buchs", state:"AG"),
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
  saveObject(@[$t.id], t)
  

when isMainModule:
  for i in 1..1:
    save(newCustomer(i))
    save(newResponder(i))

  for i in 1..1:
    let customer = loadObject[Customer](@[$i])
    echo "---------------------- Customer ----------------------"
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

    let responder = loadObject[Responder](@[$i])
    echo "---------------------- Responder ----------------------" 
    #echo "responder:", responder
    echo "responder      id:", responder.id, " name:", responder.name
    for sibling in responder.siblings:
      echo "  sibling:", sibling

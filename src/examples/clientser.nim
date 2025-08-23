import std/[strformat, strutils, streams, sets, times, os, osproc, unittest]
import macros
import ../yottadb
import ../libs/bingo

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
    id*: int
    address*: Address
    isGoodCustomer: bool
    charX: char = 'X'
    name*: string
    first_name*: string
    dob*: int
    ct: CustomerType
    keywords: seq[string]
    int32F: int32
    float32F: float32
    setI: set[int8]
    setU: set[uint8]
    setRange: set[10.uint8..99.uint8]
    setEnum: set[CustomerType]

type
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
    #hset: HashSet[string]
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


proc save[T](t: T) =
  store(@[$t.id], t)
  
proc load[T](t: T): T =
  store(@[$t.id], t)
  return t
  
proc newCustomer(id: int): Customer =
  result =
    Customer(id: id, int32F:456, float32F:3.456, isGoodCustomer: true, charX:'Y', 
    name:"Jöckel", first_name:"Lothar", dob:211258, ct:Uggly, keywords: @["Besteller", "Versender"],
    address: Address(street: "Gartenweg 4", zip:6233, city:"Büron", state:"LU"),
    setI:{1,9,4,127},
    setU:{11,99,245},
    setRange:{11, 99, 45},
    setEnum:{Laufkundschaft, Stammkunde}
    )

#hset: toHashSet(["a","b","c"]),
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
  
when isMainModule:
  for i in 1..1:
    save(newCustomer(i))
    save(newResponder(i))

    var customer: Customer
    load(@[$i], customer)
    var responder: Responder
    load(@[$i], responder)

    echo "customer after load:", customer
    echo "responder after load:", responder
    
    # echo "siblings:", responder.siblings
    # let sibling = Sibling(sex: male, birthYear: 1958, relation: step, alive: true, keywords: @["Lothar", "Joeckel"])
    # responder.siblings.add(sibling)
    # save(responder)
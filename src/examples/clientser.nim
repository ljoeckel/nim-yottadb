import std/[strformat, strutils, streams, times, os, osproc, unittest]
import macros
import ../yottadb
import ../bingo

type 
  CustomerType = enum
    Good, Bad, Uggly 

  Customer* = object of RootObj
    id*: int
    name*: string
    first_name*: string
    dob*: int
    ct: CustomerType

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
  Sibling = object of RootObj
     sex: Gender
     birthYear: int
     relation: Relation
     alive: bool
     keywords: seq[string]



proc save[T](t: T) =
  store(@[$t.id], t)
  
  
proc createCustomer(id: int) =
  let customer =
    Customer(id: id, name:"Jöckel", first_name:"Lothar", dob:211258, ct:Good)
  save(customer)

  let data =
    Responder(id: id, name: "John Smith", gender: male, occupation: "student", age: 18,
        siblings: @[Sibling(sex: female, birthYear: 1991, relation: biological, alive: true),
        Sibling(sex: male, birthYear: 1989, relation: step, alive: true, keywords: @["Stark", "Regen"])],
        keywords: @["Achtung", "Gefahrt"]
        )
  save(data)

  echo "Created ", id
  
when isMainModule:
  for i in 1..1:
    createCustomer(i)
import std/unittest
import std/strutils
import yottadb

type
  Address* = object of RootObj
    street*: string
    zip*: uint
    city*: string
    state*: string

  Customer* = object of RootObj
    id: int
    name: string
    first_name: string
    dob: int
    addresses: seq[Address]
    keywords: seq[string]


  Gender = enum
    male, female
  Relation = enum
    biological, step
  Responder = object
    id: int
    name: string
    gender: Gender
    occupation: string
    age: int
    siblings: seq[Sibling]
  Sibling = object
    sex: Gender
    birthYear: int
    relation: Relation
    alive: bool


proc createData(kb: int): string =
  # create a binary string
  var binval: string
  for i in 0 .. 255:
    binval.add(i.char)
  repeat(binval, kb*4)


proc newCustomer(id: int): Customer =
  result =
    Customer(id: id, name:"Jöckel", first_name:"Lothar", dob:211299, keywords: @["Besteller", "Versender"],
      addresses: @[
        Address(street: "Bachstrasse 14", zip:6033, city:"Buchs", state:"AG"),
        Address(street: "Gartenweg 5", zip:6233, city:"Büron", state:"LU")
      ],
    )


proc testCompositionSerialization() =
  let customer = newCustomer(4711)
  saveObject(@[$customer.id], customer)

  let customer2 = loadObject[Customer](@["4711"])
  assert customer2 == customer

  # Add new attribute in db to simulation class change
  Set: ^Customer("4711", "Employment") = "TheCompany"
  let customer3 = loadObject[Customer](@["4711"])
  # should work, but no "Employment" attribute because we have old type definition
  assert customer3 == customer

  # Remvoe attribute in db to simulation class change
  Killnode: ^Customer("4711", "name")
  let customer4 = loadObject[Customer](@["4711"])
  assert customer4.name == ""
  assert customer4.id == 4711


when isMainModule:
  suite "Object Serialization Tests":
    test "composition serialization": testCompositionSerialization()

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
  store(@[$customer.id], customer)

  var customer2: Customer
  load(@["4711"], customer2)
  assert customer2 == customer

  # Add new attribute in db to simulation class change
  Set: ^Customer("4711", "Employment") = "TheCompany"
  var customer3: Customer
  load(@["4711"], customer3)
  # should work, but no "Employment" attribute because we have old type definition
  assert customer3 == customer

  # Remvoe attribute in db to simulation class change
  Killnode: ^Customer("4711", "name")
  load(@["4711"], customer2)
  assert customer2.name == ""
  assert customer.id == 4711


proc testBinarySerialization() =
  Kill: ^Customer

  for i in 0..10:
    let data = Responder(id: i, name: "John Smith", gender: male, occupation: "student", age: 18,
             siblings: @[
              Sibling(sex: female, birthYear: 1991, relation: biological, alive: true),
              Sibling(sex: male, birthYear: 1989, relation: step, alive: true)
              ]
            )
    
    serializeToDb(data, $i)
    let responder = deserializeFromDb[Responder]($i)
    assert responder == data

    var subs: Subscripts = @["RSP2", "GRP1", $i]
    serializeToDb(data, subs)
    let responder2 = deserializeFromDb[Responder](subs)
    assert responder2 == data


when isMainModule:
  suite "Object Serialization Tests":
    test "composition serialization": testCompositionSerialization()
    test "binary serialization": testBinarySerialization()

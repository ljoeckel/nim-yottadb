import std/unittest
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


proc testCompositionSerialization() =
  let customer = newCustomer(4711)
  store(@[$customer.id], customer)

  var customer2: Customer
  load(@["4711"], customer2)
  assert customer2 == customer

  # Add new attribute in db to simulation class change
  set: ^Customer("4711", "Employment") = "TheCompany"
  var customer3: Customer
  load(@["4711"], customer3)
  # should work, but no "Employment" attribute because we have old type definition
  assert customer3 == customer

  # Remvoe attribute in db to simulation class change
  delnode: ^Customer("4711", "name")
  doAssertRaises(YdbError): load(@["4711"], customer2)


proc testBinarySerialization() =
  for i in 0..10:
    let data = Responder(id: i, name: "John Smith", gender: male, occupation: "student", age: 18,
             siblings: @[Sibling(sex: female, birthYear: 1991, relation: biological, alive: true),
             Sibling(sex: male, birthYear: 1989, relation: step, alive: true)])
    
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


# id: 4711,
#  address: (street: "Bachstrasse 14", zip: 6033, city: "Buchs", state: "AG"),
#   isGoodCustomer: true, charX: 'Y', name: "Jöckel", first_name: "Lothar", dob: 211258, ct: Uggly, keywords: @["Besteller", "Versender"],
#   int32F: 456, float32F: 3.456, setI: {1, 4, 9, 127}, setU: {11, 99, 245}, setRange: {11, 45, 99}, setEnum: {Stammkunde, Laufkundschaft}, hset: {"abc", "xyz", "asdf"}, custsets: (setI: {1, 4, 9, 127}, setU: {11, 99, 245}, setC: {'e', 't', 'z'}, setE: {Stammkunde, Laufkundschaft}))
# id: 4711,
#  address: (street: "Bachstrasse 14", zip: 6033, city: "Buchs", state: "AG"),
#   isGoodCustomer: true, charX: 'Y', name: "Jöckel", first_name: "Lothar", dob: 211258, ct: Uggly, keywords: @["Besteller", "Versender", "Besteller", "Versender"],
#   int32F: 456, float32F: 3.456, setI: {1, 4, 9, 127}, setU: {11, 99, 245}, setRange: {11, 45, 99}, setEnum: {Stammkunde, Laufkundschaft}, hset: {"asdf", "xyz", "abc"}, custsets: (setI: {1, 4, 9, 127}, setU: {11, 99, 245}, setC: {'e', 't', 'z'}, setE: {Stammkunde, Laufkundschaft}))
# /
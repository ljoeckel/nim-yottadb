import std/strformat
import yottadb

proc setup() =
  kill: ^CUSTOMER

  setvar:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

    ^customer(1, "profile", "Name")="John Doe"
    ^customer(1, "profile", "Email")="john-doe.@gmail.com"
    ^customer(1, "address", "street")="Bachstrasse 12"
    ^customer(1, "address", "zip")=6123
    ^customer(1, "address", "city")="Aarau"

    ^customer(2, "profile", "Name")="Jane Smith"
    ^customer(2, "profile", "Email")="jane.smith.@yahoo.com"
    ^customer(2, "address", "street")="Gartenweg 1"
    ^customer(2, "address", "zip")=5600
    ^customer(2, "address", "city")="Luzern"

  let profile3 = "^customer(3, profile)"
  let address3 = "^customer(3, address)"
  setvar:
      @profile3("name") = "Lothar Joeckel"
      @profile3("dob") = 140762
      @profile3("email") = "lothar.joeckel@gmail.com"
      @address3("street") = "C/ dels Xops"
      @address3("number") = "15"
      @address3("city") = "Pedreguer"
      @address3("zip") = "65443"

proc showOrder() =
  block:
    echo "\nIterate with order CUSTOMER"
    var id = order: ^CUSTOMER
    while id.len > 0:
      let name = getvar  ^CUSTOMER(id, "Name")
      let email = getvar  ^CUSTOMER(id, "Email")
      echo fmt"Customer {id}: {name} <{email}>"
      id = order: ^CUSTOMER(id) # Read next

  block:
    echo "\nIterate with order CUSTOMER.keys"
    var subs = order: ^CUSTOMER.keys
    while subs.len > 0:
      let name = getvar  ^CUSTOMER(subs, "Name")
      let email = getvar  ^CUSTOMER(subs, "Email")
      echo fmt"Customer {subs[0]}: {name} <{email}>"
      subs = order: ^CUSTOMER(subs).keys # Read next


  block:
    echo "\nIterate over all CUSTOMER Indirection"
    var gbl = order ^CUSTOMER.key
    while gbl.len > 0:
      let name = getvar  @gbl("Name")
      let email = getvar @gbl("Email")
      echo fmt"{gbl}: name: {name}, email:{email}"
      gbl = order @gbl.key

proc showCustomer() =
  for id in orderItr ^customer:
    echo id
    for group in orderItr ^customer(id,""):
      echo "  ", group
      for attribute in orderItr ^customer(id, group, ""):
        echo "    ", attribute
  echo "--"
  echo "with @"
  for id in orderItr ^customer:
    echo id
    for group in orderItr ^customer(id,""):
      echo "  ", group
      for attribute in orderItr ^customer(id, group, "").key:
        echo "    ", attribute, "=", getvar @attribute


  # block:
  #   echo "\nIterate with order customer.keys"
  #   var subs = order: ^customer.keys
  #   while subs.len > 0:
  #     let name = getvar  ^customer(subs, "Name")
  #     let email = getvar  ^customer(subs, "Email")
  #     echo fmt"customer {subs[0]}: {name} <{email}>"
  #     subs = order: ^customer(subs).keys # Read next


  # block:
  #   echo "\nIterate over all customer Indirection"
  #   var gbl = order ^customer.key
  #   while gbl.len > 0:
  #     let name = getvar  @gbl("Name")
  #     let email = getvar @gbl("Email")
  #     echo fmt"{gbl}: name: {name}, email:{email}"
  #     gbl = order @gbl.key

  # # -------------------
  # # orderItr
  # # -------------------
  #   echo "\nIterate over all customer with orderItr"
  #   for key in orderItr ^customer:
  #     echo "key=", key

  #   echo "\nIterate over all customer with orderItr.key"
  #   for id in orderItr ^customer.key:
  #     echo fmt"id={id}, name={getvar @id(""Name"")}, email={getvar @id(""Email"")}"

  #   echo "\nIterate over all customer with orderItr.keys"
  #   for subs in orderItr ^customer.keys:
  #     var keys = subs
  #     keys.add("Name")
  #     echo "subscripts=", keys, " Name=", getvar ^customer(keys)

proc showQuery() =
  # --------------
  # queryItr
  # --------------
    echo "\nIterate over all nodes with queryItr"
    for key in queryItr ^CUSTOMER:
      let value = getvar @key
      echo key,"=",value

    echo "\nIterate over all nodes with queryItr.kv"
    for key, value in queryItr ^CUSTOMER.kv:
      echo fmt"Node {key} = {value}"

    echo "\nIterate over all nodes with queryItr.val"
    for value in queryItr ^CUSTOMER.val:
      echo value

    echo "\nIterate over all nodes with queryItr.keys"
    for value in queryItr ^CUSTOMER.keys:
      echo value


when isMainModule:
  setup()
  showOrder()
  showQuery()
  showCustomer()

import std/strformat
import yottadb

proc setup() =
  Kill: ^CUSTOMER

  Set:
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
  Set:
      @profile3("name") = "Lothar Joeckel"
      @profile3("dob") = 140762
      @profile3("email") = "lothar.joeckel@gmail.com"
      @address3("street") = "C/ dels Xops"
      @address3("number") = "15"
      @address3("city") = "Pedreguer"
      @address3("zip") = "65443"

proc showOrder() =
  block:
    echo "\nIterate with Order CUSTOMER"
    var id = Order: ^CUSTOMER("")
    while id.len > 0:
      let name = Get ^CUSTOMER(id, "Name")
      let email = Get ^CUSTOMER(id, "Email")
      echo fmt"Customer {id}: {name} <{email}>"
      id = Order: ^CUSTOMER(id) # Read next

  block:
    echo "\nIterate with Order CUSTOMER.keys"
    var subs = Order: ^CUSTOMER("").keys
    while subs.len > 0:
      let name = Get ^CUSTOMER(subs, "Name")
      let email = Get ^CUSTOMER(subs, "Email")
      echo fmt"Customer {subs[0]}: {name} <{email}>"
      subs = Order: ^CUSTOMER(subs).keys # Read next


  block:
    echo "\nIterate over all CUSTOMER Indirection"
    var gbl = Order ^CUSTOMER("").key
    while gbl.len > 0:
      let name = Get @gbl("Name")
      let email = Get @gbl("Email")
      echo fmt"{gbl}: name: {name}, email:{email}"
      gbl = Order @gbl.key

proc showCustomer() =
  for id in OrderItr ^customer(""):
    echo id
    for group in OrderItr ^customer(id,""):
      echo "  ", group
      for attribute in OrderItr ^customer(id, group, ""):
        echo "    ", attribute
  echo "--"
  echo "with @"
  for id in OrderItr ^customer:
    echo id
    for group in OrderItr ^customer(id,""):
      echo "  ", group
      for attribute in OrderItr ^customer(id, group, "").key:
        echo "    ", attribute, "=", Get @attribute


proc showQuery() =
  # --------------
  # QueryItr
  # --------------
    echo "\nIterate over all nodes with QueryItr"
    for key in QueryItr ^CUSTOMER:
      let value = Get @key
      echo key,"=",value

    echo "\nIterate over all nodes with QueryItr.kv"
    for key, value in QueryItr ^CUSTOMER.kv:
      echo fmt"Node {key} = {value}"

    echo "\nIterate over all nodes with QueryItr.val"
    for value in QueryItr ^CUSTOMER.val:
      echo value

    echo "\nIterate over all nodes with QueryItr.keys"
    for value in QueryItr ^CUSTOMER.keys:
      echo value


when isMainModule:
  setup()
  showOrder()
  showQuery()
  showCustomer()

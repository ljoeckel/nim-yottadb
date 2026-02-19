import std/strformat
import yottadb

proc main() =
  Set:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  echo "Iterate over all customer id's"
  for id in OrderItr ^CUSTOMER(""):
    let name = Get ^CUSTOMER(id, "Name")
    let email = Get ^CUSTOMER(id, "Email")
    echo fmt"Customer {id}: {name} <{email}>"

  echo "Iterate over all nodes"
  for node in QueryItr ^CUSTOMER(""):
    let value = Get @node
    echo fmt"{node}={value}"

when isMainModule:
  main()
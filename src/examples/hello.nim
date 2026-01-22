import std/strformat
import yottadb

proc main() =
  setvar:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  echo "Iterate over all customer id's"
  for id in orderItr ^CUSTOMER(""):
    let name = getvar  ^CUSTOMER(id, "Name")
    let email = getvar  ^CUSTOMER(id, "Email")
    echo fmt"Customer {id}: {name} <{email}>"

  echo "Iterate over all nodes"
  for node in queryItr ^CUSTOMER(""):
    let value = getvar @node
    echo fmt"{node}={value}"

when isMainModule:
  main()
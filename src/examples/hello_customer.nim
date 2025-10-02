import std/strformat
import yottadb

proc main() =
  set:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  echo "Iterate over all customers"
  var (rc, subs) = nextsubscript: ^CUSTOMER()
  while rc == YDB_OK:
    let name = get: ^CUSTOMER(subs, "Name")
    let email = get: ^CUSTOMER(subs, "Email")
    echo fmt"Customer {subs[0]}: {name} <{email}>"
    (rc, subs) = nextsubscript: ^CUSTOMER(subs) # Read next

  echo "Iterate over all nodes"
  (rc, subs) = nextnode: ^CUSTOMER()
  while rc == YDB_OK:
    let value = get: ^CUSTOMER(subs)
    echo fmt"Node {subs} = {value}"
    (rc, subs) = nextnode: ^CUSTOMER(subs) # Read next

when isMainModule:
  main()
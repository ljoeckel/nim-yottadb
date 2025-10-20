import std/strformat
import yottadb

proc main() =
  setvar:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  echo "Iterate over all customers"
  var (rc, subs) = nextsubscript: ^CUSTOMER.seq
  while rc == YDB_OK:
    let name = getvar  ^CUSTOMER(subs, "Name")
    let email = getvar  ^CUSTOMER(subs, "Email")
    echo fmt"Customer {subs[0]}: {name} <{email}>"
    (rc, subs) = nextsubscript: ^CUSTOMER(subs).seq # Read next

  echo "Iterate over all nodes"
  (rc, subs) = nextnode: ^CUSTOMER.seq
  while rc == YDB_OK:
    let value = getvar  ^CUSTOMER(subs)
    echo fmt"Node {subs} = {value}"
    (rc, subs) = nextnode: ^CUSTOMER(subs).seq # Read next

when isMainModule:
  main()
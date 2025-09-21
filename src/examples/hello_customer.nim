import std/strformat
import yottadb

proc main() =
  set:
    ^CUSTOMER(1, "Name")="John Doe"
    ^CUSTOMER(1, "Email")="john-doe.@gmail.com"
    ^CUSTOMER(2, "Name")="Jane Smith"
    ^CUSTOMER(2, "Email")="jane.smith.@yahoo.com"

  var
    subs:Subscripts
    rc = YDB_OK

  echo "Iterate over all customers"
  (rc, subs) = nextsubscript: ^CUSTOMER(subs)
  while rc == YDB_OK:
    let id = subs[0]
    let name = get: ^CUSTOMER(id, "Name")
    let email = get: ^CUSTOMER(id, "Email")
    echo fmt"Customer {id}: {name} <{email}>"
    # Read next
    (rc, subs) = nextsubscript: ^CUSTOMER(subs)

  echo "Iterate over all nodes and use subscripts()"
  subs = @[]
  rc = YDB_OK
  while rc == YDB_OK:
    (rc, subs) = nextnode: ^CUSTOMER(subs)
    if rc == YDB_OK:
      let value = get: ^CUSTOMER(subs)
      echo fmt"Node {subs} = {value}"

when isMainModule:
  main()
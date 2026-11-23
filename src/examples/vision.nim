import yottadb
import std/strformat

Kill ^Customer


type
    Customer = object
        id: int
        name: string

# Inside a `ydb:` block `^Global(subscripts)` is a value on its own:
# reads become `Get ^Global(..)`, `^Global(..) = value` becomes `Set: ...`.

ydb:
  ^Customer(4711, "name") = "Lothar"
  ^Customer(4711, "count") = "1"
  let v = ^Customer(4711, "name") & "," & ^Customer(4711, "count")
  echo "v=", v
  assert v == "Lothar,1"

  # postfixes and the other DSL macros keep working unchanged
  let count = ^Customer(4711, "count").int
  assert count == 1
echo "count=", count


# Indirection: `@var` works like `^Global(..)`, the key is built at runtime
ydb:
  var cust = "^Customer(4788, name)" # set key
  @cust = "Arno Miller" # save on DB
  assert "Arno Miller" == @cust # get from DB
  
  cust = "^Customer(4788, adress)" # set key
  @cust = "CH-44053 New Buchs LU" # save on DB
  assert "CH-44053 New Buchs LU" == @cust # get from DB


proc setCustomerName(id: int, name: string) =
    ydb:
        let cust = &"^Customer({id}, name)"
        @cust = name

proc setCustomerNameTx(customer:  Customer) =
    # The callback is `cdecl` and cannot capture locals, so `Transaction(customer)`
    # passes the object by address and the body reads it back via `param`.
    let rc = Transaction(customer):
        let cust = cast[ptr Customer](param)[]
        let gbl = &"^Customer({cust.id}, name)"
        Set: @gbl = cust.name

proc setCustomerNameTx2(customer:  Customer) =
    let rc = Transaction(customer):
        let cust = cast[ptr Customer](param)[]
        let gbl = &"^Customer({cust.id}, name)"
        ydb:
            @gbl = cust.name

proc getCustomerName(id: int): string =
    ydb:
        let cust = &"^Customer({id}, name)"
        result = @cust


setCustomerName(4712, "Martina Jöckel")

let sebi = Customer(id: 4716, name: "Sebastian Hoffmann")
setCustomerNameTx(sebi)

let jd = Customer(id: 4715, name: "Jonny Depp")
setCustomerNameTx2(jd)

let custName = getCustomerName(4712)
echo "name(4712)=", custName

for key, value in QueryItr ^Customer.kv:
    echo key, "=", value
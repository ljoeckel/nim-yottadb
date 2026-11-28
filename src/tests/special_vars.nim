import std/[unittest, strutils]
import yottadb

proc testSpecialVars() =
  # Get
  let zversion = Get $ZVERSION
  assert zversion.len > 0 and zversion.startsWith("GT.M")

  # Set
  Set: $ZMAXTPTIME()="2"
  let zmaxtptime = Get $ZMAXTPTIME
  assert zmaxtptime == "2"

proc testSpecialVarsIndirekt() =
    assert (Get $ZVERSION).startsWith("GT.M")
    assert Get $ZVERSION.startsWith("GT.M")
    let specialname = "$ZVERSION"
    assert (Get @specialname).startsWith("GT.M")
    assert Get @specialname.startsWith("GT.M")


proc testPostfixAndOps() =
  # postfixes (type conversions) also work on special variables
  Set: $ZMAXTPTIME() = "2"
  assert (Get $ZMAXTPTIME.int) == 2
  assert 2 == Get $ZMAXTPTIME.int
  assert Get $ZMAXTPTIME.int == 2
  assert (Get $ZMAXTPTIME.float) == 2.0
  assert Get $ZMAXTPTIME.float / 2.0 == 1.0

  assert (Get $ZVERSION).len > 0            # plain read still works
  assert (Get $ZVERSION[0..1]) == "GT"      # slicing a special variable
  assert Get $ZVERSION.len > 0              # Get binds to the leftmost operand
  assert Get $ZVERSION[0..1] == "GT"      # slicing a special variable
  assert Get $ZMAXTPTIME.int + 1 == 3       # ... also for arithmetic

  # ... and on normal YottaDB variables (no '^' prefix)
  Set: lv = "42"
  assert (Get lv.int) == 42
  assert Get lv.int == 42
  assert (Get lv.float) == 42.0
  assert Get lv.float == 42.0
  assert (Get lv[0..0]) == "4"
  assert Get lv[0..0] == "4"
  Set: lvsub(1) = "7"
  assert (Get lvsub(1).int) == 7
  assert Get lvsub(1).int == 7


test "specialVars": testSpecialVars()
test "specialVarsIndirekt": testSpecialVarsIndirekt()
test "postfixAndOps": testPostfixAndOps()
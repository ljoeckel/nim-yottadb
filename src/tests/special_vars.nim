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
    let specialname = "$ZVERSION"
    assert (Get @specialname).startsWith("GT.M")


test "specialVars": testSpecialVars()
test "specialVarsIndirekt": testSpecialVarsIndirekt()
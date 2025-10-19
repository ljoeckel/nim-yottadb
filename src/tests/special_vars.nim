import std/[unittest, strutils]
import yottadb

proc testSpecialVars() =
  # Get
  let zversion = get $ZVERSION
  assert zversion.len > 0 and zversion.startsWith("GT.M")

  # Set
  setvar: $ZMAXTPTIME()="2"
  let zmaxtptime = get $ZMAXTPTIME
  assert zmaxtptime == "2"

proc testSpecialVarsIndirekt() =
    assert (get $ZVERSION).startsWith("GT.M")
    let specialname = "$ZVERSION"
    assert (get @specialname).startsWith("GT.M")


test "specialVars": testSpecialVars()
test "specialVarsIndirekt": testSpecialVarsIndirekt()
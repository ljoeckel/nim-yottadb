import std/[unittest, strutils]
import yottadb

proc testSpecialVars() =
  # Get
  let zversion = getvar $ZVERSION
  assert zversion.len > 0 and zversion.startsWith("GT.M")

  # Set
  setvar: $ZMAXTPTIME()="2"
  let zmaxtptime = getvar $ZMAXTPTIME
  assert zmaxtptime == "2"

proc testSpecialVarsIndirekt() =
    assert (getvar $ZVERSION).startsWith("GT.M")
    let specialname = "$ZVERSION"
    assert (getvar @specialname).startsWith("GT.M")


test "specialVars": testSpecialVars()
test "specialVarsIndirekt": testSpecialVarsIndirekt()
import std/[unittest]
import yottadb

proc basic() =
    let gbl = "^global"
    Kill @gbl

    Set: @gbl(1) = 1
    assert 1 == Get @gbl(1).int

    Set: @gbl(1, "name") = "Lothar"
    assert "Lothar" == Get @gbl(1, "name")

    var subs = @["ort","plz"]
    Set: @gbl(1, subs) = 65535
    assert 65535 == Get @gbl(1, subs).Int

    subs = @["ort","name"]
    Set: @gbl(1, subs) = "Idstein"
    assert "Idstein" == Get @gbl(1, subs)

    subs = @["4711", "0815"]
    Set: @gbl(subs, "name") = "Null Acht Fünfzehn"
    assert "Null Acht Fünfzehn" == Get @gbl(subs, "name")

    var subs2 = @[12345, 1]
    Set: @gbl(subs, "Konto", subs2) = "Kontonummer 1 Sub 1"
    assert "Kontonummer 1 Sub 1" == Get @gbl(subs, "Konto", subs2)

    subs2 = @[12345, 2]
    Set: @gbl(subs, "Konto", subs2) = "Kontonummer 1 Sub 2"
    assert "Kontonummer 1 Sub 2" == Get @gbl(subs, "Konto", subs2)


if isMainModule:
  test "Basic": basic()
import yottadb

proc testLocals() =
  set: gbl(1) = 1
  echo get(gbl(1))
  set: ^tmp(100)=100
  let id = "1"
  let val = get: gbl(id).int

  # set: gbl(2, 2)="2.2"
  # var valI = get(gbl(2, 2))
  # echo "valI:", valI

  # set: gbl(10 + 1) = 11
  # echo get(gbl(10 + 1))

  # let id = 100
  # set: gbl(id) = 100
  # echo get(gbl(id))
  # set: gbl(id + 10) = 110
  # echo get(gbl(id + 10))

  # set: ^gbl(id) = 100
  # echo get(^gbl(id))
  # set: ^gbl(id + 10) = 110
  # echo get(^gbl(id + 10))

testLocals()

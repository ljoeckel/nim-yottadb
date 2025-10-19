import std/[times, os, unittest, strutils]
import yottadb

proc test_ydb_ci() =
  let ydb_ci = getEnv("ydb_ci")
  if ydb_ci.isEmptyOrWhitespace:
    echo "Could not find environment variable 'ydb_ci' to set the callin table. *** Test ignored ***"
    return
  if not fileExists(ydb_ci):
    echo "Could not find callin file ", ydb_ci, " *** Test ignored ***"
    return

  let tm = getTime()
  setvar: VAR1 = tm # pass this callm.m
  ydb_ci: "method1"
  assert $tm == get RESULT # Read the YottaDB variable from the Callin

  ydb_ci: "method2"
  assert "TheResultFrom YDB" == get RESULT
  
if isMainModule:
  test "ydb_ci": test_ydb_ci()
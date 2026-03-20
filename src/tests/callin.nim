import std/[times, os, unittest, strformat, json]
import yottadb

#[ File: $ydb_dir/$ydb_version/r/callm.ci
method1  : void method1^callm()
method2  : void method2^callm()
method3  : void method3^callm()
]#

#[ File: $ydb_dir/$ydb_version/r/callm.m
callm   ;
        quit

method1 ; Echo back CTX set by Nim program
        ; Use this form if 'Nim macro CallM' is used
        set key="CTX"
        set i=0
        set RESULT="Traverse RESULT with QueryItr"
        for  set key=$query(@key) quit:key=""  do
        . set value=$get(@key)
        . set RESULT(i)=value
        . set i=i+1
        quit

method2 ; echo back some text with CTX (single argument)
        set RESULT="TheResultFrom YDB CTX="_CTX
        quit

method3 ; echo back some text with CTX (multiple arguments)
        set RESULT="From callin: CTX(1..4)="_CTX(1)_","_CTX(2)_","_CTX(3)_","_CTX(4)
        quit
]#


proc haveEnvironment(): bool =
  let ciEnv = getEnv("ydb_ci")
  if ciEnv.len == 0:
    echo "Could not find environment variable 'ydb_ci' to set the callin table. *** Test ignored ***"
    return false

  if not fileExists(ciEnv):
    echo "Could not find callin file ", ciEnv, " *** Test ignored ***"
    return false

  return true


proc test_ydb_ci() =
  let tm = getTime()
  Set: CTX = $tm # pass CTX to callm.m
  ydb_ci: "method2"
  assert "TheResultFrom YDB CTX=" & $tm == Get RESULT


proc test_ydb_callm() =
  let result = CallM: method2("Hello World")
  assert result == "TheResultFrom YDB CTX=Hello World"


proc test_ydb_callm_multiargs() =
  let result = CallM: method3("Hello World", 123, 456.99, true)
  assert "From callin: CTX(1..4)=Hello World,123,456.99,true" == result


proc test_ydb_callm_json() =
  let data = parseJson("""{
      "total": {
          "RegT Margin": "896,255 USD",
          "current_initial": "468,562 USD",
      },
      "Crypto at Paxos": {
          "current_initial": "0 USD",
          "Prdctd Pst-xpry Mrgn @ Opn": "0 USD",
      },
      "commodities": {
          "current_initial": "13,794 USD",
          "Prdctd Pst-xpry Mrgn @ Opn": "0 USD",
      },
      "securities": {
          "RegT Margin": "896,255 USD",
          "current_initial": "454,768 USD",
          "Prjctd Ovrnght Mntnnc Mrgn": 454768,
          "Valid": true,
          "SomeFloatValue": 123.322
      }
    }""")

  # CTX("CryptoatPaxos","PrdctdPst-xpryMrgnOpn")="0 USD"
  # CTX("CryptoatPaxos","current_initial")="0 USD"
  # CTX("commodities","PrdctdPst-xpryMrgnOpn")="0 USD"
  # CTX("commodities","current_initial")="13,794 USD"
  # CTX("securities","PrjctdOvrnghtMntnncMrgn")=454768
  # CTX("securities","RegTMargin")="896,255 USD"
  # CTX("securities","SomeFloatValue")=123.322
  # CTX("securities","Valid")="true"
  # CTX("securities","current_initial")="454,768 USD"
  # CTX("total","RegTMargin")="896,255 USD"
  # CTX("total","current_initial")="468,562 USD"

  # The CallM macro will transform the JSON into the CTX local variable
  let result = CallM: method1(data)
  assert result == "Traverse RESULT with QueryItr"

  # Traverse through the RESULT local var
  var cnt = 0
  for key in QueryItr RESULT:
      let value = Get @key
      assert key == fmt"RESULT({cnt})"
      assert value.len > 0
      inc cnt


if isMainModule and haveEnvironment():
  test "ydb_ci_api": test_ydb_ci()
  test "ydb_ci_callm": test_ydb_callm()
  test "ydb_ci_callm_multiargs": test_ydb_callm_multiargs()
  test "ydb_ci_callm_json": test_ydb_callm_json()
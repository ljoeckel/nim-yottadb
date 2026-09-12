## Maps YottaDB numeric status codes to their `YDB_ERR_*` identifier names.
##
## Every status code returned by the YottaDB C API has a symbolic name, e.g.
## `-150372602` is `YDB_ERR_NOTGBL`. Instead of maintaining that list twice,
## `getYdbError` is generated at compile time from YottaDB's own
## `futhark/libydberrors.h` header, so it stays in sync with the bundled
## bindings automatically.

import std/[macros, os, strutils]

const ydbErrorHeader =
  currentSourcePath().parentDir.parentDir.parentDir / "futhark" / "libydberrors.h"

macro buildYdbErrorLookup(header: static string): untyped =
  ## Parses all `#define YDB_ERR_<NAME> <code>` lines and expands to `getYdbError`.
  ## and creates
  ## func getYdbError*(code: int): string =
  ##   case code
  ##   of -150372361: "YDB_ERR_ACK"
  ##   of -150372371: "YDB_ERR_BREAKZST"
  ##   # ... ~1619 more ...
  ##   of -150372602: "YDB_ERR_NOTGBL"
  ##   else: ""

  var lines = @[
    "func getYdbError*(code: int): string =",
    "  ## Returns the `YDB_ERR_*` identifier name for a YottaDB status code.",
    "  ## Example: `getYdbError(-150372602)` returns `\"YDB_ERR_NOTGBL\"`.",
    "  ## Unknown codes yield an empty string.",
    "  case code",
  ]
  var entries = 0
  for rawLine in readFile(header).splitLines():
    let line = rawLine.strip()
    if not line.startsWith("#define YDB_ERR_"):
      continue
    let fields = line.splitWhitespace()
    if fields.len < 3:
      continue
    var value: int
    try:
      value = parseInt(fields[2])
    except ValueError:
      continue # not a plain integer, e.g. an expression we cannot resolve
    lines.add("  of " & $value & ": \"" & fields[1] & "\"")
    inc entries
  if entries == 0:
    error("no YDB_ERR_* definitions found in " & header)
  lines.add("  else: \"\"")
  result = parseStmt(lines.join("\n"))

buildYdbErrorLookup(ydbErrorHeader)


if isMainModule:
    echo getYdbError(-150372602)
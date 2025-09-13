import std/[os, strutils, strformat, sequtils, algorithm]

switch("nimcache", ".nimcache")

task test, "Run full test suite":
  for kind, path in walkDir("tests"):
    if kind == pcFile and path.endsWith(".nim") and not path.endsWith("config.nims"):
      let name = splitFile(path).name
      if not name.startsWith("t"): continue # run only t*.nim files
      echo fmt"[sigils] Running {path}"
      exec fmt"nim c -r {path}"

task docs, "Generate API docs to docs/api":
  let outDir = "docs/api"
  exec "mkdir -p " & outDir
  let listing2 = staticExec("find src -type f -name '*.nim' -print 2>/dev/null || true")
  var files = listing2.splitLines().filterIt(it.len > 0)
  files.sort()
  if files.len == 0:
    echo "No Nim sources found under src/."
  for f in files:
    if f.contains("tx.nim"):
      echo "Ignored ", f 
      continue
    echo "[docs] Generating for ", f
    exec "nim doc --outdir:" & outDir & " " & f
    
# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
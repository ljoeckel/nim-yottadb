import std/[strutils, os, osproc, posix, streams, strformat, times]
import yottadb

# -----------------------
# Yotta related functions 
# -----------------------

# withlock:
template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database lock named ^LOCKS(lockid) while executing the body
    lock: {+^LOCKS(lockid)}
    body
    lock: {-^LOCKS(lockid)}

proc getYdbKeys(name: string): seq[string] =
  var (rc, gbl) = nextnode @name
  if data(@name) in {YDB_DATA_VALUE_DESC, YDB_DATA_VALUE_NODESC}: # node has data and/or descendents
     result.add(name)
  while rc == YDB_OK:
    result.add(gbl)
    (rc, gbl) = nextnode @gbl

proc listVar*(name: string) =
  # List all globals with its value
  for varname in getYdbKeys(name):
    echo fmt"{varname}={get @varname}"


proc getGlobals*(): seq[string] =
  # Get the global variables from the ydb ^%GD utility
    result = @[]
    var lines: seq[string]

    # Start a process with stdin/stdout redirection
    let ydb = findExe("ydb")
    let p = startProcess(
        ydb,
        args = @["-run ^%GD"],
        options = {poUsePath, poStdErrToStdOut, poInteractive}
    )

    p.inputStream.write("\n") # Send "Enter" (newline) to the process
    p.inputStream.flush()

    var line = ""
    while p.outputStream.readLine(line):
        if line.startsWith("^"):
            lines.add(line)
    for line in lines:
        let names = line.split('^')
        for name in names:
            let s = name.strip()
            if not s.isEmptyOrWhitespace:
                result.add("^" & s)

    discard waitForExit(p)  # Wait until process finishes


proc getLocksFromYottaDb*(all: bool = false): seq[string] =
  # Show real locks on db with 'lke show'
  let pid = ydb_get("$JOB")
  result = @[]

  let lke = findExe("lke")
  let lines = execProcess(lke & " show")
  for line in lines.split('\n'):
    if all and line.contains("Owned by"):
      result.add(line)    
    elif line.contains("Owned by") and line.contains(pid):
      result.add(line)    

proc getLockCountFromYottaDb*(all: bool = false): int =
  getLocksFromYottaDb(all).len


proc isLocked*(lock: string): bool =
  for line in getLocksFromYottaDb():
    if line.contains("^LOCKS(") and line.contains(lock):
      return true
  false


proc isLocked*(lock: int | float): bool =
  isLocked($lock)


# -----------------------
# Generic functions 
# -----------------------

# timed: templates
template timed_execute(body: untyped): auto =
  let t1 = getTime()
  body
  let durationMs = (getTime() - t1).inMilliseconds
  durationMs

template timed*(body: untyped) =
  let durationMs = timed_execute: body
  echo "Duration: ", durationMs," ms."

template timed*(info: string, body: untyped) =
  let durationMs = timed_execute: body
  echo $info & ": ", durationMs," ms."

template timed_ms*(body: untyped): auto =
  let durationMs = timed_execute: body
  durationMs

template timed_rc*(body: untyped): auto =
  ## Measure the execution time of the given body and return the body return code and the duration in ms.
  #[
    let (ms, fibresult) = timed:
      let fib = rand(30..44)
      fibonacci_recursive(fib) # do some cpu intense work
    echo "time used:", ms, " finonacci:", fibresult)
  ]#
  let t1 = getTime()
  let rc = body
  let durationMs = (getTime() - t1).inMilliseconds
  (ms: durationMs, rc: rc)

template timed_rc*(info: string, body: untyped) =
  var ms: int64
  var rc: int
  (ms, rc) = timed_rc: body
  echo $info & ": ", ms," ms, rc:", rc


# nimSleep

proc nimSleep*(ms: int) =
  ## Sleep for the given ms. but handle signal interruption
  var req: Timespec
  req.tv_sec = cast[posix.Time](ms div 1000)
  req.tv_nsec = (ms mod 1000 * 1000000).clong
  var rem: Timespec
  # Handle signal interruptions
  while true:
    let rc = nanosleep(req, rem)
    if rc == 0:
      break
    elif rc == EINTR:
      # Interrupted by signal, continue with remaining time
      req = rem
      rem.tv_sec = cast[posix.Time](0)
      rem.tv_nsec = 0.clong
    else:
      echo "Other error occured rc=": rc
      break


# fibonacci

proc fibonacci_recursive*(n: int): int =
  ## Simulate some CPU intense work
  if n <= 1:
    result = n
  else:
    result = fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)

proc calcFibonacciValueFor1000ms*(durationMs: int): int =
  echo "Calculate highest Fibonacci value for ", durationMs, " ms."
  for i in 25..100:
    let t1 = getTime()
    discard fibonacci_recursive(i)
    let tdiff = (getTime() - t1).inMilliseconds
    if tdiff > durationMs:
      echo "Fibonacci(",i,") took ", tdiff, " ms. to calculate"
      return i
  
  0

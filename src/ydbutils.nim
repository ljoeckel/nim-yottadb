import std/[strutils, os, osproc, posix, streams, strformat, tables, times, math]
import yottadb

# -----------------------
# Yotta related functions 
# -----------------------

# withlock:
template withlock*(body: untyped): untyped =
    ## Create a database lock named ^LOCKS(lockid) while executing the body
    lock: {+^LOCKS(int.high)}
    body
    lock: {-^LOCKS(int.high)}

template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database lock named ^LOCKS(lockid) while executing the body
    lock: {+^LOCKS(lockid)}
    body
    lock: {-^LOCKS(lockid)}

proc listVar*(name: string) =
  # List all entries for a variable with its value
  for key, value in queryItr @name.kv:
    echo fmt"{key}={value}"


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
func getDuration(microseconds: int): string =
  if microseconds >= 1000: # 1ms
    return $(microseconds div 1000) & " ms."
  else:
    return $microseconds & " µs."

# timed: templates
template timed_execute(body: untyped): auto =
  let t1 = getTime()
  body
  (getTime() - t1).inMicroseconds

template timed*(body: untyped) =
  var micros = timed_execute: body
  echo getDuration(micros)

template timed*(info: string, body: untyped) =
  let micros = timed_execute: body
  echo getDuration(micros)

template timed_ms*(body: untyped): auto =
  let micros = timed_execute: body
  micros div 1000

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
      if rc != -1: echo "nanosleep rc=": rc
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

# -------------------------------
# Process handling 'startProcess'
# -------------------------------
var processKV: Table[int, Process]

proc job*(name: string, params: seq[string], timeout: int = 30000): int =
  let prog = findExe(name)
  if prog == "": raise newException(Exception, "Executeable " & name & " not found")
  let process = startProcess(prog, args=params)
  processKV[process.processID] = process
  return process.processID

proc closeJob*(pid: int) =
  if processKV.contains(pid):
    processKV[pid].close()
    echo "Process ", pid, " closed"
  else:
    echo "Process ", pid, " NOT found"

proc closeAllProcesses*() =
    for pid in processKV.keys():
        closeJob(pid)

# -------------------------------
# Logfile handling
# -------------------------------
proc getLogs*(path: string): seq[string] =
  for kind, path in walkDir(path):
      if kind == pcFile and path.endsWith(".log"):
          result.add(path)

proc printLogs*() =
  for log in getLogs("."):
    let logFile = open(log, fmRead)
    let s = logFile.readAll()
    if not s.isEmptyOrWhitespace():
      echo "log: ", log, " ", s
    logFile.close()

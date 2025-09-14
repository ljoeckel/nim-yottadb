import posix
import std/[times, strformat]

template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database lock named ^LOCKS(lockid) while executing the body
    lockincr: ^LOCKS(lockid)
    body
    lockdecr: ^LOCKS(lockid)

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


# proc showIdxArr*(idxarr: array[0..YDB_MAX_SUBS, ydb_buffer_t]) = 
#   for i in 0..<idxarr.len:
#     if idxarr[i].len_used > 0:
#       echo "idxarr[", i, "]=", idxarr[i]
#     else:
#       break

proc fibonacci_recursive*(n: int): int =
  ## Simulate some CPU intense work
  if n <= 1:
    result = n
  else:
    result = fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)
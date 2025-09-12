import posix
import std/times

template withlock*(lockid: untyped, body: untyped): untyped =
    ## Create a database lock named ^LOCKS(lockid) while executing the body
    var rc = lockincr: ^LOCKS(lockid)
    body
    rc = lockdecr: ^LOCKS(lockid)


template timed*(body: untyped) =
  ## Measure the execution time of the given body.
  #[
    let ms = timed_norc:
      let fib = rand(30..44)
      discard fibonacci_recursive(fib) # do some cpu intense work
    echo "time used:", ms
  ]#
  let t1 = getTime()
  body
  let durationMs = (getTime() - t1).inMilliseconds
  echo "Duration: ", durationMs," ms."

template timed_ms*(body: untyped, show: bool = true): auto =
  ## Measure the execution time of the given body and return the duration in ms.
  #[
    let ms = timed_ms:
      let fib = rand(30..44)
      fibonacci_recursive(fib) # do some cpu intense work
    echo "time used:", ms, " finonacci:", fibresult)
  ]#
  let t1 = getTime()
  body
  let durationMs = (getTime() - t1).inMilliseconds
  if show:
    echo "Duration: ", durationMs," ms."
  durationMs

template timed_rc*(body: untyped, show: bool = true): auto =
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
  if show:
    echo "rc: ",rc, " duration: ", durationMs," ms."
  (ms: durationMs, rc: rc)


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


proc fibonacci_recursive*(n: int): int =
  ## Simulate some CPU intense work
  if n <= 1:
    result = n
  else:
    result = fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)
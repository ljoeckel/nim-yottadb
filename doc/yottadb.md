# YottaDB commands

## Enable Journaling
mupip set -journal=enable -region '*'

## Transaction Timeout
$ZMAXTPTI[ME] contains an integer value indicating the time duration, in seconds, YottaDB should wait for the completion of all activities fenced by the current transaction's outermost TSTART/TCOMMIT pair.

$ZMAXTPTIME can be SET but cannot be NEWed.

$ZMAXTPTIME takes its value from the environment variable ydb_maxtptime. If ydb_maxtptime is not defined, the initial value of $ZMAXTPTIME is zero (0) seconds which indicates "no timeout" (unlimited time). The value of $ZMAXTPTIME when a transaction's outermost TSTART operation executes determines the timeout setting for that transaction.

When a $ZMAXTPTIME expires, YottaDB executes the $ETRAP/$ZTRAP exception handler currently in effect.
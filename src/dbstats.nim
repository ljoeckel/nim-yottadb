import std/[strutils, posix, tables, times, math]
import libs/dsl
import libs/ydbimpl


const mnemomics* = {
    "AFRA": "# of waits for instance freeze to release critical sections",
    "BREA": "# of waits for block read & decryption",
    "BTD": "# of database Block Transitions to Dirty",
    "BTS": "# of times a dirty buffer was flushed so a BT could be reused",
    "BUS": "# of times db_csh_get could not determine whether a block was in cache or not",
    "CAT": "Critical section Total Acquisitions successes",
    "CFE": "Critical section Failed (blocked) acquisition total caused by Epochs. It is incremented a single time for each observed instance of contention.",
    "CFS": "This mnemonic is not maintained and contains zeros.",
    "CFT": "Critical section Failed (blocked) acquisition Total. It is incremented a single time for each observed instance of contention.",
    "CQS": "This mnemonic is not maintained and contains zeros.",
    "CQT": "This is maintained only if MUTEX_TYPE is YDB or ADAPTIVE. It is not maintained and contains zeros if MUTEX_TYPE is PTHREAD. When maintained, this is the number of times a process did a queued sleep while waiting for the database critical section.",
    "CTN": "Current Transaction Number of the database for the last committed read-write transaction (TP and non-TP)",
    "CYS": "This mnemonic is not maintained and contains zeros.",
    "CYT": "This is maintained only if MUTEX_TYPE is YDB or ADAPTIVE. It is not maintained and contains zeros if MUTEX_TYPE is PTHREAD. When maintained, this is the number of times a process did a yield while waiting for the database critical section.",
    "DEX": "# of Database file EXtentions",
    "DEXA": "# of waits for database extension",
    "DFL": "# of Database FLushes of the entire set of dirty global buffers in shared memory to disk",
    "DFS": "# of times a process does an fsync of the database file.",
    "DRD": "# of Disk ReaDs from the database file (TP and non-TP, committed and rolled-back). This does not include reads that are satisfied by buffered globals for databases that use the BG (Buffered Global) access method. YottaDB always reports 0 for databases that use the MM (memory-mapped) access method as this has no real meaning in that mode.",
    "DTA": "# of DaTA operations (TP and non-TP)",
    "DWT": "# of Disk WriTes to the database file (TP and non-TP, committed and rolled-back). This does not include writes that are satisfied by buffered globals for databases that use the BG (Buffered Global) access method. YottaDB always reports 0 for databases that use the MM (memory-mapped) access method as this has no real meaning in that mode.",
    "GET": "# of GET operations (TP and non-TP)",
    "GLB": "# of waits for bg access critical section",
    "JBB": "# of Journal Buffer Bytes updated in shared memory",
    "JEX": "# of Journal file EXtentions",
    "JFB": "# of Journal File Bytes written to the journal file on disk. For performance reasons, YottaDB always aligns the beginning of these writes to file system block size boundaries. JFB counts all bytes including those needed for alignment in order to reflect the actual IO load on the journal file. Since the bytes required to achieve alignment may have already been counted as part of the previous JFB, processes may write the same bytes more than once, causing the JFB counter to typically be higher than JBB.",
    "JFL": "# of Journal FLushes of all dirty journal buffers in shared memory to disk. For example: when switching journal files etc.",
    "JFS": "# of Journal FSync operations on the journal file. For example: when writing an epoch record, switching a journal file etc.",
    "JFW": "# of Journal File Write system calls",
    "JNL": "# of waits for journal access critical section",
    "JOPA": "# of waits for journal open critical section",
    "JRE": "# of Journal Regular Epoch records written to the journal file (only seen in a -detail journal extract). These are written every time an epoch-interval boundary is crossed while processing updates.",
    "JRI": "# of JouRnal Idle epoch journal records written to the journal file (only seen in a -detail journal extract). These are written when a burst of updates is followed by an idle period, around 5 seconds of no updates after the database flush timer has flushed all dirty global buffers to the database file on disk.",
    "JRL": "# of Journal Records with a Logical record type (e.g. SET, KILL etc.) written to the journal file",
    "JRO": "# of Journal Records with a type Other than logical written to the journal file (e.g. AIMG, EPOCH, PBLK, PFIN, PINI, and so on)",
    "JRP": "# of Journal Records with a Physical record type (i.e. PBLK, AIMG) written to the journal file (these records are seen only in a -detail journal extract)",
    "KIL": "# of KILl operations (kill as well as zwithdraw, TP and non-TP)",
    "KTG": "# of invoked KILL triggers",
    "LKF": "# of LocK calls (mapped to this db) that Failed",
    "LKS": "# of LocK calls (mapped to this db) that Succeeded",
    "MLBA": "# of waits for blocked LOCK",
    "MLK": "# of waits for LOCK access",
    "NBR": "# of Non-tp committed transaction induced Block Reads on this database",
    "NBW": "# of Non-tp committed transaction induced Block Writes on this database",
    "NR0": "# of Non-tp transaction Restarts at try 0",
    "NR1": "# of Non-tp transaction Restarts at try 1",
    "NR2": "# of Non-tp transaction Restarts at try 2",
    "NR3": "# of Non-tp transaction Restarts at try 3",
    "NTR": "# of Non-tp committed Transactions that were Read-only on this database",
    "NTW": "# of Non-tp committed Transactions that were read-Write on this database",
    "ORD": "# of $ORDer(,1) (forward) operations (TP and non-TP); the count of $Order(,-1) operations are reported under ZPR.",
    "PRC": "# of waits on exit",
    "PRG": "# of pre-read globals that were performed by the reader helper",
    "QRY": "# of $QueRY() operations (TP and non-TP)",
    "SET": "# of SET operations (TP and non-TP)",
    "STG": "# of invoked SET triggers",
    "TBR": "# of Tp transaction induced Block Reads on this database",
    "TBW": "# of Tp transaction induced Block Writes on this database",
    "TC0": "# of Tp transaction Conflicts at try 0 (counted only for that region which caused the TP transaction restart)",
    "TC1": "# of Tp transaction Conflicts at try 1 (counted only for that region which caused the TP transaction restart)",
    "TC2": "# of Tp transaction Conflicts at try 2 (counted only for that region which caused the TP transaction restart)",
    "TC3": "# of Tp transaction Conflicts at try 3 (counted only for that region which caused the TP transaction restart)",
    "TC4": "# of Tp transaction Conflicts at try 4 and above (counted only for that region which caused the TP transaction restart)",
    "TR0": "# of Tp transaction Restarts at try 0 (counted for all regions participating in restarting TP transaction)",
    "TR1": "# of Tp transaction Restarts at try 1 (counted for all regions participating in restarting TP transaction)",
    "TR2": "# of Tp transaction Restarts at try 2 (counted for all regions participating in restarting TP transaction)",
    "TR3": "# of Tp transaction Restarts at try 3 (counted for all regions participating in restarting TP transaction)",
    "TR4": "# of Tp transaction Restarts at try 4 and above (restart counted for all regions participating in restarting TP transaction)",
    "TRB": "# of Tp read-only or read-write transactions Rolled Back (excluding incremental rollbacks)",
    "TRGA": "# of mini-transaction completion",
    "TRX": "# of waits for transaction in progress",
    "TTR": "# of Tp committed Transactions that were Read-only on this database",
    "TTW": "# of Tp committed Transactions that were read-Write on this database",
    "WFL": "# of database flushes that were performed by the writer helpers",
    "WFR": "# of times a process slept while waiting for another process to read in a database block",
    "WHE": "# of writer helper epochs",
    "WRL": "# of times a process consistently slept (longer than WFR) while waiting for another process to read in a database block",
    "ZAD": "# of waits for region freeze off",
    "ZPR": "# of $order(,-1) or $ZPRevious() (reverse order) operations (TP and non-TP). The count of $Order(,1) operations are reported under ORD.",
    "ZTG": "# of invoked ZTRIGGERs",
    "ZTR": "# of ZTRigger command operations"
}.toTable


proc updateDBStats*(domainKey: string) =
    ydb_ci: "xzshow"
    for (key, value) in QueryItr RESULT("G",0).kv:
        let fields = value.split(",")
        for field in fields:
            let parts = field.split(":")
            let mnemonic = parts[0]
            if mnemonic in mnemomics:
                let value = parseInt(parts[1])
                if value != 0:
                    let pid = Get $JOB
                    let tm = now().toTime().toUnix()
                    let prevValue = Get ^DBStats(domainKey, mnemonic, pid)
                    var delta: int
                    if not prevValue.isEmptyOrWhitespace:
                        delta = value - parseInt(prevValue)
                    else:
                        delta = value
                    if delta > 0:
                        #echo domainKey," ",mnemonic," prevValue=", prevValue, " value=", value, " delta=", delta
                        Set: ^DBStats(domainKey, mnemonic, pid) = value
                        Set: ^DBStatsDOMAIN(domainKey, mnemonic, tm, pid) = delta


proc getDomains*(): seq[string] =
    for domain in OrderItr ^DBStatsDOMAIN:
        result.add(domain)

proc getMnemonics*(domain: string): seq[string] =
    for mnemonic in OrderItr ^DBStatsDOMAIN(domain,""):
        result.add(mnemonic)
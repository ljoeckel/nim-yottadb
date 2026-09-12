# Some Benchmarks

Benchmarks are measured on Ubuntu 24.04.3 LTS.
```bash
System 'A' is AMD Ryzen 7 2700X 8-Core with 3900 MHz
Virtualized on proxmox with 2 cpu cores / 4GB RAM

System 'B' is MacMini M4
Virtualized on UTM with 2 cpu cores / 4GB RAM
```
Compiled with
```bash
nim c --mm:arc|markAndSweep -r -d:release -d:danger --threads:off benchmark
````

```
Each test runs with 10_000_000 iterations.

               System A         System B
Test           arc   mAS        arc   mAS
upcount        8746  7987       2382  2474 
upcount dsl    8940  7958       2439  2515
set            8278  6182       2255  2227
set dsl        8905  6448       2479  2387
nextnode       4602  5694       1534  2129
nextnode dsl   4654  5649       1536  2133
delnode        8824  8151       2551  2628
delnode dsl    9082  8371       2774  2882
````

# Nim vs. Rust
Comparing the nim-yottadb implementation with the official YottaDB Rust implementation with the following code

**Nim**
```nim
proc setSimple() =
  for id in 0..<10000000:
    Set: ^hello(id)=id

timed("set simple"): setSimple()
```
**Rust**
```rust
use yottadb::{Context, KeyContext as Key, YDBError};
fn main() -> Result<(), YDBError> {
    let ctx = Context::new();
    for i in 0..10000000 {
      let s = i.to_string();
      let hello = Key::new(&ctx, "^hello", &[s.as_str()]);
      hello.set("hello")?;
    }
    Ok(())
}
```
**Results**
```bash
Test runs with 10_000_000 iterations on 'B' (MacMini M4)
Test     Nim       Rust    Nim Compile              
set api  2.488s    2.335s  release                  
set api  2.414s            release,danger.          
set api  2.119s            release,danger,mm:refc
set api  2.818s            release,danger,mm:arc
set api  2.692s            release,danger,mm:orc
set api  11.62s            release,danger,mm:atomicArc
set api  2.016s            release,danger,mm:markAndSweep
set api  2.098s            release,danger,mm:boehm
set api  2.076s            release,danger,mm:regions
set dsl  2.790s            release                  
set dsl  2.596s            release,danger           
```
For both tests the global ^hello was killed first. Only the fist run counts.
The dsl adds a small amount of additional work.

**Conclusion**

With some memory management configurations, Nim outperforms Rust in this scenario. The practical implications may be minimal. The difference per iteration is extremly low.



** Compression Benchmarks **
All are run on "MacMini M4, 16GB"

YottaDB - Journaling disabled, 3'rd run:

$./archiveRSS
Loading files ...
Loaded 10000 files
Load data: : time:250 ms. bytes:1245289471 Throughput: 4.639 G/s.
Compression lz4: time:1272 ms. bytes:1245289471 Throughput: 933.648 M/s.
Decompression lz4: time:324 ms. bytes:1245289471 Throughput: 3.580 G/s.
Read Compressed lz4: time:119 ms. bytes:458195249 Throughput: 3.586 G/s.
Ratio lz4: 2.717814018625933
[OK] lz4
Compression zstd: time:1779 ms. bytes:1245289471 Throughput: 667.566 M/s.
Decompression zstd: time:660 ms. bytes:1245289471 Throughput: 1.757 G/s.
Read Compressed zstd: time:77 ms. bytes:299614507 Throughput: 3.624 G/s.
Ratio zstd: 4.156305659124843
[OK] zstd lvl 1

YottaDB - Journaling enabled, 3'rd run:
$./archiveRSS
Loading files ...
Loaded 10000 files
Load data: : time:242 ms. bytes:1245289471 Throughput: 4.792 G/s.
Compression lz4: time:2750 ms. bytes:1245289471 Throughput: 431.854 M/s.
Decompression lz4: time:319 ms. bytes:1245289471 Throughput: 3.636 G/s.
Read Compressed lz4: time:110 ms. bytes:458195249 Throughput: 3.879 G/s.
Ratio lz4: 2.717814018625933
[OK] lz4
Compression zstd: time:2584 ms. bytes:1245289471 Throughput: 459.598 M/s.
Decompression zstd: time:664 ms. bytes:1245289471 Throughput: 1.747 G/s.
Read Compressed zstd: time:73 ms. bytes:299614507 Throughput: 3.822 G/s.
Ratio zstd: 4.156305659124843
[OK] zstd lvl 1
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
nim c -r --threads:off -d:release benchmark
````

```
Each test runs with 10_000_000 iterations.
Test            Duration ms. A      Duration ms. B
upcount             9934                3317
upcount dsl        10209                3252
set                 8193                2443
set dsl             8879                2741
nextnode           21366                7836
nextnode dsl       21428                7911
delnode             8791                2811
delnode dsl         9238                2936
````

# Nim vs. Rust
Comparing the nim-yottadb implementation with the official YottaDB Rust implementation with the following code

**Nim**
```nim
proc setSimple() =
    for id in 0..<10000000:
        set: ^hello($id)="hello"
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


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
Test     Nim       Rust    Nim Compile     Rust
set api  2.488s    2.335s  release         -7%
set api  2.414s    2.335s  release,danger. -4%
set dsl  2.790s    2.335s  release         -16%
set dsl  2.596s    2.335s  release,danger  -10%
```

There is some advantage for Rust over Nim in this scenario. For both tests the global ^hello was killed first. Only the fist run counts.
The dsl adds a small amount of additional work.

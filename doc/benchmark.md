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
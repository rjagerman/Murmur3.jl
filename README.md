Murmur3
=======

Julia implementation of Murmur3 hashing.

##Performance
Tested on Windows 7 (64 bit) with Intel core i5 3570K at 4222.25 Mhz. Julia performance is measured relative to the reference C++ implementation performance.

| Payload | Iterations | C++   | Julia x86 32-bit  | Julia x86 128-bit | Julia x64 128-bit |
| ------- | ----------:| -----:| -----------------:| -----------------:| -----------------:|
| 5   B   | 50,000,000 | 1.000 | **3.392** ± 0.006 | **2.908** ± 0.002 | **3.140** ± 0.003 |
| 15  B   | 25,000,000 | 1.000 | **2.843** ± 0.005 | **2.715** ± 0.002 | **2.666** ± 0.002 |
| 256 B   | 5,000,000  | 1.000 | **1.168** ± 0.001 | **1.485** ± 0.018 | **1.575** ± 0.004 |
| 256 KiB | 5,000      | 1.000 | **1.028** ± 0.001 | **1.257** ± 0.002 | **1.222** ± 0.002 |
| 256 MiB | 10         | 1.000 | **1.027** ± 0.002 | **1.249** ± 0.002 | **1.218** ± 0.002 |

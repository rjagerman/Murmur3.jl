Murmur3
=======

Julia implementation of Murmur3 hashing.

##Performance
Tested on Windows 7 (64 bit) with Intel core i5 3570K at 4222.25 Mhz. Julia performance is measured relative to the reference C++ implementation performance.

| Payload | Iterations | C++   | Julia x86 32-bit  | Julia x86 128-bit | Julia x64 128-bit |
| ------- | ----------:| -----:| -----------------:| -----------------:| -----------------:|
| 256 B   | 25,000,000 | 1.000 | **1.488** ± 0.003 | **1.872** ± 0.003 | **2.353** ± 0.004 |
| 256 KiB | 25,000     | 1.000 | **1.027** ± 0.001 | **1.253** ± 0.002 | **1.224** ± 0.003 |
| 256 MiB | 25         | 1.000 | **1.024** ± 0.002 | **1.247** ± 0.002 | **1.221** ± 0.003 |




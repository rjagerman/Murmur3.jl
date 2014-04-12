Murmur3
=======

Julia implementation of Murmur3 hashing.

##Performance
Tested on Windows 7 (64 bit) with Intel core i5 3570K at 4222.25 Mhz.

    C++:               1.000 ± 0.000
    Julia x86 32-bit:  1.159 ± 0.003
    Julia x86 128-bit: 1.425 ± 0.007
    Julia x64 128-bit: 1.458 ± 0.008

The 128 bit versions use 15 if-statements in the tail operation which causes the drop in performance. A jump/goto or switch/case (with fallthrough) would probably be much more efficient, but those are not available in Julia.

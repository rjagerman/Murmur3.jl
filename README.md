# Murmur3
Julia implementation of Murmur3 hashing. Pull requests are very welcome!

[![Build Status](https://travis-ci.org/rjagerman/Murmur3.jl.svg?branch=master)](https://travis-ci.org/rjagerman/Murmur3.jl) [![Coverage Status](https://coveralls.io/repos/rjagerman/Murmur3.jl/badge.png?branch=master)](https://coveralls.io/r/rjagerman/Murmur3.jl?branch=master)

## Usage
Make sure Murmur3 is imported:

    using Murmur3

Next, use the three hashing functions on Strings or Uint8 Arrays:

    Murmur3.x86.hash32("Hello world!")
    Murmur3.x86.hash128("This is Murmur3 hashing!")
    Murmur3.x64.hash128("You can also add seeds!", 42)
    
The 32-bit function returns a 32 bit unsigned integer. The 128-bit variants return a 128 bit unsigned integer.

## Performance
Tested on Windows 7 (64 bit) with Intel core i5 3570K at 4222.25 Mhz. Julia performance is measured relative to the reference C++ implementation performance.

| Payload | Iterations  | C++   | Julia x86 32-bit  | Julia x86 128-bit | Julia x64 128-bit |
| ------- | -----------:| -----:| -----------------:| -----------------:| -----------------:|
| 5   B   | 100,000,000 | 1.000 | **1.287** ± 0.002 | **1.635** ± 0.001 | **1.966** ± 0.001 |
| 15  B   | 50,000,000  | 1.000 | **1.200** ± 0.001 | **1.707** ± 0.001 | **1.852** ± 0.002 |
| 256 B   | 5,000,000   | 1.000 | **1.060** ± 0.004 | **1.418** ± 0.002 | **1.531** ± 0.003 |
| 256 KiB | 5,000       | 1.000 | **1.008** ± 0.005 | **1.288** ± 0.001 | **1.177** ± 0.002 |
| 256 MiB | 10          | 1.000 | **1.006** ± 0.003 | **1.285** ± 0.001 | **1.175** ± 0.002 |

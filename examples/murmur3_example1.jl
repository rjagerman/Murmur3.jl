# example 1: basic string hashing

include("../src/Murmur3.jl")
using Murmur3

value = "Hello world"

hash = Murmur3.x86.hash32(value)
println("x86  32-bit: \"$value\" => $(hex(hash))")

hash = Murmur3.x86.hash128(value)
println("x86 128-bit: \"$value\" => $(hex(hash))")

hash = Murmur3.x64.hash128(value)
println("x64 128-bit: \"$value\" => $(hex(hash))")

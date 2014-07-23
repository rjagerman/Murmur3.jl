# example 2: string hashing with a seed

include("../src/Murmur3.jl")
using Murmur3

value = "Hello world"
seed = 42

hash = Murmur3.x86.hash32(value, seed)
println("x86  32-bit (seed: $seed): \"$value\" => $(hex(hash))")

hash = Murmur3.x86.hash128(value, seed)
println("x86 128-bit (seed: $seed): \"$value\" => $(hex(hash))")

hash = Murmur3.x64.hash128(value, seed)
println("x64 128-bit (seed: $seed): \"$value\" => $(hex(hash))")


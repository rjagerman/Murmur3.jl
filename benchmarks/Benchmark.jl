include("../src/Murmur3.jl")
using Murmur3
using JSON
Murmur3.x86.hash32("Warmup")
Murmur3.x86.hash128("Warmup")
Murmur3.x64.hash128("Warmup")

# Generate payload if it doesn't exist
if !isfile("benchmarks/data.txt")
    println("Benchmark data doesn't exist, generating 256MiB...");
    f = open("benchmarks/data.txt", "w")
    for i = 1:256*1024*1024
        write(f, (((i-1)*4)%25) + 'A');
    end
    close(f)
end

# Load the payloads
f = open("benchmarks/data.txt", "r")
payload_5B = read(f, Array(Uint8,5))
close(f)

f = open("benchmarks/data.txt", "r")
payload_15B = read(f, Array(Uint8,15))
close(f)

f = open("benchmarks/data.txt", "r")
payload_256B = read(f, Array(Uint8,256))
close(f)

f = open("benchmarks/data.txt", "r")
payload_256KiB = read(f, Array(Uint8,256 * 1024))
close(f)

f = open("benchmarks/data.txt", "r")
payload_256MiB = read(f, Array(Uint8,256 * 1024 * 1024))
close(f)

# Load the C++ reference times
f = open("benchmarks/i5-3570K-4222-C-times.json")
reference = JSON.parse(readall(f))
close(f)


function bench_x86_32(times::Uint32, payload::Array{Uint8})
    seed = uint32(0)
    for i = 1:times
        Murmur3.x86.hash32(payload, seed)
    end
end

function bench_x86_128(times::Uint32, payload::Array{Uint8})
    seed = uint32(0)
    for i = 1:times
        Murmur3.x86.hash128(payload, seed)
    end
end

function bench_x64_128(times::Uint32, payload::Array{Uint8})
    seed = uint64(0)
    for i = 1:times
        Murmur3.x64.hash128(payload, seed)
    end
end

function repeat_and_measure(benchfunc, ref, args...)
    measurements = Float64[]
    for i = 1:10
        tic()
        apply(benchfunc, args)
        push!(measurements, toq())
    end
    m = mean(measurements ./ ref)
    s = std(measurements ./ ref)
    @printf("%.3f ± %.3f\n", m, s)
end

function benchmark_scenarios(benchfunc, ref)
    print("  5   B: ")
    repeat_and_measure(benchfunc, ref["pl_5B"], uint32(50000000), payload_5B)
    print(" 15   B: ")
    repeat_and_measure(benchfunc, ref["pl_15B"], uint32(25000000), payload_15B)
    print("256   B: ")
    repeat_and_measure(benchfunc, ref["pl_256B"], uint32(5000000), payload_256B)
    print("256 KiB: ")
    repeat_and_measure(benchfunc, ref["pl_256KiB"], uint32(5000), payload_256KiB)
    print("256 MiB: ")
    repeat_and_measure(benchfunc, ref["pl_256MiB"], uint32(10), payload_256MiB)
end

println("x86 32-bit")
benchmark_scenarios(bench_x86_32, reference["x86_32"])

println("x86 128-bit")
benchmark_scenarios(bench_x86_128, reference["x86_128"])

println("x64 128-bit")
benchmark_scenarios(bench_x64_128, reference["x64_128"])

println("Done!")

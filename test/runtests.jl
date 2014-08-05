using Murmur3
using Base.Test
using JSON

f = open("test/tests.json")
tests = JSON.parse(readall(f))
close(f)

for test in tests

    if "seed" in keys(test)
        x86_32 = lpad(hex(Murmur3.x86.hash32(test["text"], test["seed"])), 8, "0")
        x86_128 = lpad(hex(Murmur3.x86.hash128(test["text"], test["seed"])), 32, "0")
        x64_128 = lpad(hex(Murmur3.x64.hash128(test["text"], test["seed"])), 32, "0")
    else
        x86_32 = lpad(hex(Murmur3.x86.hash32(test["text"])), 8, "0")
        x86_128 = lpad(hex(Murmur3.x86.hash128(test["text"])), 32, "0")
        x64_128 = lpad(hex(Murmur3.x64.hash128(test["text"])), 32, "0")
    end

    @test test["x86_32"] == x86_32
    @test test["x86_128"] == x86_128
    @test test["x64_128"] == x64_128

end


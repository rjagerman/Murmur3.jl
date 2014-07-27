using Murmur3
using Base.Test
using JSON

f = open("test/tests.json")
tests = JSON.parse(readall(f))
close(f)

for test in tests

    if "seed" in keys(test)
        x86_32 = hex(Murmur3.x86.hash32(test["text"], test["seed"]))
        x86_128 = hex(Murmur3.x86.hash128(test["text"], test["seed"]))
        x64_128 = hex(Murmur3.x64.hash128(test["text"], test["seed"]))
    else
        x86_32 = lpad(hex(Murmur3.x86.hash32(test["text"])), 8, "0")
        x86_128 = lpad(hex(Murmur3.x86.hash128(test["text"])), 32, "0")
        x64_128 = lpad(hex(Murmur3.x64.hash128(test["text"])), 32, "0")
    end

    test["x86_32"] = x86_32
    test["x86_128"] = x86_128
    test["x64_128"] = x64_128

end

f = open("test/tests.json", "w")
JSON.print(f, tests)
close(f)


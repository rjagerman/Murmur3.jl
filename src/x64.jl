module x64

function rotl64(var::Integer, value::Integer)
    (var << value) | (var >> (64-value))
end

function fmix64(value::Integer)
    value ⊻= (value >> 33)
    value = UInt64(value * UInt64(0xff51afd7ed558ccd))
    value ⊻= (value >> 33)
    value = UInt64(value * UInt64(0xc4ceb9fe1a85ec53))
    value ⊻= (value >> 33)
end

function hash128(data::Array{UInt8}, seed::UInt64)

    c1 = UInt64(0x87c37b91114253d5)
    c2 = UInt64(0x4cf5ad432745937f)

    h1 = seed
    h2 = seed

    len = UInt64(length(data))
    remainder = len & 15
    blocks = div(len, UInt64(16))
    p = convert(Ptr{UInt64}, pointer(data))

    # Body
    iterations = UInt64(blocks*2)
    for next_block::UInt64 = UInt64(1):UInt64(2):iterations
        k1 = UInt64(unsafe_load(p, next_block))
        k2 = UInt64(unsafe_load(p, next_block+1))

        k1 = k1 * c1
        k1 = rotl64(k1, 31)
        k1 = k1 * c2
        h1 ⊻= k1

        h1 = rotl64(h1, 27)
        h1 = h1 + h2
        h1 = h1 * UInt64(5) + UInt64(0x52dce729)

        k2 = k2 * c2
        k2 = rotl64(k2, 33)
        k2 = k2 * c1
        h2 ⊻= k2

        h2 = rotl64(h2, 31)
        h2 = h2 + h1
        h2 = h2 * UInt64(5) + UInt64(0x38495ab5)
    end

    # Tail
    last = blocks*16
    k1 = UInt64(0)
    k2 = UInt64(0)

    if remainder == 15
        k2 ⊻= UInt64(data[last+15]) << 48
    elseif remainder == 14
        k2 ⊻= UInt64(data[last+14]) << 40
    elseif remainder == 13
        k2 ⊻= UInt64(data[last+13]) << 32
    elseif remainder == 12
        k2 ⊻= UInt64(data[last+12]) << 24
    elseif remainder == 11
        k2 ⊻= UInt64(data[last+11]) << 16
    elseif remainder == 10
        k2 ⊻= UInt64(data[last+10]) << 8
    elseif remainder == 9
        k2 ⊻= UInt64(data[last+9]) << 0
        k2 = k2 * c2
        k2 = rotl64(k2, 33)
        k2 = k2 * c1
        h2 ⊻= k2
    elseif remainder == 8
        k1 ⊻= UInt64(data[last+8]) << 56
    elseif remainder == 7
        k1 ⊻= UInt64(data[last+7]) << 48
    elseif remainder == 6
        k1 ⊻= UInt64(data[last+6]) << 40
    elseif remainder == 5
        k1 ⊻= UInt64(data[last+5]) << 32
    elseif remainder == 4
        k1 ⊻= UInt64(data[last+4]) << 24
    elseif remainder == 3
        k1 ⊻= UInt64(data[last+3]) << 16
    elseif remainder == 2
        k1 ⊻= UInt64(data[last+2]) << 8
    elseif remainder == 1
        k1 ⊻= UInt64(data[last+1])
        k1 = k1 * c1
        k1 = rotl64(k1, 31)
        k1 = k1 * c2
        h1 ⊻= k1
    end

    # Finalization
    h1 ⊻= len
    h2 ⊻= len
    h1 = h1 + h2
    h2 = h2 + h1
    h1 = fmix64(h1)
    h2 = fmix64(h2)
    h1 = h1 + h2
    h2 = h2 + h1

    h1 = rotl64(h1, 32)
    h2 = rotl64(h2, 32)

    return (UInt128(h1) << 64) | UInt128(h2)

end

hash128(data::Array{UInt8}, seed::Int) = hash128(data, UInt64(seed))
hash128(data::Array{UInt8}) = hash128(data, UInt64(0))
hash128(data::AbstractString, seed::UInt64) = hash128(UInt8.(collect(data)), seed)
hash128(data::AbstractString, seed::Int) = hash128(UInt8.(collect(data)), UInt64(seed))
hash128(data::AbstractString) = hash128(UInt8.(collect(data)), UInt64(0))

end

module x86

using Switch

macro rotl32(var, value)
    :(($var << $value) | ($var >> $(32-value)))
end

macro fmix32(var)
    quote
      local value = $(var)
      value $= (value >> 16)
      value = UInt32(value * UInt32(0x85ebca6b))
      value $= (value >> 13)
      value = UInt32(value * UInt32(0xc2b2ae35))
      value $= (value >> 16)
      value
    end
end

function hash32(data::Array{UInt8}, seed::UInt32)
    c1 = UInt32(0xcc9e2d51)
    c2 = UInt32(0x1b873593)
    h = seed

    len = UInt32(length(data))
    remainder = len & 3
    blocks = div(len, 4)
    p = convert(Ptr{UInt32}, pointer(data))

    # Body
    for next_block = 1:blocks
        k = UInt32(unsafe_load(p, next_block))
        k = k * c1
        k = @rotl32(k, 15)
        k = k * c2

        h $= k
        h = @rotl32(h, 13)
        h = h * UInt32(5) + UInt32(0xe6546b64)
    end

    # Tail
    k = UInt32(0)
    last = blocks*4 + 1
    @switch remainder begin
        @case 3
            k |= UInt32(data[last + 2]) << 16
        @case 2
            k |= UInt32(data[last + 1]) << 8
        @case 1
            k |= UInt32(data[last])
    end

    k = k * c1
    k = @rotl32(k, 15)
    k = k * c2
    h $= k

    # Finalization
    h $= len
    h = @fmix32(h)

    return h

end

hash32(data::Array{UInt8}, seed::Int) = hash32(data, UInt32(seed))
hash32(data::Array{UInt8}) = hash32(data, UInt32(0))
hash32(data::AbstractString, seed::UInt32) = hash32(convert(Array{UInt8}, data), seed)
hash32(data::AbstractString, seed::Int) = hash32(convert(Array{UInt8}, data), UInt32(seed))
hash32(data::AbstractString) = hash32(convert(Array{UInt8}, data), UInt32(0))

function hash128(data::Array{UInt8}, seed::UInt32)
    c1 = UInt32(0x239b961b)
    c2 = UInt32(0xab0e9789)
    c3 = UInt32(0x38b34ae5)
    c4 = UInt32(0xa1e38b93)

    h1 = seed
    h2 = seed
    h3 = seed
    h4 = seed

    len = UInt32(length(data))
    remainder = len & 15
    blocks = div(len, 16)
    p = convert(Ptr{UInt32}, pointer(data))

    # Body
    for next_block = 1:4:blocks*4
        k1 = UInt32(unsafe_load(p, next_block))
        k2 = UInt32(unsafe_load(p, next_block+1))
        k3 = UInt32(unsafe_load(p, next_block+2))
        k4 = UInt32(unsafe_load(p, next_block+3))

        k1 = k1 * c1
        k1 = @rotl32(k1, 15)
        k1 = k1 * c2
        h1 $= k1

        h1 = @rotl32(h1, 19)
        h1 = h1 + h2
        h1 = h1 * UInt32(5) + UInt32(0x561ccd1b)

        k2 = k2 * c2
        k2 = @rotl32(k2, 16)
        k2 = k2 * c3
        h2 $= k2

        h2 = @rotl32(h2, 17)
        h2 = h2 + h3
        h2 = h2 * UInt32(5) + UInt32(0x0bcaa747)

        k3 = k3 * c3
        k3 = @rotl32(k3, 17)
        k3 = k3 * c4
        h3 $= k3

        h3 = @rotl32(h3, 15)
        h3 = h3 + h4
        h3 = h3 * UInt32(5) + UInt32(0x96cd1c35)

        k4 = k4 * c4
        k4 = @rotl32(k4, 18)
        k4 = k4 * c1
        h4 $= k4

        h4 = @rotl32(h4, 13)
        h4 = h4 + h1
        h4 = h4 * UInt32(5) + 0x32ac3b17

    end

    # Tail
    last = blocks*16
    k1 = UInt32(0)
    k2 = UInt32(0)
    k3 = UInt32(0)
    k4 = UInt32(0)

    @switch remainder begin
        @case 15
            k4 $= UInt32(data[last+15]) << 16
        @case 14
            k4 $= UInt32(data[last+14]) << 8
        @case 13
            k4 $= UInt32(data[last+13])
            k4 = k4 * c4
            k4 = @rotl32(k4, 18)
            k4 = k4 * c1
            h4 $= k4
        @case 12
            k3 $= UInt32(data[last+12]) << 24
        @case 11
            k3 $= UInt32(data[last+11]) << 16
        @case 10
            k3 $= UInt32(data[last+10]) << 8
        @case 9
            k3 $= UInt32(data[last+9])
            k3 = k3 * c3
            k3 = @rotl32(k3, 17)
            k3 = k3 * c4
            h3 $= k3
        @case 8
            k2 $= UInt32(data[last+8]) << 24
        @case 7
            k2 $= UInt32(data[last+7]) << 16
        @case 6
            k2 $= UInt32(data[last+6]) << 8
        @case 5
            k2 $= UInt32(data[last+5])
            k2 = k2 * c2
            k2 = @rotl32(k2, 16)
            k2 = k2 * c3
            h2 $= k2
        @case 4
            k1 $= UInt32(data[last+4]) << 24
        @case 3
            k1 $= UInt32(data[last+3]) << 16
        @case 2
            k1 $= UInt32(data[last+2]) << 8
        @case 1
            k1 $= UInt32(data[last+1])
            k1 = k1 * c1
            k1 = @rotl32(k1, 15)
            k1 = k1 * c2
            h1 $= k1
    end

    # Finalization
    h1 $= len
    h2 $= len
    h3 $= len
    h4 $= len

    h1 = h1 + h2
    h1 = h1 + h3
    h1 = h1 + h4
    h2 = h2 + h1
    h3 = h3 + h1
    h4 = h4 + h1

    h1 = @fmix32(h1)
    h2 = @fmix32(h2)
    h3 = @fmix32(h3)
    h4 = @fmix32(h4)

    h1 = h1 + h2
    h1 = h1 + h3
    h1 = h1 + h4
    h2 = h2 + h1
    h3 = h3 + h1
    h4 = h4 + h1

    return UInt128(h1)<<96 | (UInt128(h2)<<64) | (UInt128(h3)<<32) | (UInt128(h4))
end

hash128(data::Array{UInt8}, seed::Int) = hash128(data, UInt32(seed))
hash128(data::Array{UInt8}) = hash128(data, UInt32(0))
hash128(data::AbstractString, seed::UInt32) = hash128(convert(Array{UInt8}, data), seed)
hash128(data::AbstractString, seed::Int) = hash128(convert(Array{UInt8}, data), UInt32(seed))
hash128(data::AbstractString) = hash128(convert(Array{UInt8}, data), UInt32(0))

end

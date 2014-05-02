module Murmur3

    module x86

        macro rotl32(var, value)
            :(($var << $value) | ($var >> $(32-value)))
        end

        macro fmix32(var)
            quote
              local value = $(var)
              value $= (value >> 16)
              value = uint32(value * uint32(0x85ebca6b))
              value $= (value >> 13)
              value = uint32(value * uint32(0xc2b2ae35))
              value $= (value >> 16)
              value
            end
        end

        function hash32(data::Array{Uint8}, seed::Uint32)
            c1 = uint32(0xcc9e2d51)
            c2 = uint32(0x1b873593)
            h = seed

            len = uint32(length(data))
            remainder = len & 3
            blocks = uint32(floor(len / 4))
            pointer = convert(Ptr{Uint32}, data)

            # Body
            for next_block = 1:blocks
                k = unsafe_load(pointer, next_block)
                k = uint32(k * c1)
                k = @rotl32(k, 15)
                k = uint32(k * c2)

                h $= k
                h = @rotl32(h, 13)
                h = uint32(h * 5 + 0xe6546b64)
            end

            # Tail
            k = uint32(0)
            last = blocks*4 + 1
            if remainder == 3
                k = (uint32(data[last + 2]) << 16) | (uint32(data[last + 1]) << 8) | uint32(data[last])
            elseif remainder == 2
                k = (uint32(data[last + 1]) << 8) | uint32(data[last])
            elseif remainder == 1
                k = uint32(data[last])
            end
            k = uint32(k * c1)
            k = @rotl32(k, 15)
            k = uint32(k * c2)
            h $= k

            # Finalization
            h $= len
            h = @fmix32(h)

            return h

        end

        hash32(data::Array{Uint8}, seed::Int) = hash32(data, uint32(seed))
        hash32(data::Array{Uint8}) = hash32(data, uint32(0))
        hash32(data::String, seed::Uint32) = hash32(convert(Array{Uint8}, data), seed)
        hash32(data::String, seed::Int) = hash32(convert(Array{Uint8}, data), uint32(seed))
        hash32(data::String) = hash32(convert(Array{Uint8}, data), uint32(0))

        function hash128(data::Array{Uint8}, seed::Uint32)
            c1 = uint32(0x239b961b)
            c2 = uint32(0xab0e9789)
            c3 = uint32(0x38b34ae5)
            c4 = uint32(0xa1e38b93)

            h1 = seed
            h2 = seed
            h3 = seed
            h4 = seed

            len = uint32(length(data))
            remainder = len & 15
            blocks = int(floor(len / 16))
            pointer = convert(Ptr{Uint32}, data)

            # Body
            for next_block = 1:4:blocks*4
                k1 = unsafe_load(pointer, next_block)
                k2 = unsafe_load(pointer, next_block+1)
                k3 = unsafe_load(pointer, next_block+2)
                k4 = unsafe_load(pointer, next_block+3)

                k1 = uint32(k1 * c1)
                k1 = @rotl32(k1, 15)
                k1 = uint32(k1 * c2)
                h1 $= k1

                h1 = @rotl32(h1, 19)
                h1 = uint32(h1 + h2)
                h1 = uint32(h1 * 5 + 0x561ccd1b)

                k2 = uint32(k2 * c2)
                k2 = @rotl32(k2, 16)
                k2 = uint32(k2 * c3)
                h2 $= k2

                h2 = @rotl32(h2, 17)
                h2 = uint32(h2 + h3)
                h2 = uint32(h2 * 5 + 0x0bcaa747)

                k3 = uint32(k3 * c3)
                k3 = @rotl32(k3, 17)
                k3 = uint32(k3 * c4)
                h3 $= k3

                h3 = @rotl32(h3, 15)
                h3 = uint32(h3 + h4)
                h3 = uint32(h3 * 5 + 0x96cd1c35)

                k4 = uint32(k4 * c4)
                k4 = @rotl32(k4, 18)
                k4 = uint32(k4 * c1)
                h4 $= k4

                h4 = @rotl32(h4, 13)
                h4 = uint32(h4 + h1)
                h4 = uint32(h4 * 5 + 0x32ac3b17)

            end

            # Tail
            last = blocks*16
            k1 = uint32(0)
            k2 = uint32(0)
            k3 = uint32(0)
            k4 = uint32(0)

            if remainder >= 15; k4 $= uint32(data[last+15]) << 16; end
            if remainder >= 14; k4 $= uint32(data[last+14]) << 8; end
            if remainder >= 13; k4 $= uint32(data[last+13]) << 0
                k4 = uint32(k4 * c4)
                k4 = @rotl32(k4, 18)
                k4 = uint32(k4 * c1)
                h4 $= k4
            end

            if remainder >= 12; k3 $= uint32(data[last+12]) << 24; end
            if remainder >= 11; k3 $= uint32(data[last+11]) << 16; end
            if remainder >= 10; k3 $= uint32(data[last+10]) << 8; end
            if remainder >=  9; k3 $= uint32(data[last+ 9]) << 0
                k3 = uint32(k3 * c3)
                k3 = @rotl32(k3, 17)
                k3 = uint32(k3 * c4)
                h3 $= k3
            end

            if remainder >= 8; k2 $= uint32(data[last+8]) << 24; end
            if remainder >= 7; k2 $= uint32(data[last+7]) << 16; end
            if remainder >= 6; k2 $= uint32(data[last+6]) << 8; end
            if remainder >= 5; k2 $= uint32(data[last+5]) << 0
                k2 = uint32(k2 * c2)
                k2 = @rotl32(k2, 16)
                k2 = uint32(k2 * c3)
                h2 $= k2
            end

            if remainder >= 4; k1 $= uint32(data[last+4]) << 24; end
            if remainder >= 3; k1 $= uint32(data[last+3]) << 16; end
            if remainder >= 2; k1 $= uint32(data[last+2]) << 8; end
            if remainder >= 1; k1 $= uint32(data[last+1]) << 0
                k1 = uint32(k1 * c1)
                k1 = @rotl32(k1, 15)
                k1 = uint32(k1 * c2)
                h1 $= k1
            end

            # Finalization
            h1 $= len
            h2 $= len
            h3 $= len
            h4 $= len

            h1 = uint32(h1 + h2)
            h1 = uint32(h1 + h3)
            h1 = uint32(h1 + h4)
            h2 = uint32(h2 + h1)
            h3 = uint32(h3 + h1)
            h4 = uint32(h4 + h1)

            h1 = @fmix32(h1)
            h2 = @fmix32(h2)
            h3 = @fmix32(h3)
            h4 = @fmix32(h4)

            h1 = uint32(h1 + h2)
            h1 = uint32(h1 + h3)
            h1 = uint32(h1 + h4)
            h2 = uint32(h2 + h1)
            h3 = uint32(h3 + h1)
            h4 = uint32(h4 + h1)

            return uint128(h1)<<96 | (uint128(h2)<<64) | (uint128(h3)<<32) | (uint128(h4))
        end

        hash128(data::Array{Uint8}, seed::Int) = hash128(data, uint32(seed))
        hash128(data::Array{Uint8}) = hash128(data, uint32(0))
        hash128(data::String, seed::Uint32) = hash128(convert(Array{Uint8}, data), seed)
        hash128(data::String, seed::Int) = hash128(convert(Array{Uint8}, data), uint32(seed))
        hash128(data::String) = hash128(convert(Array{Uint8}, data), uint32(0))

    end

    module x64

        macro rotl64(var, value)
            :(($var << $value) | ($var >> $(64-value)))
        end

        macro fmix64(var)
            quote
              local value = $(var)
              value $= (value >> 33)
              value = uint64(value * uint64(0xff51afd7ed558ccd))
              value $= (value >> 33)
              value = uint64(value * uint64(0xc4ceb9fe1a85ec53))
              value $= (value >> 33)
              value
            end
        end

        function hash128(data::Array{Uint8}, seed::Uint64)

            c1 = uint64(0x87c37b91114253d5)
            c2 = uint64(0x4cf5ad432745937f)

            h1 = seed
            h2 = seed

            len = uint64(length(data))
            remainder = len & 15
            blocks = div(len, uint64(16))#uint64((len / uint64(16)))
            pointer = convert(Ptr{Uint64}, data)

            # Body
            iterations = uint64(blocks*2)
            for next_block::Uint64 = uint64(1):uint64(2):iterations
                k1 = unsafe_load(pointer, next_block)
                k2 = unsafe_load(pointer, next_block+1)

                k1 = uint64(k1 * c1)
                k1 = @rotl64(k1, 31)
                k1 = uint64(k1 * c2)
                h1 $= k1

                h1 = @rotl64(h1, 27)
                h1 = uint64(h1 + h2)
                h1 = uint64(h1 * 5 + 0x52dce729)

                k2 = uint64(k2 * c2)
                k2 = @rotl64(k2, 33)
                k2 = uint64(k2 * c1)
                h2 $= k2

                h2 = @rotl64(h2, 31)
                h2 = uint64(h2 + h1)
                h2 = uint64(h2 * 5 + 0x38495ab5)
            end

            # Tail
            last = blocks*16
            k1 = uint64(0)
            k2 = uint64(0)
            if remainder >= 15; k2 $= uint64(data[last+15]) << 48; end
            if remainder >= 14; k2 $= uint64(data[last+14]) << 40; end
            if remainder >= 13; k2 $= uint64(data[last+13]) << 32; end
            if remainder >= 12; k2 $= uint64(data[last+12]) << 24; end
            if remainder >= 11; k2 $= uint64(data[last+11]) << 16; end
            if remainder >= 10; k2 $= uint64(data[last+10]) << 8; end
            if remainder >=  9; k2 $= uint64(data[last+ 9]) << 0
                k2 = uint64(k2 * c2)
                k2 = @rotl64(k2, 33)
                k2 = uint64(k2 * c1)
                h2 $= k2
            end

            if remainder >= 8; k1 $= uint64(data[last+8]) << 56; end
            if remainder >= 7; k1 $= uint64(data[last+7]) << 48; end
            if remainder >= 6; k1 $= uint64(data[last+6]) << 40; end
            if remainder >= 5; k1 $= uint64(data[last+5]) << 32; end
            if remainder >= 4; k1 $= uint64(data[last+4]) << 24; end
            if remainder >= 3; k1 $= uint64(data[last+3]) << 16; end
            if remainder >= 2; k1 $= uint64(data[last+2]) << 8; end
            if remainder >= 1; k1 $= uint64(data[last+1]) << 0
                k1 = uint64(k1 * c1)
                k1 = @rotl64(k1, 31)
                k1 = uint64(k1 * c2)
                h1 $= k1
            end

            # Finalization
            h1 $= uint64(len)
            h2 $= uint64(len)
            h1 = uint64(h1 + h2)
            h2 = uint64(h2 + h1)
            h1 = @fmix64(h1)
            h2 = @fmix64(h2)
            h1 = uint64(h1 + h2)
            h2 = uint64(h2 + h1)

            h1 = @rotl64(h1, 32)
            h2 = @rotl64(h2, 32)

            return (uint128(h1) << 64) | uint128(h2)

        end

        hash128(data::Array{Uint8}, seed::Int) = hash128(data, uint64(seed))
        hash128(data::Array{Uint8}) = hash128(data, uint64(0))
        hash128(data::String, seed::Uint64) = hash128(convert(Array{Uint8}, data), seed)
        hash128(data::String, seed::Int) = hash128(convert(Array{Uint8}, data), uint64(seed))
        hash128(data::String) = hash128(convert(Array{Uint8}, data), uint64(0))

    end
    
end

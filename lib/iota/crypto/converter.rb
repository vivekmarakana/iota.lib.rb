module IOTA
  module Crypto
    class Converter
      RADIX = 3
      RADIX_BYTES = 256
      MAX_TRIT_VALUE = 1
      MIN_TRIT_VALUE = -1
      BYTE_HASH_LENGTH = 48
      HASH_LENGTH = Curl::HASH_LENGTH

      # All possible tryte values
      TRYTES_ALPHABET = "9ABCDEFGHIJKLMNOPQRSTUVWXYZ"

      TRYTE_TRITS = [
        [ 0,  0,  0],
        [ 1,  0,  0],
        [-1,  1,  0],
        [ 0,  1,  0],
        [ 1,  1,  0],
        [-1, -1,  1],
        [ 0, -1,  1],
        [ 1, -1,  1],
        [-1,  0,  1],
        [ 0,  0,  1],
        [ 1,  0,  1],
        [-1,  1,  1],
        [ 0,  1,  1],
        [ 1,  1,  1],
        [-1, -1, -1],
        [ 0, -1, -1],
        [ 1, -1, -1],
        [-1,  0, -1],
        [ 0,  0, -1],
        [ 1,  0, -1],
        [-1,  1, -1],
        [ 0,  1, -1],
        [ 1,  1, -1],
        [-1, -1,  0],
        [ 0, -1,  0],
        [ 1, -1,  0],
        [-1,  0,  0]
      ]

      class << self
        def trits(input, state = [])
          trits = state

          if input.is_a? Integer
            absoluteValue = input < 0 ? -input : input

            while absoluteValue > 0
              remainder = absoluteValue % 3
              absoluteValue = (absoluteValue / 3).floor

              if remainder > 1
                remainder = -1
                absoluteValue += 1
              end

              trits[trits.length] = remainder
            end

            if input < 0
              (0... trits.length).step(1) do |i|
                trits[i] = -trits[i]
              end
            end
          else
            (0... input.length).step(1) do |i|
              index = TRYTES_ALPHABET.index(input[i])
              tmp = i * 3
              trits[tmp...tmp+3] = TRYTE_TRITS[index]
            end
          end

          trits
        end

        def trytes(trits)
          trytes = ""

          (0...trits.length).step(3) do |i|
            chunk = trits[i...i+3]
            trytes += TRYTES_ALPHABET[TRYTE_TRITS.index(chunk)]
          end

          trytes
        end

        def value(trits)
          returnValue = 0

          range = (trits.length..0)

          range.first.downto(range.last).each do |i|
            returnValue = returnValue * 3 + trits[i].to_i
          end

          returnValue
        end

        def fromValue(value)
          destination = []
          absoluteValue = value < 0 ? -value : value
          i = 0

          while absoluteValue > 0
            remainder = absoluteValue % RADIX
            absoluteValue = (absoluteValue / RADIX).floor

            if remainder > MAX_TRIT_VALUE
              remainder = MIN_TRIT_VALUE
              absoluteValue += 1
            end
            destination[i] = remainder
            i += 1
          end

          if value < 0
            (0...destination.length).step(1) do |j|
              # switch values
              destination[j] = destination[j] == 0 ? 0 : -destination[j]
            end
          end

          destination
        end

        ### ADOPTED FROM PYTHON LIBRARY
        # Word to tryte & trytes to words conversion
        def convertToBytes(trits)
          bigInt = convertBaseToBigInt(trits, 3)
          bytes_k = convertBigIntToBytes(bigInt)
          bytes_k
        end

        def convertToTrits(bytes)
          bigInt = convertBytesToBigInt(bytes)
          trits = convertBigIntToBase(bigInt, 3, HASH_LENGTH)
          trits
        end

        # Convert between signed and unsigned bytes
        def convertSign(byte)
          if byte < 0
            return 256 + byte
          elsif byte > 127
            return -256 + byte
          end
          byte
        end

        def convertBaseToBigInt(array, base)
          bigint = 0
          (0...array.length).step(1) do |i|
            bigint += array[i] * (base ** i)
          end
          bigint
        end

        def convertBigIntToBase(bigInt, base, length)
          result = []

          isNegative = bigInt < 0
          quotient = bigInt.abs

          max, _ = (isNegative ? base : base-1).divmod(2)

          length.times do
            quotient, remainder = quotient.divmod(base)

            if remainder > max
              # Lend 1 to the next place so we can make this digit negative.
              quotient += 1
              remainder -= base
            end

            remainder = -remainder if isNegative

            result << remainder
          end

          result
        end

        def convertBigIntToBytes(big)
          bytesArrayTemp = []

          (0...48).step(1) do |pos|
            bytesArrayTemp << (big.abs >> pos * 8) % (1 << 8)
          end

          # big endian and balanced
          bytesArray = bytesArrayTemp.reverse.map { |x| x <= 0x7F ? x : x - 0x100 }

          if big < 0
            # 1-compliment
            bytesArray = bytesArray.map { |x| ~x }

            # add1
            (0...bytesArray.length).reverse_each do |pos|
              add = (bytesArray[pos] & 0xFF) + 1
              bytesArray[pos] = add <= 0x7F ? add : add - 0x100
              break if bytesArray[pos] != 0
            end
          end

          bytesArray
        end

        def convertBytesToBigInt(array)
          # copy of array
          bytesArray = array.map { |x| x }

          # number sign in MSB
          signum = bytesArray[0] >= 0 ? 1 : -1

          if signum == -1
            # sub1
            (0...bytesArray.length).reverse_each do |pos|
              sub = (bytesArray[pos] & 0xFF) - 1
              bytesArray[pos] = sub <= 0x7F ? sub : sub - 0x100
              break if bytesArray[pos] != -1
            end

            # 1-compliment
            bytesArray = bytesArray.map { |x| ~x }
          end

          # sum magnitudes and set sign
          sum = 0
          bytesArray.reverse.each_with_index do |v, pos|
            sum += (v & 0xFF) << pos * 8
          end

          sum * signum
        end
      end
    end
  end
end

module IOTA
  module Utils
    module Ascii
      TRYTE_VALUES = "9ABCDEFGHIJKLMNOPQRSTUVWXYZ"

      def toTrytes(input)
        # If input is not a string, return nil
        return nil if !@validator.isString(input)
        trytes = ""

        (0...input.length).step(1) do |i|
          char = input[i]
          asciiValue = char.bytes.sum

          # If not recognizable ASCII character, return null
          return nil if asciiValue > 255

          firstValue = asciiValue % 27
          secondValue = (asciiValue - firstValue) / 27

          trytesValue = TRYTE_VALUES[firstValue] + TRYTE_VALUES[secondValue]

          trytes += trytesValue
        end

        trytes
      end

      def fromTrytes(input)
        # If input is invalid trytes or input length is odd
        return nil if !@validator.isTrytes(input) || input.length % 2 != 0

        outputString = ""

        (0...input.length).step(2) do |i|
          trytes = input[i] + input[i + 1]

          firstValue = TRYTE_VALUES.index(trytes[0])
          secondValue = TRYTE_VALUES.index(trytes[1])

          decimalValue = firstValue + secondValue * 27

          outputString += decimalValue.chr
        end

        outputString
      end
    end
  end
end

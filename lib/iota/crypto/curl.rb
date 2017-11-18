module IOTA
  module Crypto
    class Curl
      NUMBER_OF_ROUNDS = 81
      HASH_LENGTH = 243
      STATE_LENGTH = 3 * HASH_LENGTH

      def initialize(rounds = nil)
        @rounds = rounds || NUMBER_OF_ROUNDS
        @truthTable = [1, 0, -1, 2, 1, -1, 0, 2, -1, 1, 0]
      end

      def setup(state = nil)
        if state
          @state = state
        else
          @state = []
          STATE_LENGTH.times {|a| @state << 0}
        end
      end

      def reset
        setup
      end

      def absorb(trits, offset, length)
        loop do
          i = 0
          limit = length < HASH_LENGTH ? length : HASH_LENGTH

          while i < limit
            @state[i] = trits[offset]
            i += 1
            offset += 1
          end

          transform
          length -= HASH_LENGTH

          break if length <= 0
        end
      end

      def squeeze(trits, offset, length)
        loop do
          i = 0
          limit = length < HASH_LENGTH ? length : HASH_LENGTH
          while i < limit
            trits[offset] = @state[i]
            i += 1
            offset += 1
          end

          transform
          length -= HASH_LENGTH

          break if length <= 0
        end
      end

      def transform
        stateCopy = []
        index = 0

        (0...@rounds).step(1) do |_|
          stateCopy = @state.slice(0, @state.length)
          (0...STATE_LENGTH).step(1) do |i|
            @state[i] = @truthTable[stateCopy[index].to_i + (stateCopy[index += (index < 365 ? 364 : -365)].to_i << 2) + 5]
          end
        end
      end
    end
  end
end

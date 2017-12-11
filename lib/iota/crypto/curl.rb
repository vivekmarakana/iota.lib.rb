module IOTA
  module Crypto
    class Curl
      NUMBER_OF_ROUNDS = 81
      HASH_LENGTH = 243
      STATE_LENGTH = 3 * HASH_LENGTH
      TRUTH_TABLE = [1, 0, -1, 1, -1, 0, -1, 1, 0]

      def initialize(rounds = nil)
        @rounds = rounds || NUMBER_OF_ROUNDS
        reset
      end

      def reset
        @state = [0] * STATE_LENGTH
      end

      def absorb(trits)
        length  = trits.length
        offset  = 0

        while offset < length
          start = offset
          stop  = [start + HASH_LENGTH, length].min

          @state[0...stop-start] = trits.slice(start, stop-start)
          transform

          offset += HASH_LENGTH
        end
      end

      def squeeze(trits)
        trits[0...HASH_LENGTH] = @state.slice(0, HASH_LENGTH)
        transform
      end

      def transform
        previousState  = @state.slice(0, @state.length)
        newState   = @state.slice(0, @state.length)

        index = 0
        round = 0
        while round < @rounds
          previousTrit = previousState[index].to_i

          pos = 0
          while true
            index += (index < 365) ? 364 : -365
            newTrit = previousState[index].to_i
            newState[pos] = TRUTH_TABLE[previousTrit + (3 * newTrit) + 4]
            previousTrit = newTrit
            pos += 1
            break if pos >= STATE_LENGTH
          end

          previousState = newState
          newState = newState.slice(0, newState.length)
          round += 1
        end

        @state = newState
      end
    end
  end
end

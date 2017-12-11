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
        s = Time.now
        length  = trits.length
        offset  = 0

        while offset < length
          start = offset
          stop  = [start + HASH_LENGTH, length].min

          @state[0...stop-start] = trits.slice(start, stop-start)
          transform

          offset += HASH_LENGTH
        end
        puts "**absorb: #{(Time.now - s) * 1000.0}ms"
      end

      def squeeze(trits)
        start = Time.now
        trits[0...HASH_LENGTH] = @state.slice(0, HASH_LENGTH)
        transform
        puts "**squeeze: #{(Time.now - start) * 1000.0}ms"
      end

      def transform
        previousState  = @state.slice(0, @state.length)
        newState   = @state.slice(0, @state.length)

        # Note: This code looks significantly different from the C
        # implementation because it has been optimized to limit the number
        # of list item lookups (these are relatively slow in Python).
        index = 0
        round = 0
        while round < @rounds
          previousTrit = previousState[index].to_i

          a = Time.now
          # (0...STATE_LENGTH).each do |pos|
          pos = 0
          while true
            index += (index < 365) ? 364 : -365
            newTrit = previousState[index].to_i
            newState[pos] = TRUTH_TABLE[previousTrit + (3 * newTrit) + 4]
            previousTrit = newTrit
            pos += 1
            break if pos >= STATE_LENGTH
          end
          # puts "loop took: #{(Time.now - a) * 1000.0}ms"

          previousState = newState
          newState = newState.slice(0, newState.length)
          round += 1
        end

        @state = newState
      end
    end
  end
end

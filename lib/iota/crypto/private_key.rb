module IOTA
  module Crypto
    class PrivateKey
      HASH_LENGTH = Kerl::HASH_LENGTH

      attr_reader :key

      def initialize(seed, index, security)
        key = []
        offset = 0
        buffer = []

        (0...index).step(1) do |i|
          # Treat ``seed`` like a really big number and add ``index``.
          # Note that addition works a little bit differently in balanced ternary.
          (0...seed.length).step(1) do |j|
            seed[j] += 1

            if seed[j] > 1
              seed[j] = -1
            else
              break
            end
          end
        end

        kerl = Kerl.new
        kerl.absorb(seed, 0, seed.length)
        kerl.squeeze(seed, 0, seed.length)
        kerl.reset
        kerl.absorb(seed, 0, seed.length)

        security.times do
          (0...27).step(1) do |i|
            kerl.squeeze(buffer, 0, seed.length)
            (0...HASH_LENGTH).step(1) do |j|
              key[offset] = buffer[j]
              offset += 1
            end
          end
        end

        @key = key
      end

      def digests
        digestsArray = []
        buffer = []

        (0...(@key.length / 6561).floor).step(1) do |i|
          keyFragment = @key.slice(i * 6561, 6561)

          (0...27).step(1) do |j|
            buffer = keyFragment.slice(j * HASH_LENGTH, HASH_LENGTH);

            (0...26).step(1) do |k|
              kKerl = Kerl.new
              kKerl.absorb(buffer, 0, buffer.length)
              kKerl.squeeze(buffer, 0, HASH_LENGTH)
            end

            (0...HASH_LENGTH).step(1) do |k|
              keyFragment[j * HASH_LENGTH + k] = buffer[k]
            end
          end

          kerl = Kerl.new
          kerl.absorb(keyFragment, 0, keyFragment.length)
          kerl.squeeze(buffer, 0, HASH_LENGTH)

          (0...HASH_LENGTH).step(1) do |j|
            digestsArray[i * HASH_LENGTH + j] = buffer[j];
          end
        end

        digestsArray
      end
    end
  end
end

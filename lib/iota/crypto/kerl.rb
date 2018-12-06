module IOTA
  module Crypto
    class Kerl
      BIT_HASH_LENGTH = 384
      HASH_LENGTH = Curl::HASH_LENGTH

      def initialize
        reset
      end

      def reset
        unless RUBY_PLATFORM =~ /java/
          require 'digest/sha3'
          @hasher = Digest::SHA3.new(BIT_HASH_LENGTH)
        else
          require "iota/crypto/sha3_ruby"
          @hasher = Digest::RubySHA3.new(BIT_HASH_LENGTH)
        end
      end

      def absorb(trits, offset = 0, length = nil)
        pad = trits.length % HASH_LENGTH != 0 ? trits.length % HASH_LENGTH : HASH_LENGTH
        trits.concat([0] * (HASH_LENGTH - pad))

        length = trits.length if length.nil?

        if length % HASH_LENGTH != 0 || length == 0
          raise StandardError,  "Illegal length provided"
        end

        while offset < length
          limit = [offset + HASH_LENGTH, length].min

          # If we're copying over a full chunk, zero last trit
          trits[limit - 1] = 0 if limit - offset == HASH_LENGTH

          signed_bytes = Converter.convertToBytes(trits[offset...limit])

          # Convert signed bytes into their equivalent unsigned representation
          # In order to use Python's built-in bytes type
          unsigned_bytes = signed_bytes.map{ |b| Converter.convertSign(b) }.pack('c*').force_encoding('UTF-8')

          @hasher.update(unsigned_bytes)

          offset += HASH_LENGTH
        end
      end

      def squeeze(trits, offset = 0, length = nil)
        pad = trits.length % HASH_LENGTH != 0 ? trits.length % HASH_LENGTH : HASH_LENGTH
        trits.concat([0] * (HASH_LENGTH - pad))

        length = trits.length > 0 ? trits.length : HASH_LENGTH if length.nil?

        if length % HASH_LENGTH != 0 || length == 0
          raise StandardError,  "Illegal length provided"
        end

        while offset < length
          unsigned_hash =  @hasher.digest

          signed_hash = unsigned_hash.bytes.map { |b| Converter.convertSign(b) }

          trits_from_hash = Converter.convertToTrits(signed_hash)
          trits_from_hash[HASH_LENGTH - 1] = 0

          limit = [HASH_LENGTH, length - offset].min

          trits[offset...offset+limit] = trits_from_hash[0...limit]

          flipped_bytes = unsigned_hash.bytes.map{ |b| Converter.convertSign(~b)}.pack('c*').force_encoding('UTF-8')

          # Reset internal state before feeding back in
          reset
          @hasher.update(flipped_bytes)

          offset += HASH_LENGTH
        end
      end
    end
  end
end

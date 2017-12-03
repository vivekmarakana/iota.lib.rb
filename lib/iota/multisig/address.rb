module IOTA
  module Multisig
    class Address
      def initialize(digests = nil)
        # Initialize kerl instance
        @kerl = IOTA::Crypto::Kerl.new

        # Add digests if passed
        absorb(digests) if digests
      end

      def absorb(digest)
        # Construct array
        digests = digest.class == Array ? digest : [digest]

        # Add digests
        digests.each do |d|
          # Get trits of digest
          digestTrits = IOTA::Crypto::Converter.trits(d)

          # Absorb
          @kerl.absorb(digestTrits, 0, digestTrits.length)
        end

        self
      end

      def finalize(digest = nil)
        # Absorb last digest if passed
        absorb(digest) if digest

        # Squeeze the address trits
        addressTrits = []
        @kerl.squeeze(addressTrits, 0, IOTA::Crypto::Kerl::HASH_LENGTH)

        # Convert trits into trytes and return the address
        IOTA::Crypto::Converter.trytes(addressTrits)
      end
    end
  end
end

module IOTA
  module Models
    class Seed < Base
      def initialize(seed)
        @utils = IOTA::Utils::Utils.new

        # Check if correct seed
        if seed.class == String && !@utils.validator.isTrytes(seed)
          raise StandardError, "Invalid seed provided"
        end

        seed += "9" * (81 - seed.length) if seed.length < 81

        @seed = seed
      end

      def getAddress(index, security, checksum)
        pk = IOTA::Crypto::PrivateKey.new(self.as_trits, index, security)
        address_trits = IOTA::Crypto::Signing.address(pk.digests)
        address = IOTA::Crypto::Converter.trytes(address_trits)

        address = @utils.addChecksum(address) if checksum

        address
      end

      # Converter methods
      def as_trits
        IOTA::Crypto::Converter.trits(@seed)
      end
    end
  end
end

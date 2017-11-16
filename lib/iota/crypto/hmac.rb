module IOTA
  module Crypto
    class Hmac
      ROUNDS = 27

      def initialize(key)
        @key = Converter.trits(key)
      end

      def addHMAC(bundle)
        curl = Curl.new(ROUNDS)
        (0...bundle.bundle.length).step(1) do |i|
          if bundle.bundle[i].value > 0
            bundleHashTrits = Converter.trits(bundle.bundle[i].bundle)
            hmac = Array.new(243, 0)
            curl.reset
            curl.absorb(@key)
            curl.absorb(bundleHashTrits)
            curl.squeeze(hmac)
            hmacTrytes = Converter.trytes(hmac)
            bundle.bundle[i].signatureMessageFragment = hmacTrytes + bundle.bundle[i].signatureMessageFragment[81...2187]
          end
        end
      end
    end
  end
end

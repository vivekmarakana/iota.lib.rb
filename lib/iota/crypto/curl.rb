if RUBY_PLATFORM =~ /java/
  require "iota/crypto/curl_java"
  BaseCurl = IOTA::Crypto::JCurl
else
  require "iota/crypto/curl_c"
  BaseCurl = IOTA::Crypto::CCurl
end

module IOTA
  module Crypto
    class Curl < BaseCurl
      def initialize(rounds = nil)
        rounds ||= NUMBER_OF_ROUNDS
        super(rounds)
      end
    end
  end
end

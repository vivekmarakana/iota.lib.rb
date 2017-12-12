if File.file?(File.join(File.dirname(__FILE__), 'ccurl.bundle'))
  require "iota/crypto/curl_c"
  BaseCurl = IOTA::Crypto::CCurl
else
  require "iota/crypto/curl_ruby"
  BaseCurl = IOTA::Crypto::RubyCurl
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

module IOTA
  module Crypto
    class JCurl
      NUMBER_OF_ROUNDS = 81
      HASH_LENGTH = 243
      STATE_LENGTH = 3 * HASH_LENGTH

      if RUBY_PLATFORM =~ /java/
        require 'jcurl'
        com.vmarakana.JCurlService.new.basicLoad(JRuby.runtime)
      end

      def version
        "Java"
      end
    end
  end
end

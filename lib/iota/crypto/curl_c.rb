module IOTA
  module Crypto
    class CCurl
      NUMBER_OF_ROUNDS = 81
      HASH_LENGTH = 243
      STATE_LENGTH = 3 * HASH_LENGTH

      unless RUBY_PLATFORM =~ /java/
        require "ccurl"
      end

      def version
        "C"
      end
    end
  end
end

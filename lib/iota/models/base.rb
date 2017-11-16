module IOTA
  module Models
    class Base
      def inspect
        self.to_s
      end

      def symbolize_keys(hash)
        hash.inject({}){ |h,(k,v)| h[k.to_sym] = v; h }
      end
    end
  end
end

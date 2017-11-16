module IOTA
  module Utils
    class ObjectValidator
      def initialize(keysToValidate)
        @validator = InputValidator.new
        @keysToValidate = keysToValidate
      end

      def valid?(object)
        valid = true
        @keysToValidate.each do |keyToValidate|
          key = keyToValidate[:key]
          func = keyToValidate[:validator]
          args = keyToValidate[:args]

          # If input does not have keyIndex and address, return false
          if !object.respond_to?(key)
            valid = false
            break
          end

          # If input function does not return true, exit
          method_args = [object.send(key)]
          method_args << args if !args.nil?
          if !@validator.method(func).call(*method_args)
            valid = false
            break
          end
        end
        valid
      end
    end
  end
end

module IOTA
  module Models
    class Transfer < Base
      attr_accessor :address, :message, :obsoleteTag, :value, :hmacKey

      def initialize(options)
        @utils = IOTA::Utils::Utils.new

        options = symbolize_keys(options)
        @address = options[:address] || nil
        if @address.nil?
          raise StandardError, "address not provided for transfer"
        end

        if @address.length == 90 && !@utils.isValidChecksum(@address)
          raise StandardError, "Invalid checksum: #{thisTransfer[:address]}"
        end

        @address = @utils.noChecksum(@address)

        @message = options[:message] || ''
        @obsoleteTag = options[:tag] || options[:obsoleteTag] || ''
        @value = options[:value]
        @hmacKey = options[:hmacKey] || nil

        if @hmacKey
          @message = ('9'*244) + @message
        end
      end

      def valid?
        keysToValidate = [
          { key: 'address', validator: :isAddress, args: nil },
          { key: 'value', validator: :isValue, args: nil },
          { key: 'message', validator: :isTrytes, args: nil },
          { key: 'obsoleteTag', validator: :isTrytes, args: '0,27' }
        ]

        validator = IOTA::Utils::ObjectValidator.new(keysToValidate)
        validator.valid?(self)
      end
    end
  end
end

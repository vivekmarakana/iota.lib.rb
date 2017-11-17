module IOTA
  module Models
    class Input < Base
      attr_accessor :address, :keyIndex, :security, :balance

      def initialize(options)
        utils = IOTA::Utils::Utils.new
        options = symbolize_keys(options)

        @address = options[:address] || nil
        if @address.nil?
          raise StandardError, "address not provided for transfer"
        end

        if @address.length == 90 && !utils.isValidChecksum(@address)
          raise StandardError, "Invalid checksum: #{thisTransfer[:address]}"
        end

        @address = utils.noChecksum(@address) if @address.length == 90

        @keyIndex = options[:keyIndex]
        @security = options[:security]
        @balance = options[:balance]
      end

      def valid?
        keysToValidate = [
          { key: 'address', validator: :isAddress, args: nil },
          { key: 'security', validator: :isValue, args: nil },
          { key: 'keyIndex', validator: :isValue, args: nil }
        ]

        validator = IOTA::Utils::ObjectValidator.new(keysToValidate)
        validator.valid?(self)
      end
    end
  end
end

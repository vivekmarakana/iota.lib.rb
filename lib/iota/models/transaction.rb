module IOTA
  module Models
    class Transaction < Base
      attr_accessor :hash, :signatureMessageFragment, :address, :value, :obsoleteTag, :timestamp, :currentIndex, :lastIndex, :bundle, :trunkTransaction, :branchTransaction, :tag, :attachmentTimestamp, :attachmentTimestampLowerBound, :attachmentTimestampUpperBound, :nonce, :persistence

      def initialize(options)
        options = symbolize_keys(options)
        @hash = options[:hash]
        @signatureMessageFragment = options[:signatureMessageFragment]
        @address = options[:address]
        @value = options[:value]
        @obsoleteTag = options[:obsoleteTag]
        @timestamp = options[:timestamp]
        @currentIndex = options[:currentIndex]
        @lastIndex = options[:lastIndex]
        @bundle = options[:bundle]
        @trunkTransaction = options[:trunkTransaction]
        @branchTransaction = options[:branchTransaction]
        @tag = options[:tag]
        @attachmentTimestamp = options[:attachmentTimestamp]
        @attachmentTimestampLowerBound = options[:attachmentTimestampLowerBound]
        @attachmentTimestampUpperBound = options[:attachmentTimestampUpperBound]
        @nonce = options[:nonce]
        @persistence = nil
      end

      def valid?
        keysToValidate = [
          { key: 'hash', validator: :isHash, args: nil},
          { key: 'signatureMessageFragment', validator: :isTrytes, args: 2187 },
          { key: 'address', validator: :isHash, args: nil },
          { key: 'value', validator: :isValue, args: nil },
          { key: 'obsoleteTag', validator: :isTrytes, args: 27 },
          { key: 'timestamp', validator: :isValue, args: nil },
          { key: 'currentIndex', validator: :isValue, args: nil },
          { key: 'lastIndex', validator: :isValue, args: nil },
          { key: 'bundle', validator: :isHash, args: nil },
          { key: 'trunkTransaction', validator: :isHash, args: nil },
          { key: 'branchTransaction', validator: :isHash, args: nil },
          { key: 'tag', validator: :isTrytes, args: 27 },
          { key: 'attachmentTimestamp', validator: :isValue, args: nil },
          { key: 'attachmentTimestampLowerBound', validator: :isValue, args: nil },
          { key: 'attachmentTimestampUpperBound', validator: :isValue, args: nil },
          { key: 'nonce', validator: :isTrytes, args: 27 }
        ]

        validator = IOTA::Utils::ObjectValidator.new(keysToValidate)
        validator.valid?(self)
      end
    end
  end
end

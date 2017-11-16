module IOTA
  module Utils
    class InputValidator
      def isAllNine(input)
        /^[9]+$/.match?(input)
      end

      def isValue(input)
        input && input.is_a?(Integer)
      end

      def isNum(input)
        /^(\d+\.?\d{0,15}|\.\d{0,15})$/.match?(input.to_s)
      end

      def isString(input)
        input.class == String
      end

      def isArray(input)
        input.class == Array
      end

      def isObject(input)
        input.class == Hash
      end

      def isHash(input)
        isTrytes(input, 81)
      end

      def isAddress(input)
        if input.length == 90
          if !isTrytes(input, 90)
            return false
          end
        else
          if !isTrytes(input, 81)
            return false
          end
        end

        true
      end

      def isTrytes(input, length = "0,")
        isString(input) && /^[9A-Z]{#{length}}$/.match?(input)
      end

      def isArrayOfTrytes(trytesArray)
        return false if !isArray(trytesArray)

        trytesArray.each do |tryte|
          return false if !isTrytes(tryte, 2673)
        end

        true
      end

      def isArrayOfHashes(input)
        return false if !isArray(input)

        input.each do |entry|
          return false if !isAddress(entry)
        end

        true
      end

      def isArrayOfAttachedTrytes(trytes)
        return false if !isArray(trytes)

        (0...trytes.length).step(1) do |i|
          tryte = trytes[i]
          return false if !isTrytes(tryte, 2673)

          lastTrytes = tryte.slice(2673 - (3 * 81), trytes.length)
          return false if isAllNine(lastTrytes)
        end

        true
      end

      def isArrayOfTxObjects(bundle)
        bundle = bundle.transactions if bundle.class == IOTA::Models::Bundle

        return false if !isArray(bundle) || bundle.length == 0

        bundle.each do |txObject|
          if txObject.class != IOTA::Models::Transaction
            txObject = IOTA::Models::Transaction.new(txObject)
          end

          return false if !txObject.valid?
        end

        true
      end

      def isTransfersArray(transfersArray)
        return false if !isArray(transfersArray)

        transfersArray.each do |transfer|
          if transfer.class != IOTA::Models::Transfer
            transfer = IOTA::Models::Transfer.new(transfer)
          end

          return false if !transfer.valid?
        end

        true
      end

      def isInputs(inputs)
        return false if !isArray(inputs)

        inputs.each do |input|
          if input.class != IOTA::Models::Input
            input = IOTA::Models::Input.new(input)
          end

          return false if !input.valid?
        end

        true
      end

      # Checks that a given uri is valid
      # Valid Examples:
      # udp://[2001:db8:a0b:12f0::1]:14265
      # udp://[2001:db8:a0b:12f0::1]
      # udp://8.8.8.8:14265
      # udp://domain.com
      # udp://domain2.com:14265
      def isUri(node)
        getInside = /^(udp|tcp):\/\/([\[][^\]\.]*[\]]|[^\[\]:]*)[:]{0,1}([0-9]{1,}$|$)/i

        stripBrackets = /[\[]{0,1}([^\[\]]*)[\]]{0,1}/

        uriTest = /((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))|(^\s*((?=.{1,255}$)(?=.*[A-Za-z].*)[0-9A-Za-z](?:(?:[0-9A-Za-z]|\b-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|\b-){0,61}[0-9A-Za-z])?)*)\s*$)/

        match = getInside.match(node)
        return false if match.nil? || match[2].nil?

        uriTest.match?(stripBrackets.match(match[2])[1])
      end
    end
  end
end

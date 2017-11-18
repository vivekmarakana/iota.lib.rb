module IOTA
  module Models
    class Bundle < Base
      attr_reader :transactions, :persistence, :attachmentTimestamp

      def initialize(transactions)
        if transactions.class != Array
          raise StandardError, "Invalid transactions array"
        end

        @transactions = []
        transactions.each do |trx|
          trx = Transaction.new(trx) if trx.class != IOTA::Models::Transaction
          @transactions << trx
        end

        @persistence = @transactions.first.persistence
        @attachmentTimestamp = @transactions.first.attachmentTimestamp
      end

      def extractJSON
        utils = IOTA::Utils::Utils.new

        # Sanity check: if the first tryte pair is not opening bracket, it's not a message
        firstTrytePair = transactions[0].signatureMessageFragment[0] + transactions[0].signatureMessageFragment[1]

        return nil if firstTrytePair != "OD"

        index = 0
        notEnded = true
        trytesChunk = ''
        trytesChecked = 0
        preliminaryStop = false
        finalJson = ''

        while index < transactions.length && notEnded
          messageChunk = transactions[index].signatureMessageFragment

          # We iterate over the message chunk, reading 9 trytes at a time
          (0...messageChunk.length).step(9) do |i|
            # get 9 trytes
            trytes = messageChunk.slice(i, 9)
            trytesChunk += trytes

            # Get the upper limit of the tytes that need to be checked
            # because we only check 2 trytes at a time, there is sometimes a leftover
            upperLimit = trytesChunk.length - trytesChunk.length % 2

            trytesToCheck = trytesChunk[trytesChecked...upperLimit]

            # We read 2 trytes at a time and check if it equals the closing bracket character
            (0...trytesToCheck.length).step(2) do |j|
              trytePair = trytesToCheck[j] + trytesToCheck[j + 1]

              # If closing bracket char was found, and there are only trailing 9's
              # we quit and remove the 9's from the trytesChunk.
              if preliminaryStop && trytePair == '99'
                notEnded = false
                break
              end

              finalJson += utils.fromTrytes(trytePair)

              # If tryte pair equals closing bracket char, we set a preliminary stop
              # the preliminaryStop is useful when we have a nested JSON object
              if trytePair === "QD"
                preliminaryStop = true
              end
            end

            break if !notEnded

            trytesChecked += trytesToCheck.length;
          end

          # If we have not reached the end of the message yet, we continue with the next transaction in the bundle
          index += 1
        end

        # If we did not find any JSON, return nil
        return nil if notEnded

        finalJson
      end
    end
  end
end

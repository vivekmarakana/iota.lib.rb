module IOTA
  module Crypto
    class Bundle
      attr_reader :bundle

      def initialize
        @bundle = []
      end

      def addEntry(signatureMessageLength, address, value, tag, timestamp)
        (0...signatureMessageLength).step(1) do |i|
          transactionObject = IOTA::Models::Transaction.new(
            address: address,
            value: i==0 ? value : 0,
            obsoleteTag: tag,
            tag: tag,
            timestamp: timestamp
          )

          @bundle << transactionObject
        end
      end

      def addTrytes(signatureFragments)
        emptySignatureFragment = ''
        emptyHash = '9' * 81
        emptyTag = '9' * 27
        emptyTimestamp = '9' * 9

        while emptySignatureFragment.length < 2187
          emptySignatureFragment += '9'
        end

        (0...@bundle.length).step(1) do |i|
          # Fill empty signatureMessageFragment
          @bundle[i].signatureMessageFragment = signatureFragments[i] ? signatureFragments[i] : emptySignatureFragment

          # Fill empty trunkTransaction
          @bundle[i].trunkTransaction = emptyHash

          # Fill empty branchTransaction
          @bundle[i].branchTransaction = emptyHash

          @bundle[i].attachmentTimestamp = emptyTimestamp
          @bundle[i].attachmentTimestampLowerBound = emptyTimestamp
          @bundle[i].attachmentTimestampUpperBound = emptyTimestamp

          # Fill empty nonce
          @bundle[i].nonce = emptyTag
        end
      end

      def finalize
        validBundle = false

        while !validBundle

          kerl = Kerl.new

          (0...@bundle.length).step(1) do |i|
            valueTrits = Converter.trits(@bundle[i].value)
            while valueTrits.length < 81
              valueTrits << 0
            end

            timestampTrits = Converter.trits(@bundle[i].timestamp)
            while timestampTrits.length < 27
              timestampTrits << 0
            end

            @bundle[i].currentIndex = i
            currentIndexTrits = Converter.trits(@bundle[i].currentIndex)
            while currentIndexTrits.length < 27
              currentIndexTrits << 0
            end

            @bundle[i].lastIndex = @bundle.length - 1
            lastIndexTrits = Converter.trits(@bundle[i].lastIndex)
            while lastIndexTrits.length < 27
              lastIndexTrits << 0
            end

            bundleEssence = Converter.trits(@bundle[i].address + Converter.trytes(valueTrits) + @bundle[i].obsoleteTag + Converter.trytes(timestampTrits) + Converter.trytes(currentIndexTrits) + Converter.trytes(lastIndexTrits))
            kerl.absorb(bundleEssence, 0, bundleEssence.length)
          end

          hash = []
          kerl.squeeze(hash, 0, Kerl::HASH_LENGTH)
          hash = Converter.trytes(hash)

          (0...@bundle.length).step(1) do |i|
            @bundle[i].bundle = hash
          end

          normalizedHash = normalizedBundle(hash)
          if !normalizedHash.index(13).nil?
            # Insecure bundle. Increment Tag and recompute bundle hash.
            increasedTagTrits = Converter.trits(@bundle[0].obsoleteTag)

            # Adder implementation with 1 round
            (0...increasedTagTrits.length).step(1) do |j|
              increasedTagTrits[j] += 1

              if increasedTagTrits[j] > 1
                increasedTagTrits[j] = -1
              else
                break
              end
            end

            @bundle[0].obsoleteTag = Converter.trytes(increasedTagTrits)
          else
            validBundle = true
          end
        end
      end

      def normalizedBundle(bundleHash)
        normalizedBundleArr = []

        (0...3).step(1) do |i|
          sum = 0
          (0...27).step(1) do |j|
            normalizedBundleArr[i * 27 + j] = Converter.value(Converter.trits(bundleHash[i * 27 + j]))
            sum += normalizedBundleArr[i * 27 + j]
          end

          if sum >= 0
            while sum > 0
              sum -= 1
              (0...27).step(1) do |j|
                if normalizedBundleArr[i * 27 + j] > -13
                  normalizedBundleArr[i * 27 + j] -= 1
                  break
                end
              end
            end
          else
            while sum < 0
              sum += 1
              (0...27).step(1) do |j|
                if normalizedBundleArr[i * 27 + j] < 13
                  normalizedBundleArr[i * 27 + j] += 1
                  break
                end
              end
            end
          end
        end

        normalizedBundleArr
      end
    end
  end
end

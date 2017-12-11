require 'bigdecimal'

module IOTA
  module Utils
    class Utils
      include Ascii

      attr_reader :validator

      UNIT_MAP = {
        'i'  => 1,
        'Ki' => 1_000,
        'Mi' => 1_000_000,
        'Gi' => 1_000_000_000,
        'Ti' => 1_000_000_000_000,
        'Pi' => 1_000_000_000_000_000
      }

      UNIT_MAP_ORDER = ['Pi', 'Ti', 'Gi', 'Mi', 'Ki', 'i']

      def initialize
        @validator = InputValidator.new
      end

      def convertUnits(value, fromUnit, toUnit)
        # Check if wrong unit provided
        if !UNIT_MAP[fromUnit] || !UNIT_MAP[toUnit]
          raise ArgumentError, "Invalid unit provided"
        end

        # If not valid value, throw error
        if !@validator.isNum(value)
          raise ArgumentError, "Invalid value"
        end

        converted = (BigDecimal(value.to_s) * UNIT_MAP[fromUnit]) / UNIT_MAP[toUnit]
        converted.to_f
      end

      def noChecksum(address)
        isSingleAddress = @validator.isString(address)

        return address if isSingleAddress && address.length == 81

        # If only single address, turn it into an array
        if isSingleAddress
          address = [address]
        end

        addressesWithChecksum = []

        address.each do |addr|
          addressesWithChecksum << addr.slice(0, 81)
        end

        # return either string or the list
        if isSingleAddress
            return addressesWithChecksum.first
        else
            return addressesWithChecksum
        end
      end

      def transactionObject(trytes)
        start = Time.now
        return if !trytes

        # validity check
        (2279...2295).step(1) do |i|
          raise ArgumentError, "Invalid trytes provided" if trytes[i] != "9"
        end

        trx = {}
        transactionTrits = IOTA::Crypto::Converter.trits(trytes)
        hash = []

        # generate the correct transaction hash
        curl = IOTA::Crypto::Curl.new
        curl.absorb(transactionTrits)
        curl.squeeze(hash)
        puts "Took: #{(Time.now - start) * 1000.0}ms"

        trx['hash'] = IOTA::Crypto::Converter.trytes(hash)
        trx['signatureMessageFragment'] = trytes.slice(0, 2187)
        trx['address'] = trytes.slice(2187, 81)
        trx['value'] = IOTA::Crypto::Converter.value(transactionTrits.slice(6804, 33))
        trx['obsoleteTag'] = trytes.slice(2295, 27)
        trx['timestamp'] = IOTA::Crypto::Converter.value(transactionTrits.slice(6966, 27))
        trx['currentIndex'] = IOTA::Crypto::Converter.value(transactionTrits.slice(6993, 27))
        trx['lastIndex'] = IOTA::Crypto::Converter.value(transactionTrits.slice(7020, 27))
        trx['bundle'] = trytes.slice(2349, 81)
        trx['trunkTransaction'] = trytes.slice(2430, 81)
        trx['branchTransaction'] = trytes.slice(2511, 81)

        trx['tag'] = trytes.slice(2592, 27)
        trx['attachmentTimestamp'] = IOTA::Crypto::Converter.value(transactionTrits.slice(7857, 27))
        trx['attachmentTimestampLowerBound'] = IOTA::Crypto::Converter.value(transactionTrits.slice(7884, 27))
        trx['attachmentTimestampUpperBound'] = IOTA::Crypto::Converter.value(transactionTrits.slice(7911, 27))
        trx['nonce'] = trytes.slice(2646, 27)

        IOTA::Models::Transaction.new(trx)
      end

      def transactionTrytes(transaction)
        valueTrits = IOTA::Crypto::Converter.trits(transaction.value)
        valueTrits = valueTrits.concat([0]*(81-valueTrits.length)) if valueTrits.length < 81

        timestampTrits = IOTA::Crypto::Converter.trits(transaction.timestamp)
        timestampTrits = timestampTrits.concat([0]*(27-timestampTrits.length)) if timestampTrits.length < 27

        currentIndexTrits = IOTA::Crypto::Converter.trits(transaction.currentIndex)
        currentIndexTrits = currentIndexTrits.concat([0]*(27-currentIndexTrits.length)) if currentIndexTrits.length < 27

        lastIndexTrits = IOTA::Crypto::Converter.trits(transaction.lastIndex)
        lastIndexTrits = lastIndexTrits.concat([0]*(27-lastIndexTrits.length)) if lastIndexTrits.length < 27

        attachmentTimestampTrits = IOTA::Crypto::Converter.trits(transaction.attachmentTimestamp || 0);
        attachmentTimestampTrits = attachmentTimestampTrits.concat([0]*(27-attachmentTimestampTrits.length)) if attachmentTimestampTrits.length < 27

        attachmentTimestampLowerBoundTrits = IOTA::Crypto::Converter.trits(transaction.attachmentTimestampLowerBound || 0);
        attachmentTimestampLowerBoundTrits = attachmentTimestampLowerBoundTrits.concat([0]*(27-attachmentTimestampLowerBoundTrits.length)) if attachmentTimestampLowerBoundTrits.length < 27

        attachmentTimestampUpperBoundTrits = IOTA::Crypto::Converter.trits(transaction.attachmentTimestampUpperBound || 0);
        attachmentTimestampUpperBoundTrits = attachmentTimestampUpperBoundTrits.concat([0]*(27-attachmentTimestampUpperBoundTrits.length)) if attachmentTimestampUpperBoundTrits.length < 27

        tag = transaction.tag || transaction.obsoleteTag

        return (
          transaction.signatureMessageFragment +
          transaction.address +
          IOTA::Crypto::Converter.trytes(valueTrits) +
          transaction.obsoleteTag +
          IOTA::Crypto::Converter.trytes(timestampTrits) +
          IOTA::Crypto::Converter.trytes(currentIndexTrits) +
          IOTA::Crypto::Converter.trytes(lastIndexTrits) +
          transaction.bundle +
          transaction.trunkTransaction +
          transaction.branchTransaction +
          tag +
          IOTA::Crypto::Converter.trytes(attachmentTimestampTrits) +
          IOTA::Crypto::Converter.trytes(attachmentTimestampLowerBoundTrits) +
          IOTA::Crypto::Converter.trytes(attachmentTimestampUpperBoundTrits) +
          transaction.nonce
        )
      end

      def addChecksum(input, checksumLength = 9, isAddress = true)
        # the length of the trytes to be validated
        validationLength = isAddress ? 81 : nil

        isSingleInput = @validator.isString(input)

        # If only single address, turn it into an array
        input = [input] if isSingleInput

        inputsWithChecksum = input.map do |inputValue|
          # check if correct trytes
          if !@validator.isTrytes(inputValue, validationLength)
            throw Error, "Invalid input provided"
          end

          kerl = IOTA::Crypto::Kerl.new

          # Address trits
          addressTrits = IOTA::Crypto::Converter.trits(inputValue)

          # Checksum trits
          checksumTrits = []

          # Absorb address trits
          kerl.absorb(addressTrits, 0, addressTrits.length)

          # Squeeze checksum trits
          kerl.squeeze(checksumTrits, 0, IOTA::Crypto::Curl::HASH_LENGTH)

          # First 9 trytes as checksum
          checksum = IOTA::Crypto::Converter.trytes(checksumTrits)[81-checksumLength...81]
          inputValue + checksum
        end

        isSingleInput ? inputsWithChecksum[0] : inputsWithChecksum
      end

      def isBundle(bundle)
        # If not correct bundle
        return false if !@validator.isArrayOfTxObjects(bundle)

        bundle = bundle.transactions if bundle.class == IOTA::Models::Bundle

        totalSum = 0
        bundleHash = bundle[0].bundle

        # Prepare to absorb txs and get bundleHash
        bundleFromTxs = []

        kerl = IOTA::Crypto::Kerl.new

        # Prepare for signature validation
        signaturesToValidate = []

        bundle.each_with_index do |bundleTx, index|
          totalSum += bundleTx.value

          # currentIndex has to be equal to the index in the array
          return false if bundleTx.currentIndex != index

          # Get the transaction trytes
          trytes = transactionTrytes(bundleTx)

          # Absorb bundle hash + value + timestamp + lastIndex + currentIndex trytes.
          trits = IOTA::Crypto::Converter.trits(trytes.slice(2187, 162))
          kerl.absorb(trits, 0, trits.length)

          # Check if input transaction
          if bundleTx.value < 0
            address = bundleTx.address

            newSignatureToValidate = {
              address: address,
              signatureFragments: [bundleTx.signatureMessageFragment]
            }

            # Find the subsequent txs with the remaining signature fragment
            (index...bundle.length-1).step(1) do |i|
              newBundleTx = bundle[i+1]

              if newBundleTx.address == address && newBundleTx.value == 0
                newSignatureToValidate[:signatureFragments] << newBundleTx.signatureMessageFragment
              end
            end

            signaturesToValidate << newSignatureToValidate
          end
        end

        # Check for total sum, if not equal 0 return error
        return false if totalSum != 0

        # get the bundle hash from the bundle transactions
        kerl.squeeze(bundleFromTxs, 0, IOTA::Crypto::Kerl::HASH_LENGTH)
        bundleFromTxs = IOTA::Crypto::Converter.trytes(bundleFromTxs)

        # Check if bundle hash is the same as returned by tx object
        return false if bundleFromTxs != bundleHash

        # Last tx in the bundle should have currentIndex === lastIndex
        return false if bundle[bundle.length - 1].currentIndex != bundle[bundle.length - 1].lastIndex

        # Validate the signatures
        (0...signaturesToValidate.length).step(1) do |i|
          return false if !IOTA::Crypto::Signing.validateSignatures(signaturesToValidate[i][:address], signaturesToValidate[i][:signatureFragments], bundleHash)
        end

        true
      end

      def isValidChecksum(addressWithChecksum)
        withoutChecksum = noChecksum(addressWithChecksum)
        newWithCheckcum = addChecksum(withoutChecksum)
        newWithCheckcum == addressWithChecksum
      end

      def validateSignatures(signedBundle, inputAddress)
        bundleHash = nil
        signatureFragments = []

        signedBundle = signedBundle.transactions if signedBundle.class == IOTA::Models::Bundle

        (0...signedBundle.length).step(1) do |i|
          if signedBundle[i].address === inputAddress
            bundleHash = signedBundle[i].bundle

            signature = signedBundle[i].signatureMessageFragment

            # if we reached remainder bundle
            break if @validator.isString(signature) && @validator.isAllNine(signature)

            signatureFragments << signature
          end
        end

        return false if bundleHash.nil?

        IOTA::Crypto::Signing.validateSignatures(inputAddress, signatureFragments, bundleHash)
      end

      def categorizeTransfers(transfers, addresses)
        categorized = {
          sent: [],
          received: []
        }

        addresses = addresses.map { |a| a[0...81] }

        # Iterate over all bundles and sort them between incoming and outgoing transfers
        transfers.each do |bundle|
          spentAlreadyAdded = false

          bundle = IOTA::Models::Bundle.new(bundle) if bundle.class != IOTA::Models::Bundle

          # Iterate over every bundle entry
          bundle.transactions.each_with_index do |bundleEntry, bundleIndex|
            address = bundleEntry.address[0...81]
            if !addresses.index(address).nil?
              # Check if it's a remainder address
              isRemainder = (bundleEntry.currentIndex == bundleEntry.lastIndex) && bundleEntry.lastIndex != 0

              # check if sent transaction
              if bundleEntry.value < 0 && !spentAlreadyAdded && !isRemainder
                categorized[:sent] << bundle

                # too make sure we do not add transactions twice
                spentAlreadyAdded = true
              elsif bundleEntry.value >= 0 && !spentAlreadyAdded && !isRemainder
                # check if received transaction, or 0 value (message)
                # also make sure that this is not a 2nd tx for spent inputs
                categorized[:received] << bundle
              end
            end
          end
        end
        categorized
      end
    end
  end
end

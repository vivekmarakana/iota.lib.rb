module IOTA
  module Models
    class Account < Base
      attr_reader :client, :seed, :latestAddress, :addresses, :transfers, :inputs, :balance

      def initialize(client, seed, api = nil, validator = nil, utils = nil)
        @api = client ? client.api : api
        @validator = client ? client.validator : validator
        @utils = client ? client.utils : utils
        @seed = seed.class == String ? Seed.new(seed) : seed

        reset
      end

      def reset
        @latestAddress = nil
        @addresses = []
        @transfers = []
        @inputs = []
        @balance = 0.0
      end

      def getAccountDetails(options = {}, fetchInputs = true, fetchTransfers = true)
        reset
        options = symbolize_keys(options)
        startIndex = options[:start] || 0
        endIndex = options[:end] || nil
        security = options[:security] || 2

        # If start value bigger than end, return error or if difference between end and start is bigger than 1000 keys
        if endIndex && (startIndex > endIndex || endIndex > (startIndex + 1000))
          raise StandardError, "Invalid inputs provided"
        end

        addressOptions = {
          index: startIndex,
          total: endIndex ? endIndex - startIndex : nil,
          returnAll: true,
          security: security,
          checksum: true
        }

        # Get a list of all addresses associated with the users seed
        addresses = getNewAddress(addressOptions)

        # assign the last address as the latest address
        # since it has no transactions associated with it
        @latestAddress = addresses.last

        # Add all returned addresses to the lsit of addresses
        # remove the last element as that is the most recent address
        @addresses = addresses.slice(0, addresses.length)

        if fetchInputs
          # Get the correct balance count of all addresses
          @api.getBalances(addresses, 100) do |status2, balancesData|
            if !status2
              raise StandardError, balancesData
            end

            balancesData.each_with_index do |balance, index|
              balance = balance.to_i
              @balance += balance

              if balance > 0
                @inputs << IOTA::Models::Input.new(
                  address: @addresses[index],
                  keyIndex: index,
                  security: security,
                  balance: balance
                )
              end
            end
          end
        end

        if fetchTransfers
          # get all bundles from a list of addresses
          @api.bundlesFromAddresses(addresses, true) do |status1, bundlesData|
            if !status1
              raise StandardError, bundlesData
            end

            # add all transfers
            @transfers = bundlesData
          end
        end

        self
      end

      def getInputs(options = {})
        self.getAccountDetails(options, true, false)
        @inputs
      end

      def getTransfers(options = {})
        self.getAccountDetails(options, false, true)
        @transfers
      end

      def prepareTransfers(transfers, options = {})
        options = symbolize_keys(options)
        hmacKey = options[:hmacKey] || nil
        if !hmacKey.nil?
          raise StandardError, "Invalid trytes provided: #{hmacKey}" if !@validator.isTrytes(hmacKey)
        end

        # If message or tag is not supplied, provide it
        # Also remove the checksum of the address if it's there after validating it
        (0...transfers.length).step(1) do |index|
          if transfers[index].class != IOTA::Models::Transfer
            transfers[index] = IOTA::Models::Transfer.new(transfers[index].merge({ hmacKey: hmacKey }))
          end
        end

        # Input validation of transfers object
        raise StandardError, "Invalid transfers provided" if !@validator.isTransfersArray(transfers)

        # If inputs provided, validate the format
        chosenInputs = options[:inputs] || nil
        raise StandardError, "Invalid inputs provided" if chosenInputs && !@validator.isInputs(chosenInputs)

        remainderAddress = options[:address] || nil
        chosenInputs = chosenInputs || []
        security = options[:security] || 2

        remainderAddress = @utils.noChecksum(remainderAddress) if remainderAddress && remainderAddress.length == 90

        # Create a new bundle
        bundle = IOTA::Crypto::Bundle.new

        totalValue = 0
        signatureFragments = []
        tag = nil

        # Iterate over all transfers, get totalValue and prepare the signatureFragments, message and tag
        (0...transfers.length).step(1) do |i|
          signatureMessageLength = 1

          # If message longer than 2187 trytes, increase signatureMessageLength (add 2nd transaction)
          if transfers[i].message.length > 2187
            # Get total length, message / maxLength (2187 trytes)
            signatureMessageLength += (transfers[i].message.length / 2187).floor
            msgCopy = transfers[i].message

            # While there is still a message, copy it
            while msgCopy
              fragment = msgCopy[0...2187]
              msgCopy = msgCopy[2187...msgCopy.length]

              # Pad remainder of fragment
              while fragment.length < 2187
                fragment += '9'
              end

              signatureFragments << fragment
            end
          else
            # Else, get single fragment with 2187 of 9's trytes
            fragment = ''

            fragment = transfers[i].message[0...2187] if transfers[i].message

            while fragment.length < 2187
              fragment += '9'
            end

            signatureFragments << fragment
          end

          # get current timestamp in seconds
          timestamp = Time.now.utc.to_i

          # If no tag defined, get 27 tryte tag.
          tag = transfers[i].obsoleteTag || ''

          # Pad for required 27 tryte length
          while tag.length < 27
            tag += '9'
          end

          # Add first entries to the bundle
          # Slice the address in case the user provided a checksummed one
          bundle.addEntry(signatureMessageLength, transfers[i].address, transfers[i].value, tag, timestamp)
          # Sum up total value
          totalValue += transfers[i].value.to_i
        end

        # Get inputs if we are sending tokens
        if totalValue > 0
          #  Case 1: user provided inputs
          #
          #  Validate the inputs by calling getBalances
          if chosenInputs && chosenInputs.length > 0
            # Get list if addresses of the provided inputs
            inputsAddresses = [];
            (0...chosenInputs.length).step(1) do |i|
              if chosenInputs[i].class != IOTA::Models::Input
                chosenInputs[i] = IOTA::Models::Input.new(chosenInputs[i])
              end
              inputsAddresses << chosenInputs[i].address
            end

            @api.getBalances(inputsAddresses, 100) do |status, balances|
              raise StandardError, balances if !status

              confirmedInputs = []
              totalBalance = 0

              balances.each_with_index do |balance, i|
                # If input has balance, add it to confirmedInputs
                balance = balance.to_i

                if balance > 0
                  totalBalance += balance

                  input = chosenInputs[i]
                  input.balance = balance

                  confirmedInputs << input

                  # if we've already reached the intended input value, break out of loop
                  if totalBalance >= totalValue
                    break
                  end
                end
              end

              # Return not enough balance error
              raise StandardError, "Not enough balance" if totalValue > totalBalance

              return addRemainder(confirmedInputs, totalValue, bundle, tag, security, signatureFragments, remainderAddress, hmacKey)
            end
          else
            # Case 2: Get inputs deterministically
            # If no inputs provided, derive the addresses from the seed and
            # confirm that the inputs exceed the threshold
            self.getInputs(security: security)

            raise StandardError, "Not enough balance" if totalValue > @balance

            return addRemainder(@inputs, totalValue, bundle, tag, security, signatureFragments, remainderAddress, hmacKey)
          end
        else
          # If no input required, don't sign and simply finalize the bundle
          bundle.finalize()
          bundle.addTrytes(signatureFragments)

          bundleTrytes = []
          bundle.bundle.each do |bndl|
            bundleTrytes << @utils.transactionTrytes(bndl)
          end

          return bundleTrytes.reverse
        end
      end

      def sendTransfer(depth, minWeightMagnitude, transfers, options = {})
        # Check if correct depth and minWeightMagnitude
        if !@validator.isValue(depth) || !@validator.isValue(minWeightMagnitude)
          raise StandardError, "Invalid inputs provided"
        end

        trytes = prepareTransfers(transfers, options)

        @api.sendTrytes(trytes, depth, minWeightMagnitude, options) do |status, data|
          if !status
            raise StandardError, data
          else
            return data
          end
        end
      end

      def getNewAddress(options = {})
        # default index value
        options = symbolize_keys(options)
        index = options[:index] || 0

        # validate the index option
        if !@validator.isValue(index) || index < 0
          raise StandardError, "Invalid index provided: #{index}"
        end

        checksum = options[:checksum] || false
        total = options[:total] || nil
        return_all = options[:returnAll] || false

        # If no user defined security, use the standard value of 2
        security = options[:security] || 2

        # validate the security option
        if !@validator.isValue(security) || security < 1 || security > 3
          raise StandardError, "Invalid security provided: #{index}"
        end

        allAddresses = []

        # Case 1: total
        #
        # If total number of addresses to generate is supplied, simply generate
        # and return the list of all addresses
        if total
            # Increase index with each iteration
            (0...total).step(1) do |i|
              address = @seed.getAddress(index, security, checksum)
              allAddresses << address
              index += 1
            end

            return allAddresses
        else
          #  Case 2: no total provided
          #
          # Continue calling findTransactions to see if address was already created
          #  if null, return list of addresses
          loop do
            newAddress = @seed.getAddress(index, security, checksum)

            @api.wereAddressesSpentFrom([newAddress]) do |status, spent_states|
              if !status
                raise StandardError, spent_states
              end

              spent = spent_states[0]

              # Check transactions if not spent
              if !spent
                @api.findTransactions(addresses: [newAddress]) do |status, trx_hashes|
                  if !status
                    raise StandardError, trx_hashes
                  end

                  spent = trx_hashes.length > 0
                end
              end

              if return_all
                allAddresses << newAddress
              end

              index += 1
              return (return_all ? allAddresses : newAddress) if !spent
            end
          end
        end
      end

      private
      def addRemainder(inputs, totalValue, bundle, tag, security, signatureFragments, remainderAddress, hmacKey)
        totalTransferValue = totalValue
        inputs.each do |input|
          balance = input.balance
          timestamp = Time.now.utc.to_i

          # Add input as bundle entry
          bundle.addEntry(input.security, input.address, -balance, tag, timestamp)

          # If there is a remainder value
          # Add extra output to send remaining funds to
          if balance >= totalTransferValue
            remainder = balance - totalTransferValue

            # If user has provided remainder address
            # Use it to send remaining funds to
            if remainder > 0 && remainderAddress
              # Remainder bundle entry
              bundle.addEntry(1, remainderAddress, remainder, tag, timestamp)

              # Final function for signing inputs
              return signInputs(inputs, bundle, signatureFragments, hmacKey)
            elsif remainder > 0
              index = 0
              (0...inputs.length).step(1) do |k|
                index = [inputs[k].keyIndex, index].max
              end
              index += 1

              # Generate a new Address by calling getNewAddress
              address = getNewAddress({index: index, security: security})
              timestamp = Time.now.utc.to_i

              # Remainder bundle entry
              bundle.addEntry(1, address, remainder, tag, timestamp)

              # Final function for signing inputs
              return signInputs(inputs, bundle, signatureFragments, hmacKey)
            else
              # If there is no remainder, do not add transaction to bundle simply sign and return
              return signInputs(inputs, bundle, signatureFragments, hmacKey)
            end
          else
            # If multiple inputs provided, subtract the totalTransferValue by the inputs balance
            totalTransferValue -= balance
          end
        end
      end

      def signInputs(inputs, bundle, signatureFragments, hmacKey)
        bundle.finalize()
        bundle.addTrytes(signatureFragments)

        # SIGNING OF INPUTS
        # Here we do the actual signing of the inputs
        # Iterate over all bundle transactions, find the inputs
        # Get the corresponding private key and calculate the signatureFragment

        (0...bundle.bundle.length).step(1) do |i|
          trx = bundle.bundle[i]

          if trx.value < 0
            address = trx.address

            # Get the corresponding keyIndex and security of the address
            keyIndex = nil
            keySecurity = nil
            inputs.each do |input|
              if input.address == address
                keyIndex = input.keyIndex
                keySecurity = input.security ? input.security : security
                break
              end
            end

            # Get corresponding private key of address
            privateKey = IOTA::Crypto::PrivateKey.new(@seed.as_trits, keyIndex, keySecurity)
            key = privateKey.key

            #  Get the normalized bundle hash
            normalizedBundleHash = bundle.normalizedBundle(trx.bundle)
            normalizedBundleFragments = []

            # Split hash into 3 fragments
            (0...3).step(1) do |l|
              normalizedBundleFragments[l] = normalizedBundleHash.slice(l * 27, 27)
            end

            #  First 6561 trits for the firstFragment
            firstFragment = key[0...6561]

            #  First bundle fragment uses the first 27 trytes
            firstBundleFragment = normalizedBundleFragments[0]

            #  Calculate the new signatureFragment with the first bundle fragment
            firstSignedFragment = IOTA::Crypto::Signing.signatureFragment(firstBundleFragment, firstFragment)

            #  Convert signature to trytes and assign the new signatureFragment
            trx.signatureMessageFragment = IOTA::Crypto::Converter.trytes(firstSignedFragment)

            # if user chooses higher than 27-tryte security
            # for each security level, add an additional signature
            (1...keySecurity).step(1) do |j|
              #  Because the signature is > 2187 trytes, we need to
              #  find the subsequent transaction to add the remainder of the signature
              #  Same address as well as value = 0 (as we already spent the input)
              if bundle.bundle[i + j].address == address && bundle.bundle[i + j].value == 0
                # Use the next 6561 trits
                nextFragment = key.slice(6561 * j, 6561)

                nextBundleFragment = normalizedBundleFragments[j]

                #  Calculate the new signature
                nextSignedFragment = IOTA::Crypto::Signing.signatureFragment(nextBundleFragment, nextFragment)

                #  Convert signature to trytes and assign it again to this bundle entry
                bundle.bundle[i + j].signatureMessageFragment = IOTA::Crypto::Converter.trytes(nextSignedFragment)
              end
            end
          end
        end

        if hmacKey
          hmac = IOTA::Crypto::Hmac(hmacKey)
          hmac.addHMAC(bundle)
        end

        bundleTrytes = []

        # Convert all bundle entries into trytes
        bundle.bundle.each do |bndl|
          bundleTrytes << @utils.transactionTrytes(bndl)
        end

        bundleTrytes.reverse
      end
    end
  end
end

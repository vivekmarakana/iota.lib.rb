module IOTA
  module Multisig
    class Multisig
      def initialize(client)
        @api = client.api
        @utils = client.utils
        @validator = client.validator
        @converter = IOTA::Crypto::Converter
        @signing = IOTA::Crypto::Signing
      end

      def getKey(seed, index, security)
        pk = getPrivateKey(seed, index, security)
        @converter.trytes(pk.key)
      end

      def getDigest(seed, index, security)
        pk = getPrivateKey(seed, index, security)
        @converter.trytes(pk.digests)
      end

      def validateAddress(multisigAddress, digests)
        kerl = IOTA::Crypto::Kerl.new

        # Absorb all key digests
        digests.each do |digest|
          trits = @converter.trits(digest)
          kerl.absorb(@converter.trits(digest), 0, trits.length)
        end

        # Squeeze address trits
        addressTrits = []
        kerl.squeeze(addressTrits, 0, IOTA::Crypto::Kerl::HASH_LENGTH)

        # Convert trits into trytes and return the address
        @converter.trytes(addressTrits) === multisigAddress
      end

      def initiateTransfer(input, remainderAddress = nil, transfers)
        input = IOTA::Models::Input.new(input) if input.class != IOTA::Models::Input

        # If message or tag is not supplied, provide it
        # Also remove the checksum of the address if it's there
        (0...transfers.length).step(1) do |i|
          transfers[i] = IOTA::Models::Transfer.new(transfers[i]) if transfers[i].class != IOTA::Models::Transfer
        end

        # Input validation of transfers object
        raise StandardError, "Invalid transfers provided" if !@validator.isTransfersArray(transfers)

        # check if int
        raise StandardError, "Invalid inputs provided" if !@validator.isValue(input.security)

        # validate input address
        raise StandardError, "Invalid input address provided" if !@validator.isAddress(input.address)

        # validate remainder address
        raise StandardError, "Invalid remainder address provided" if remainderAddress && !@validator.isAddress(remainderAddress)

        remainderAddress = @utils.noChecksum(remainderAddress) if remainderAddress.length == 90

        # Create a new bundle
        bundle = IOTA::Crypto::Bundle.new

        totalValue = 0
        signatureFragments = []
        tag = nil

        # Iterate over all transfers, get totalValue and prepare the signatureFragments, message and tag
        (0...transfers.length).step(1) do |i|
          signatureMessageLength = 1

          # If message longer than 2187 trytes, increase signatureMessageLength (add multiple transactions)
          if transfers[i].message.length > 2187
            # Get total length, message / maxLength (2187 trytes)
            signatureMessageLength += (transfers[i].message.length / 2187).floor

            msgCopy = transfers[i].message

            # While there is still a message, copy it
            while msgCopy
              fragment = msgCopy.slice(0, 2187)
              msgCopy = msgCopy.slice(2187, msgCopy.length)

              # Pad remainder of fragment
              fragment += (['9']*(2187-fragment.length)).join('') if fragment.length < 2187

              signatureFragments.push(fragment)
            end
          else
            # Else, get single fragment with 2187 of 9's trytes
            fragment = ''

            fragment = transfers[i].message.slice(0, 2187) if transfers[i].message

            # Pad remainder of fragment
            fragment += (['9']*(2187-fragment.length)).join('') if fragment.length < 2187

            signatureFragments.push(fragment)
          end

          # get current timestamp in seconds
          timestamp = Time.now.utc.to_i

          # If no tag defined, get 27 tryte tag.
          tag = transfers[i].obsoleteTag ? transfers[i].obsoleteTag : (['9']*27).join('')

          # Pad for required 27 tryte length
          tag += (['9']*(27-tag.length)).join('') if tag.length < 27

          # Add first entries to the bundle
          # Slice the address in case the user provided a checksummed one
          bundle.addEntry(signatureMessageLength, transfers[i].address.slice(0, 81), transfers[i].value, tag, timestamp)

          # Sum up total value
          totalValue += transfers[i].value.to_i
        end

        # Get inputs if we are sending tokens
        if totalValue > 0
          if input.balance
            return createBundle(input.balance, totalValue, bundle, input, remainderAddress, tag, signatureFragments)
          else
            @api.getBalances([input.address], 100) do |st1, balances|
              if !st1
                raise StandardError, "Error fetching balances: #{balances}"
              else
                return createBundle(balances.balances[0].to_i, totalValue, bundle, input, remainderAddress, tag, signatureFragments)
              end
            end
          end
        else
          raise StandardError, "Invalid value transfer: the transfer does not require a signature."
        end
      end

      def addSignature(bundleToSign, inputAddress, key)
        bundleToSign = [bundleToSign] if bundleToSign.class != Array
        bundle = IOTA::Crypto::Bundle.new(bundleToSign)

        # Get the security used for the private key
        # 1 security level = 2187 trytes
        security = (key.length / 2187).to_i

        # convert private key trytes into trits
        key = @converter.trits(key)

        # First get the total number of already signed transactions
        # use that for the bundle hash calculation as well as knowing
        # where to add the signature
        numSignedTxs = 0

        (0...bundle.bundle.length).step(1) do |i|
          bundle.bundle[i] = IOTA::Models::Transaction.new(bundle.bundle[i]) if bundle.bundle[i].class != IOTA::Models::Transaction
          if bundle.bundle[i].address === inputAddress
            # If transaction is already signed, increase counter
            if !@validator.isAllNine(bundle.bundle[i].signatureMessageFragment)
              numSignedTxs += 1
            else
              # sign the transactions
              bundleHash = bundle.bundle[i].bundle

              # First 6561 trits for the firstFragment
              firstFragment = key.slice(0, 6561)

              # Get the normalized bundle hash
              normalizedBundleHash = bundle.normalizedBundle(bundleHash)
              normalizedBundleFragments = []

              # Split hash into 3 fragments
              (0...3).step(1) do |k|
                normalizedBundleFragments[k] = normalizedBundleHash.slice(k * 27, 27)
              end

              # First bundle fragment uses 27 trytes
              firstBundleFragment = normalizedBundleFragments[numSignedTxs % 3]

              # Calculate the new signatureFragment with the first bundle fragment
              firstSignedFragment = @signing.signatureFragment(firstBundleFragment, firstFragment)

              # Convert signature to trytes and assign the new signatureFragment
              bundle.bundle[i].signatureMessageFragment = @converter.trytes(firstSignedFragment)

              (1...security).step(1) do |j|
                # Next 6561 trits for the firstFragment
                nextFragment = key.slice(6561 * j, 6561)


                # Use the next 27 trytes
                nextBundleFragment = normalizedBundleFragments[(numSignedTxs + j) % 3]

                # Calculate the new signatureFragment with the first bundle fragment
                nextSignedFragment = @signing.signatureFragment(nextBundleFragment, nextFragment)

                # Convert signature to trytes and add new bundle entry at i + j position
                # Assign the signature fragment
                bundle.bundle[i + j].signatureMessageFragment = @converter.trytes(nextSignedFragment)
              end

              break
            end
          end
        end

        bundle.bundle
      end

      private
      def getPrivateKey(seed, index, security)
        seed = IOTA::Models::Seed.new(seed) if seed.class != IOTA::Models::Seed
        IOTA::Crypto::PrivateKey.new(seed.as_trits, index, security)
      end

      def createBundle(totalBalance, totalValue, bundle, input, remainderAddress, tag, signatureFragments)
        if totalBalance > 0
          toSubtract = 0 - totalBalance
          timestamp = Time.now.utc.to_i

          # Add input as bundle entry
          # Only a single entry, signatures will be added later
          bundle.addEntry(input.security, input.address, toSubtract, tag, timestamp)
        end

        raise StandardError, "Not enough balance" if totalValue > totalBalance

        # If there is a remainder value
        # Add extra output to send remaining funds to
        if totalBalance > totalValue
          remainder = totalBalance - totalValue

          # Remainder bundle entry if necessary
          return StandardError, "No remainder address defined" if !remainderAddress

          bundle.addEntry(1, remainderAddress, remainder, tag, timestamp)
        end

        bundle.finalize()
        bundle.addTrytes(signatureFragments)

        bundle.bundle
      end
    end
  end
end

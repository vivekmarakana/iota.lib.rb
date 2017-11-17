module IOTA
  module API
    module Wrappers
      def getTransactionsObjects(hashes, &callback)
        # If not array of hashes, return error
        if !@validator.isArrayOfHashes(hashes)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        ret_status = false
        ret_data = nil
        # get the trytes of the transaction hashes
        getTrytes(hashes) do |status, trytes|
          ret_status = status
          if status
            transactionObjects = []
            trytes.each do |tryte|
              if !tryte
                transactionObjects << nil
              else
                transactionObjects << @utils.transactionObject(tryte)
              end
            end
            ret_data = transactionObjects
          else
            ret_data = trytes
          end
        end

        sendData(ret_status, ret_data, &callback)
      end

      def findTransactionObjects(input, &callback)
        findTransactions(input) do |status, trytes|
          if !status
            return sendData(status, trytes, &callback)
          else
            return getTransactionsObjects(trytes, &callback)
          end
        end
      end

      def getLatestInclusion(hashes, &callback)
        ret_status = false
        ret_data = nil
        getNodeInfo do |status, data|
          if status
            ret_status = true
            ret_data = data['latestSolidSubtangleMilestone']
          end
        end

        if ret_status
          return getInclusionStates(hashes, [ret_data], &callback)
        else
          return sendData(ret_status, ret_data, &callback)
        end
      end

      def storeAndBroadcast(trytes, &callback)
        storeTransactions(trytes) do |status, data|
          if !status
            return sendData(status, data, &callback)
          else
            return broadcastTransactions(trytes, &callback)
          end
        end
      end

      def sendTrytes(trytes, depth, minWeightMagnitude, &callback)
        # Check if correct depth and minWeightMagnitude
        if !@validator.isValue(depth) || !@validator.isValue(minWeightMagnitude)
          return sendData(false, "Invalid inputs provided", &callback)
        end

        getTransactionsToApprove(depth) do |status, approval_data|
          if !status
            return sendData(false, approval_data, &callback)
          end

          attachToTangle(approval_data['trunkTransaction'], approval_data['branchTransaction'], minWeightMagnitude, trytes) do |status1, attached_data|
            if !status1
              return sendData(false, attached_data, &callback)
            end

            # If the user is connected to the sandbox, we have to monitor the POW queue
            # to check if the POW job was completed
            if @sandbox
              # Implement sandbox processing
              jobUri = @sandbox + '/jobs/' + attached_data['id']

              # Do the Sandbox send function
              @broker.sandboxSend(jobUri) do |status2, sandbox_data|
                if !status2
                  return sendData(false, sandbox_data, &callback)
                end

                storeAndBroadcast(sandbox_data) do |status3, data|
                  if status3
                    return sendData(false, data, &callback)
                  end

                  finalTxs = []

                  attachedTrytes.each do |trytes1|
                    finalTxs << @utils.transactionObject(trytes1)
                  end

                  return sendData(true, finalTxs, &callback)
                end
              end
            else
              # Broadcast and store tx
              storeAndBroadcast(attached_data) do |status2, data|
                if !status2
                  return sendData(false, data, &callback)
                end

                transactions = attached_data.map { |tryte| @utils.transactionObject(tryte) }

                sendData(true, transactions, &callback)
              end
            end
          end
        end
      end

      def bundlesFromAddresses(addresses, inclusionStates, &callback)
        # call wrapper function to get txs associated with addresses
        findTransactionObjects(addresses: addresses) do |status, transactionObjects|
          if !status
            return sendData(false, transactionObjects, &callback)
          end

          # set of tail transactions
          tailTransactions = []
          nonTailBundleHashes = []

          transactionObjects.each do |trx|
            # Sort tail and nonTails
            if trx.currentIndex == 0
              tailTransactions << trx.hash
            else
              nonTailBundleHashes << trx.bundle
            end
          end

          # Get tail transactions for each nonTail via the bundle hash
          findTransactionObjects(bundles: nonTailBundleHashes.uniq) do |st1, trxObjects|
            if !st1
              return sendData(false, trxObjects, &callback)
            end

            trxObjects.each do |trx|
              tailTransactions << trx.hash if trx.currentIndex == 0
            end

            finalBundles = []
            tailTransactions = tailTransactions.uniq
            tailTxStates = []

            # If inclusionStates, get the confirmation status of the tail transactions, and thus the bundles
            if inclusionStates && tailTransactions.length > 0
              getLatestInclusion(tailTransactions) do |st2, states|
                # If error, return it to original caller
                if !status
                  return sendData(false, states, &callback)
                end

                tailTxStates = states
              end
            end

            tailTransactions.each do |tailTx|
              getBundle(tailTx) do |st2, bundleTransactions|
                if !st2
                  return sendData(false, bundleTransactions, &callback)
                end

                if inclusionStates
                  thisInclusion = tailTxStates[tailTransactions.index(tailTx)]

                  bundleTransactions.each do |bundleTx|
                    bundleTx.persistence = thisInclusion
                  end
                end

                finalBundles << IOTA::Models::Bundle.new(bundleTransactions)
              end
            end
            # Sort bundles by attachmentTimestamp
            finalBundles = finalBundles.sort{|a, b| a.attachmentTimestamp <=> b.attachmentTimestamp}
            return sendData(true, finalBundles, &callback)
          end
        end
      end

      def getBundle(transaction, &callback)
        # Check if correct hash
        if !@validator.isHash(transaction)
           return sendData(false, "Invalid transaction input provided", &callback)
        end

        # Initiate traverseBundle
        traverseBundle(transaction, nil, []) do |status, bundle|
          if !status
            return sendData(false, bundle, &callback)
          end

          if !@utils.isBundle(bundle)
            return sendData(false, "Invalid Bundle provided", &callback)
          end

          return sendData(true, bundle, &callback)
        end
      end

      def replayBundle(tail, depth, minWeightMagnitude, &callback)
        # Check if correct tail hash
        if !@validator.isHash(tail)
          return sendData(false, "Invalid trytes provided", &callback)
        end

        # Check if correct depth and minWeightMagnitude
        if !@validator.isValue(depth) || !@validator.isValue(minWeightMagnitude)
          return sendData(false, "Invalid inputs provided", &callback)
        end

        getBundle(tail) do |status, transactions|
          if !status
            return sendData(false, transactions, &callback)
          end

          bundleTrytes = []
          transactions.each do |trx|
            bundleTrytes << @utils.transactionTrytes(trx);
          end

          return sendTrytes(bundleTrytes.reverse, depth, minWeightMagnitude, &callback)
        end
      end

      def broadcastBundle(tail, &callback)
        # Check if correct tail hash
        if !@validator.isHash(tail)
          return sendData(false, "Invalid trytes provided", &callback)
        end

        getBundle(tail) do |status, transactions|
          if !status
            return sendData(false, transactions, &callback)
          end

          bundleTrytes = []
          transactions.each do |trx|
            bundleTrytes << @utils.transactionTrytes(trx);
          end

          return broadcastTransactions(bundleTrytes.reverse, &callback)
        end
      end

      def traverseBundle(trunkTx, bundleHash, bundle, &callback)
        # Get trytes of transaction hash
        getTrytes([trunkTx]) do |status, trytesList|
          if !status
            return sendData(false, trytesList, &callback)
          end

          trytes = trytesList[0]

          if !trytes
            return sendData(false, "Bundle transactions not visible", &callback)
          end

          # get the transaction object
          txObject = @utils.transactionObject(trytes)

          if !trytes
            return sendData(false, "Invalid trytes, could not create object", &callback)
          end

          # If first transaction to search is not a tail, return error
          if !bundleHash && txObject.currentIndex != 0
            return sendData(false, "Invalid tail transaction supplied", &callback)
          end

          # If no bundle hash, define it
          if !bundleHash
            bundleHash = txObject.bundle
          end

          # If different bundle hash, return with bundle
          if bundleHash != txObject.bundle
            return sendData(true, bundle, &callback)
          end

          # If only one bundle element, return
          if txObject.lastIndex == 0 && txObject.currentIndex == 0
            return sendData(true, [txObject], &callback)
          end

          # Define new trunkTransaction for search
          trunkTx = txObject.trunkTransaction

          # Add transaction object to bundle
          bundle << txObject

          # Continue traversing with new trunkTx
          return traverseBundle(trunkTx, bundleHash, bundle, &callback)
        end
      end

      def isReattachable(inputAddresses, &callback)
        # if string provided, make array
        inputAddresses = [inputAddresses] if @validator.isString(inputAddresses)

        # Categorized value transactions
        # hash -> txarray map
        addressTxsMap = {}
        addresses = []

        inputAddresses.each do |address|
          if !@validator.isAddress(address)
            return sendData(false, "Invalid inputs provided", &callback)
          end

          address = @utils.noChecksum(address)

          addressTxsMap[address] = []
          addresses << address
        end

        findTransactionObjects(addresses: addresses) do |status, transactions|
          if !status
            return sendData(false, transactions, &callback)
          end

          valueTransactions = []

          transactions.each do |trx|
            if trx.value < 0
              txAddress = trx.address
              txHash = trx.hash

              addressTxsMap[txAddress] << txHash
              valueTransactions << txHash
            end
          end

          if valueTransactions.length > 0
            # get the includion states of all the transactions
            getLatestInclusion(valueTransactions) do |st1, inclusionStates|
              if !st1
                return sendData(false, inclusionStates, &callback)
              end

              # bool array
              results = addresses.map do |address|
                txs = addressTxsMap[address]
                numTxs = txs.length

                if numTxs == 0
                  true
                else
                  shouldReattach = true

                  (0...numTxs).step(1) do |i|
                    tx = txs[i]
                    txIndex = valueTransactions.index(tx)
                    isConfirmed = inclusionStates[txIndex]
                    shouldReattach = isConfirmed ? false : true
                    break if isConfirmed
                  end

                  shouldReattach
                end
              end

              # If only one entry, return first
              results = results.first if results.length == 1

              return sendData(true, results, &callback)
            end
          else
            results = [];
            numAddresses = addresses.length;

            # prepare results array if multiple addresses
            if numAddresses > 1
              numAddresses.each do |i|
                results << true
              end
            else
              results = true
            end

            return sendData(true, results, &callback)
          end
        end
      end
    end
  end
end

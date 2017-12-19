module IOTA
  module API
    class Commands
      def findTransactions(searchValues)
        command = {
          command: 'findTransactions'
        }

        searchValues.each { |k, v| command[k] = v }

        command
      end

      def getBalances(addresses, threshold)
        {
          command: 'getBalances',
          addresses: addresses,
          threshold: threshold
        }
      end

      def getTrytes(hashes)
        {
          command: 'getTrytes',
          hashes: hashes
        }
      end

      def getInclusionStates(transactions, tips)
        {
          command: 'getInclusionStates',
          transactions: transactions,
          tips: tips
        }
      end

      def getNodeInfo
        { command: 'getNodeInfo'}
      end

      def getNeighbors
        { command: 'getNeighbors' }
      end

      def addNeighbors(uris)
        {
          command: 'addNeighbors',
          uris: uris
        }
      end

      def removeNeighbors(uris)
        {
          command: 'removeNeighbors',
          uris: uris
        }
      end

      def getTips
        { command: 'getTips' }
      end

      def getTransactionsToApprove(depth, reference = nil)
        {
          command: 'getTransactionsToApprove',
          depth: depth
        }.merge(reference.nil? ? {} : { reference: reference })
      end

      def attachToTangle(trunkTransaction, branchTransaction, minWeightMagnitude, trytes)
        {
          command: 'attachToTangle',
          trunkTransaction: trunkTransaction,
          branchTransaction: branchTransaction,
          minWeightMagnitude: minWeightMagnitude,
          trytes: trytes
        }
      end

      def interruptAttachingToTangle
        { command: 'interruptAttachingToTangle' }
      end

      def broadcastTransactions(trytes)
        {
          command: 'broadcastTransactions',
          trytes: trytes
        }
      end

      def storeTransactions(trytes)
        {
          command: 'storeTransactions',
          trytes: trytes
        }
      end

      def checkConsistency(tails)
        {
          command: 'checkConsistency',
          tails: tails
        }
      end
    end
  end
end

module IOTA
  module API
    class Api
      include Wrappers

      def initialize(broker, sandbox)
        @broker = broker
        @sandbox = sandbox
        @commands = Commands.new
        @utils = IOTA::Utils::Utils.new
        @validator = @utils.validator
      end

      def sendCommand(command, &callback)
        @broker.send(command, &callback)
      end

      def findTransactions(searchValues, &callback)
        if !@validator.isObject(searchValues)
          return sendData(false, "You have provided an invalid key value", &callback)
        end

        searchKeys = searchValues.keys
        validKeys = ['bundles', 'addresses', 'tags', 'approvees']

        error = false;

        searchKeys.each do |key|
          if !validKeys.include?(key.to_s)
            error = "You have provided an invalid key value"
            break
          end

          hashes = searchValues[key]

          if key.to_s == 'addresses'
            searchValues[key] = hashes.map do |address|
              @utils.noChecksum(address)
            end
          end

          # If tags, append to 27 trytes
          if key.to_s == 'tags'
            searchValues[key] = hashes.map do |hash|
              # Simple padding to 27 trytes
              while hash.length < 27
                hash += '9'
              end
              # validate hash
              if !@validator.isTrytes(hash, 27)
                error = "Invalid Trytes provided"
                break
              end

              hash
            end
          else
            # Check if correct array of hashes
            if !@validator.isArrayOfHashes(hashes)
              error = "Invalid Trytes provided"
              break
            end
          end
        end

        if error
          return sendData(false, error, &callback)
        else
          sendCommand(@commands.findTransactions(searchValues), &callback)
        end
      end

      def getBalances(addresses, threshold, &callback)
        # Check if correct transaction hashes
        if !@validator.isArrayOfHashes(addresses)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        command = @commands.getBalances(addresses.map{|address| @utils.noChecksum(address)}, threshold)
        sendCommand(command, &callback)
      end

      def getTrytes(hashes, &callback)
        if !@validator.isArrayOfHashes(hashes)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        sendCommand(@commands.getTrytes(hashes), &callback)
      end

      def getInclusionStates(transactions, tips, &callback)
        # Check if correct transaction hashes
        if !@validator.isArrayOfHashes(transactions)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        # Check if correct tips
        if !@validator.isArrayOfHashes(tips)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        sendCommand(@commands.getInclusionStates(transactions, tips), &callback)
      end

      def getNodeInfo(&callback)
        sendCommand(@commands.getNodeInfo, &callback)
      end

      def getNeighbors(&callback)
        sendCommand(@commands.getNeighbors, &callback)
      end

      def addNeighbors(uris, &callback)
        (0...uris.length).step(1) do |i|
          return sendData(false, "You have provided an invalid URI for your Neighbor: " + uris[i], &callback) if !@validator.isUri(uris[i])
        end

        sendCommand(@commands.addNeighbors(uris), &callback)
      end

      def removeNeighbors(uris, &callback)
        (0...uris.length).step(1) do |i|
          return sendData(false, "You have provided an invalid URI for your Neighbor: " + uris[i], &callback) if !@validator.isUri(uris[i])
        end

        sendCommand(@commands.removeNeighbors(uris), &callback)
      end

      def getTips(&callback)
        sendCommand(@commands.getTips, &callback)
      end

      def getTransactionsToApprove(depth, &callback)
        # Check if correct depth
        if !@validator.isValue(depth)
          return sendData(false, "Invalid inputs provided", &callback)
        end

        sendCommand(@commands.getTransactionsToApprove(depth), &callback)
      end

      def attachToTangle(trunkTransaction, branchTransaction, minWeightMagnitude, trytes, &callback)
        # Check if correct trunk
        if !@validator.isHash(trunkTransaction)
          return sendData(false, "You have provided an invalid hash as a trunk/branch: " + trunkTransaction, &callback)
        end

        # Check if correct branch
        if !@validator.isHash(branchTransaction)
          return sendData(false, "You have provided an invalid hash as a trunk/branch: " + branchTransaction, &callback)
        end

        # Check if minweight is integer
        if !@validator.isValue(minWeightMagnitude)
          return sendData(false, "Invalid inputs provided", &callback)
        end

        # Check if array of trytes
        if !@validator.isArrayOfTrytes(trytes)
          return sendData(false, "Invalid Trytes provided", &callback)
        end

        command = @commands.attachToTangle(trunkTransaction, branchTransaction, minWeightMagnitude, trytes)

        sendCommand(command, &callback)
      end

      def interruptAttachingToTangle(&callback)
        this.sendCommand(@commands.interruptAttachingToTangle, &callback)
      end

      def broadcastTransactions(trytes, &callback)
        if !@validator.isArrayOfAttachedTrytes(trytes)
          return sendData(false, "Invalid attached Trytes provided", &callback)
        end

        sendCommand(@commands.broadcastTransactions(trytes), &callback)
      end

      def storeTransactions(trytes, &callback)
        if !@validator.isArrayOfAttachedTrytes(trytes)
          return sendData(false, "Invalid attached Trytes provided", &callback)
        end

        sendCommand(@commands.storeTransactions(trytes), &callback)
      end

      private
      def sendData(status, data, &callback)
        callback ? callback.call(status, data) : [status, data]
      end
    end
  end
end

module IOTA
  module API
    module Transport
      def sendCommand(command, &callback)
        @broker.send(command, &callback)
      end

      def sendBatchedCommand(command, &callback)
        # Key and value both should be symbols
        mapping = {
          getTrytes: [ :hashes ],
          getBalances: [ :addresses ],
          getInclusionStates: [ :transactions ],
          findTransactions: [ :bundles, :addresses, :tags, :approvees ]
        }

        command_name = command[:command].to_sym
        if mapping[command_name]
          results = []

          keys_to_batch = mapping[command_name]
          keys_to_batch.each do |key|
            if command[key]
              command[key].each_slice(@batch_size) do |group|
                batchedCommand = command.clone.merge({ key => group })
                sendCommand(batchedCommand) do |status, response|
                  if !status
                    return sendData(false, response, &callback)
                  end
                  results += response
                end
              end
            end
          end
          return sendData(true, results, &callback)
        else
          return sendCommand(command, &callback)
        end
      end
    end
  end
end

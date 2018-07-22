module IOTA
  module API
    module Transport
      def sendCommand(command, &callback)
        @broker.send(command, &callback)
      end

      def sendBatchedCommand(command, &callback)
        # Key and value both should be symbols
        mapping = {
          getTrytes: :hashes,
          getBalances: :addresses,
          getInclusionStates: :transactions
        }

        command_name = command[:command].to_sym
        if mapping[command_name] && command[mapping[command_name]].class == Array
          results = []
          command[mapping[command_name]].each_slice(@batch_size) do |group|
            batchedCommand = command.clone
            batchedCommand[mapping[command_name]] = group
            sendCommand(batchedCommand) do |status, response|
              if !status
                return sendData(false, response, &callback)
              end
              results += response
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

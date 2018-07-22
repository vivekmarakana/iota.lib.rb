require 'net/http'
require 'uri'
require 'json'

module IOTA
  module Utils
    class Broker
      def initialize(provider, token, timeout = 120)
        @provider, @token = provider, token
        @timeout = timeout if timeout.to_i > 0
      end

      def send(command, &callback)
        uri, request, req_options = prepareRequest(command)
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        success = true
        begin
          data = JSON.parse(response.body)
          if data.key?('error')
            data = data['error']
            success = false
          else
            data = prepareResponse(data, command[:command])
          end
        rescue JSON::ParserError
          success = false
          data = "Invalid response"
        end
        callback ? callback.call(success, data) : [success, data]
      end

      def sandboxSend(uri, &callback)
        processed = false
        success = false
        retValue = nil

        loop do
          uri, request, req_options = prepareRequest(nil, uri, Net::HTTP::Get)

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          begin
            data = JSON.parse(response.body)
            if data['status'] == 'FINISHED'
              processed = true
              success = true
              retValue = data['attachToTangleResponse']['trytes']
            elsif data['status'] == 'FAILED'
              processed = true
              success = false
              retValue = "Sandbox transaction processing failed. Please retry."
            end
          rescue JSON::ParserError
            processed = true
            success = false
            retValue = "Invalid response"
          end

          break if processed

          # Sleep for 15 seconds before making another request
          sleep 15
        end

        callback ? callback.call(success, retValue) : [success, retValue]
      end

      private
      def prepareRequest(command = nil, uri = @provider, requestMethod = Net::HTTP::Post)
        uri = URI.parse(uri)
        request = requestMethod.new(uri)
        request.content_type = "application/json"
        request['X-IOTA-API-Version'] = '1'
        request.body = JSON.dump(command) if !command.nil?

        req_options = {
          use_ssl: uri.scheme == "https",
          read_timeout: @timeout || 120
        }

        request["Authorization"] = "token #{@token}" if @token

        [uri, request, req_options]
      end

      def prepareResponse(result, command)
        resultMap = {
          'getNeighbors'          =>   'neighbors',
          'addNeighbors'          =>   'addedNeighbors',
          'removeNeighbors'       =>   'removedNeighbors',
          'getTips'               =>   'hashes',
          'findTransactions'      =>   'hashes',
          'getTrytes'             =>   'trytes',
          'getInclusionStates'    =>   'states',
          'attachToTangle'        =>   'trytes',
          'checkConsistency'      =>   'state',
          'getBalances'           =>   'balances'
        }

        # If correct result and we want to prepare the result
        if result && resultMap.key?(command)
          # If the response is from the sandbox, don't prepare the result
          if command === 'attachToTangle' && result.key?('id')
            result = result
          else
            result = result[resultMap[command]]
          end
        end

        result
      end
    end
  end
end

require "iota/version"

require "iota/utils/input_validator"
require "iota/utils/object_validator"
require "iota/utils/ascii"
require "iota/utils/utils"
require "iota/utils/broker"

require "iota/api/commands"
require "iota/api/wrappers"
require "iota/api/api"

require "iota/crypto/curl"
require "iota/crypto/kerl"
require "iota/crypto/converter"
require "iota/crypto/bundle"
require "iota/crypto/signing"
require "iota/crypto/hmac"
require "iota/crypto/private_key"

require "iota/models/base"
require "iota/models/input"
require "iota/models/transfer"
require "iota/models/seed"
require "iota/models/transaction"
require "iota/models/bundle"
require "iota/models/account"

module IOTA
  class Client
    attr_reader :version, :host, :port, :provider, :sandbox, :token, :broker, :api, :utils, :validator, :multisig

    def initialize(settings = {})
      setSettings(settings)
      @utils = IOTA::Utils::Utils.new
      @validator = @utils.validator
      @multisig = nil
      # TODO: Implement MAM
      # TODO: Implement Flash Channel
    end

    def changeNode(settings = {})
      setSettings(settings)
      self
    end

    private
    def setSettings(settings)
      settings = symbolize_keys(settings)
      @host = settings[:host] ? settings[:host] : "http://localhost"
      @port = settings[:port] ? settings[:port] : 14265
      @provider = settings[:provider] || @host.gsub(/\/$/, '') + ":" + @port.to_s
      @sandbox = settings[:sandbox] || false
      @token = settings[:token] || false
      @timeout = settings[:timeout] || 120

      if @sandbox
        @sandbox = @provider.gsub(/\/$/, '')
        @provider = @sandbox + '/commands'
      end

      @broker = IOTA::Utils::Broker.new(@provider, @token, @timeout)
      @api = IOTA::API::Api.new(@broker, @sandbox)
    end

    def symbolize_keys(hash)
      hash.inject({}){ |h,(k,v)| h[k.to_sym] = v; h }
    end
  end
end

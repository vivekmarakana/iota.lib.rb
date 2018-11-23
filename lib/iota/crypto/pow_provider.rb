require 'ffi'

module IOTA
  module Crypto
    class PowProvider
      extend FFI::Library

      lib_root = File.join(File.dirname(__FILE__), '../../../ext/pow')
      if FFI::Platform.windows?
        libccurl_path = "#{lib_root}/ccurl.dll"
      elsif FFI::Platform.mac?
        libccurl_path = "#{lib_root}/libccurl.dylib"
      else
        libccurl_path = "#{lib_root}/libccurl.so"
      end

      ffi_lib libccurl_path

      attach_function :ccurl_pow, [ :string, :int ], :string
      attach_function :ccurl_digest_transaction, [ :string ], :string

      alias_method :pow, :ccurl_pow
      alias_method :digest, :ccurl_digest_transaction
    end
  end
end

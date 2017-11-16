module IOTA
  module Crypto
    class Signing
      HASH_LENGTH = Kerl::HASH_LENGTH

      class << self
        def address(digests)
          addressTrits = []

          kerl = Kerl.new

          kerl.absorb(digests, 0, digests.length)
          kerl.squeeze(addressTrits, 0, Kerl::HASH_LENGTH)

          addressTrits
        end

        def digest(normalizedBundleFragment, signatureFragment)
          buffer = []
          kerl = Kerl.new

          (0...27).step(1) do |i|
            buffer = signatureFragment.slice(i * HASH_LENGTH, HASH_LENGTH)

            j = normalizedBundleFragment[i] + 13

            while j > 0
              jKerl = Kerl.new
              jKerl.absorb(buffer, 0, buffer.length)
              jKerl.squeeze(buffer, 0, HASH_LENGTH)
              j -= 1
            end

            kerl.absorb(buffer, 0, buffer.length)
          end

          kerl.squeeze(buffer, 0, HASH_LENGTH)
          buffer
        end

        def signatureFragment(normalizedBundleFragment, keyFragment)
          signatureFragment = keyFragment.slice(0, keyFragment.length)
          hash = []

          kerl = Kerl.new

          (0...27).step(1) do |i|
            hash = signatureFragment.slice(i * HASH_LENGTH, HASH_LENGTH)

            (0...13-normalizedBundleFragment[i]).step(1) do |j|
              kerl.reset
              kerl.absorb(hash, 0, hash.length)
              kerl.squeeze(hash, 0, HASH_LENGTH)
            end

            (0...HASH_LENGTH).step(1) do |j|
              signatureFragment[i * HASH_LENGTH + j] = hash[j]
            end
          end

          signatureFragment
        end

        def validateSignatures(expectedAddress, signatureFragments, bundleHash)
          if !bundleHash
            raise StandardError, "Invalid bundle hash provided"
          end

          bundle = Bundle.new

          normalizedBundleFragments = []
          normalizedBundleHash = bundle.normalizedBundle(bundleHash)

          # Split hash into 3 fragments
          (0...3).step(1) do |i|
            normalizedBundleFragments[i] = normalizedBundleHash.slice(i * 27, 27)
          end

          # Get digests
          digests = []
          (0...signatureFragments.length).step(1) do |i|
            digestBuffer = digest(normalizedBundleFragments[i % 3], Converter.trits(signatureFragments[i]))

            (0...HASH_LENGTH).step(1) do |j|
              digests[i * 243 + j] = digestBuffer[j]
            end
          end

          addressTrits = address(digests)
          address = Converter.trytes(addressTrits)

          expectedAddress == address
        end
      end
    end
  end
end

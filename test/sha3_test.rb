require "test_helper"

require "iota/crypto/sha3_ruby"

class Sha3Test < Minitest::Test
  def setup
    @ruby_sha3_class = Digest::RubySHA3
    unless RUBY_PLATFORM =~ /java/
      require 'digest/sha3'
      @c_sha3_class = Digest::SHA3
    else
      @c_sha3_class = nil
    end

    @str = "GYOMKVTSNHVJNCNFBBAH9AAMXLPLLLROQY99QN9DLSJUHDPBLCFFAIQXZA9BKMBJCYSFHFPXAHDWZFEIZ"
    @result = "e0ef02d24644a7b28b3c1b01c4fe137a49864d5bde6656faf439e1eba658064d9ecf843255ba903d1cebdc66ff2f16ce"
  end

  def test_that_c_sha3_update_works
    if @c_sha3_class
      start = Time.now
      a = @c_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      a.update(@str)
      puts "C SHA3 Update time: #{(Time.now - start) * 1000.0}ms"

      assert a.digest_length == 48
      assert a.hexdigest == @result
    end
  end

  def test_that_c_sha3_digest_works
    if @c_sha3_class
      start = Time.now
      a = @c_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      assert a.hexdigest(@str) == @result
      puts "C SHA3 Digest time: #{(Time.now - start) * 1000.0}ms"
    end
  end

  def test_that_ruby_sha3_update_works
    if @ruby_sha3_class
      start = Time.now
      a = @ruby_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      a.update(@str)
      puts "Ruby SHA3 Update time: #{(Time.now - start) * 1000.0}ms"
      assert a.digest_length == 48
      assert a.hexdigest == @result
    end
  end

  def test_that_ruby_sha3_digest_works
    if @ruby_sha3_class
      start = Time.now
      a = @ruby_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      assert a.hexdigest(@str) == @result
      puts "Ruby SHA3 Digest time: #{(Time.now - start) * 1000.0}ms"
    end
  end

  def test_that_c_sha3_and_ruby_sha3_give_same_results
    if @ruby_sha3_class && @c_sha3_class
      a = @ruby_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      b = @c_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      assert a.hexdigest(@str) == b.hexdigest(@str)

      a = @ruby_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      b = @c_sha3_class.new(IOTA::Crypto::Kerl::BIT_HASH_LENGTH)
      assert a.update(@str).hexdigest == b.update(@str).hexdigest
    end
  end
end

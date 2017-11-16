require "test_helper"

class KerlTest < Minitest::Test
  def setup
    @converter = IOTA::Crypto::Converter
    @kerl = IOTA::Crypto::Kerl.new
  end

  def test_that_sha3_works
    digest = "\xe0\xef\x02\xd2FD\xa7\xb2\x8b<\x1b\x01\xc4\xfe\x13zI\x86M[\xdefV\xfa\xf49\xe1\xeb\xa6X\x06M\x9e\xcf\x842U\xba\x90=\x1c\xeb\xdcf\xff/\x16\xce".unpack('C*')
    hexdigest = "e0ef02d24644a7b28b3c1b01c4fe137a49864d5bde6656faf439e1eba658064d9ecf843255ba903d1cebdc66ff2f16ce"

    a = Digest::SHA3.new(384)
    a.update("GYOMKVTSNHVJNCNFBBAH9AAMXLPLLLROQY99QN9DLSJUHDPBLCFFAIQXZA9BKMBJCYSFHFPXAHDWZFEIZ")

    assert a.digest_length == 48
    assert a.digest.bytes == digest
    assert a.hexdigest == hexdigest
  end

  def test_that_absorb_squeeze_works
    input = "GYOMKVTSNHVJNCNFBBAH9AAMXLPLLLROQY99QN9DLSJUHDPBLCFFAIQXZA9BKMBJCYSFHFPXAHDWZFEIZ"
    expected = "OXJCNFHUNAHWDLKKPELTBFUCVW9KLXKOGWERKTJXQMXTKFKNWNNXYD9DMJJABSEIONOSJTTEVKVDQEWTW"
    trits = @converter.trits(input)

    @kerl.reset
    @kerl.absorb(trits)
    hashTrits = []
    @kerl.squeeze(hashTrits)
    hash = @converter.trytes(hashTrits)

    assert expected == hash
  end

  def test_that_absorb_multi_squeeze_works
    input = "9MIDYNHBWMBCXVDEFOFWINXTERALUKYYPPHKP9JJFGJEIUY9MUDVNFZHMMWZUYUSWAIOWEVTHNWMHANBH"
    expected = "G9JYBOMPUXHYHKSNRNMMSSZCSHOFYOYNZRSZMAAYWDYEIMVVOGKPJBVBM9TDPULSFUNMTVXRKFIDOHUXXVYDLFSZYZTWQYTE9SPYYWYTXJYQ9IFGYOLZXWZBKWZN9QOOTBQMWMUBLEWUEEASRHRTNIQWJQNDWRYLCA"

    trits = @converter.trits(input)
    @kerl.reset
    @kerl.absorb(trits)

    hashTrits = []
    @kerl.squeeze(hashTrits, 0, IOTA::Crypto::Curl::HASH_LENGTH * 2)
    hash = @converter.trytes(hashTrits)

    assert expected == hash
  end

  def test_that_multi_absorb_multi_squeeze_works
    input = "G9JYBOMPUXHYHKSNRNMMSSZCSHOFYOYNZRSZMAAYWDYEIMVVOGKPJBVBM9TDPULSFUNMTVXRKFIDOHUXXVYDLFSZYZTWQYTE9SPYYWYTXJYQ9IFGYOLZXWZBKWZN9QOOTBQMWMUBLEWUEEASRHRTNIQWJQNDWRYLCA"
    expected = "LUCKQVACOGBFYSPPVSSOXJEKNSQQRQKPZC9NXFSMQNRQCGGUL9OHVVKBDSKEQEBKXRNUJSRXYVHJTXBPDWQGNSCDCBAIRHAQCOWZEBSNHIJIGPZQITIBJQ9LNTDIBTCQ9EUWKHFLGFUVGGUWJONK9GBCDUIMAYMMQX"

    trits = @converter.trits(input)
    @kerl.reset
    @kerl.absorb(trits, 0, trits.length)

    hashTrits = []
    @kerl.squeeze(hashTrits, 0, IOTA::Crypto::Curl::HASH_LENGTH * 2)
    hash = @converter.trytes(hashTrits)

    assert expected == hash
  end
end

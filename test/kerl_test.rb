require "test_helper"

class KerlTest < Minitest::Test
  def setup
    @converter = IOTA::Crypto::Converter
    @kerl = IOTA::Crypto::Kerl.new
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

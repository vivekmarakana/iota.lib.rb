require "bundler/setup"
require "iota"

iota = IOTA::Client.new(provider: 'http://172.104.164.117:14265')

hashes = ["QLMNETEZDOYSBQLRPRJIZNRRDZ9EKY9LCOLNIDQEZNUFWOVYR9SJLBCVIJWIOKGNPMPGWYTNFMOW99999"]

puts iota.api.getTransactionsObjects(hashes)[1]

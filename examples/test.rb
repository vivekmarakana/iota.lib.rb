require "bundler/setup"
require "iota"

iota = IOTA::Client.new(provider: 'http://172.104.164.117:14265')

# bundle = "ONZE99VKNLPP9GTBIBNGSBFCIEXARWUUGTOLTLXJKKVREEBCIHBN9QYLJCSBZFFBCCGXPZJNL9GXOFFWX"
bundle = "WCKBQGFJRFIYVJAZDYLNQZIUQGG9EKZKNUOBEEASPPJXUGCTAGHGWLQSWJKC9DRVEKKHDOUJLNEQCGYK9"

# iota.api.findTransactions(bundles: [bundle]) do |status, hashes|
#   if status && hashes.length > 0
#     iota.api.getTransactionsObjects(hashes) do |st1, transactions|
#       puts transactions.count
#     end
#   end
# end

puts iota.api.getBundle("QLMNETEZDOYSBQLRPRJIZNRRDZ9EKY9LCOLNIDQEZNUFWOVYR9SJLBCVIJWIOKGNPMPGWYTNFMOW99999")[1]

## [1.1.8] - 2019-07-15
- minor fixes in IOTA::Crypto::Converter.trytes
- Fixing some stuff in c extenstion to make it compatible with MRI ruby and Rubinius
- adding support for Rubinius
- adding support for JRuby platforms with native curl function in Java

## [1.1.7] - 2018-12-02
- adding `user` & `password` options to client
- [Local PoW Support](https://github.com/vivekmarakana/iota.lib.rb#local-pow-support)

## [1.1.6] - 2018-07-22
### Added
- `wasAddressSpentFrom` API
- Inbuilt batching for following apis: `getTrytes`, `getBalances`, `wereAddressesSpentFrom`, `getInclusionStates` & `findTransactions`
- adding changelog file to keep track of future changes

### Old major changes
- Only returning balance array as reponse for `getBalances` api call

## [1.1.7] - 2018-12-02
- adding `user` & `password` options to client
- [Local PoW Support](https://github.com/vivekmarakana/iota.lib.rb#local-pow-support)

## [1.1.6] - 2018-07-22
### Added
- `wasAddressSpentFrom` API
- Inbuilt batching for following apis: `getTrytes`, `getBalances`, `wereAddressesSpentFrom`, `getInclusionStates` & `findTransactions`
- adding changelog file to keep track of future changes

### Changed
- Only returning balance array as reponse for `getBalances` api call (Major)

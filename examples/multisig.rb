require "bundler/setup"
require "iota"

iota = IOTA::Client.new(provider: 'http://localhost:14265')

# First co-signer uses index 0 and security level 3
digestOne = iota.multisig.getDigest('ABCDFG', 0, 3)

# Second cosigner also uses index 0 and security level 3 for the private key
digestTwo = iota.multisig.getDigest('FDSAG', 0, 3)

# Initiate the multisig address generation
address = IOTA::Multisig::Address.new

# Absorb the first cosigners key digest
address.absorb(digestOne)

# Absorb the second cosigners key digest
address.absorb(digestTwo)

# and finally we finalize the address itself
finalAddress = address.finalize()

puts "MULTISIG ADDRESS: #{finalAddress}"

# Simple validation if the multisig was created correctly
# Can be called by each cosigner independently
isValid = iota.multisig.validateAddress(finalAddress, [digestOne, digestTwo])

puts "IS VALID MULTISIG ADDRESS: #{isValid}"


# Transfers object
multisigTransfer = [
  {
    address: 'ZGHXPZYDKXPEOSQTAQOIXEEI9K9YKFKCWKYYTYAUWXK9QZAVMJXWAIZABOXHHNNBJIEBEUQRTBWGLYMTX',
    value: 999,
    message: '',
    tag: '999999999999999999999999999'
  }
]

# Multisig address object, used as input
input = {
  address: finalAddress,
  security: 6,
  balance: 1000
}

# Define remainder address
remainderAddress = 'NZRALDYNVGJWUVLKDWFKJVNYLWQGCWYCURJIIZRLJIKSAIVZSGEYKTZRDBGJLOA9AWYJQB9IPWRAKUC9FBDRZJZXZG'

initiatedBundle = iota.multisig.initiateTransfer(input, remainderAddress, multisigTransfer)
firstSignedBundle = iota.multisig.addSignature(initiatedBundle, finalAddress, iota.multisig.getKey('ABCDFG', 0, 3))
finalBundle = iota.multisig.addSignature(firstSignedBundle, finalAddress, iota.multisig.getKey('FDSAG', 0, 3))

puts "IS VALID SIGNATURE: #{iota.utils.validateSignatures(finalBundle, finalAddress)}"

# Send signed transction
# Uncomment following lines if you want to send transaction
# trytes = finalBundle.map do |tx|
#   iota.utils.transactionTrytes(tx)
# end

# iota.api.sendTrytes(trytes.reverse, 10, 14) do |st1, transactions|
#   if st1
#     puts data
#   end
# end

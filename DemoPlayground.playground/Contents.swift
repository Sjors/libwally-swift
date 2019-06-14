import LibWally

BIP39Words.first!

let mnemonic = BIP39Mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")

mnemonic!.words.count
mnemonic!.description


// Initialize mnemonic from entropy:
BIP39Mnemonic(BIP39Entropy("00000000000000000000000000000000")!)

// The seed hex is the starting point for BIP32 deriviation. It can take an optional BIP39 passphrase.
// https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L6
let seedHex: BIP39Seed = mnemonic!.seedHex("TREZOR")
let masterKey = HDKey(seedHex, .mainnet)!
masterKey.description
let path = BIP32Path("m/44'/0'/0'")!
let account = try! masterKey.derive(path)
account.xpub
account.address(.payToWitnessPubKeyHash)

var address = Address("bc1q6zwjfmhdl4pvhvfpv8pchvtanlar8hrhqdyv0t")
address?.scriptPubKey
address?.scriptPubKey.type

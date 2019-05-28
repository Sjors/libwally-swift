import LibWally

BIP39Words.first!

let mnemonic = BIP39Mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")

mnemonic!.words.count
mnemonic!.description

// The seed hex is the starting point for BIP32 deriviation. It can take an optional BIP39 passphrase.
// https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L6
let seedHex: BIP39Seed = mnemonic!.seedHex("TREZOR")

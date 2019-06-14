# LibWally Swift [![Build Status](https://travis-ci.org/blockchain/libwally-swift.svg?branch=master)](https://travis-ci.org/blockchain/libwally-swift)

Opinionated Swift wrapper around [LibWally](https://github.com/ElementsProject/libwally-core),
a collection of useful primitives for cryptocurrency wallets.

Supports a minimal set of features based on v0.7.0. See also [original docs](https://wally.readthedocs.io/en/release_0.7.0).

- [ ] Core Functions
- [ ] Crypto Functions
- [ ] Address Functions
- [x] BIP32 Functions
- [ ] BIP38 Functions
- [x] BIP39 Functions
- [ ] Script Functions
- [ ] Transaction Functions

Works with iOs 11+ on 64-bit devices and the simulator.

## Usage

Derive address from a seed:

```swift
let mnemonic = BIP39Mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
let masterKey = HDKey(mnemonic.seedHex("bip39 passphrase"))!
let path = BIP32Path("m/44'/0'/0'")!
let account = try! masterKey.derive(path)
account.xpub
account.address(.payToWitnessPubKeyHash)
```

Derive address from an xpub:

```
let account = HDKey("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
let receivePath = BIP32Path("0/0")!
key = account.derive(receivePath)
key.address(.payToPubKeyHash) # => 1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj
```

Parse an address:

```swift
var address = Address("bc1q6zwjfmhdl4pvhvfpv8pchvtanlar8hrhqdyv0t")
address?.scriptPubKey # => 0014d09d24eeedfd42cbb12161c38bb17d9ffa33dc77
address?.scriptPubKey.type # => .payToWitnessPubKeyHash
```

See also the included [Playground](/DemoPlayground.playground/Contents.swift) and [tests](/LibWallyTests).

## Install

Via CocoaPods:

```
pod 'LibWally', :git => 'https://github.com/blockchain/LibWallySwift.git', :branch => 'master'
```

```
pod install --verbose
```

## Build

Install dependencies:

```sh
brew install gnu-sed
```

Clone the repository, including submodules:

```sh
git clone https://github.com/blockchain/libwally-swift.git --recurse-submodules
```

Build libwally-core:

```
./build-libwally.sh -dsc
```

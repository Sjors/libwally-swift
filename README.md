# LibWally Swift

Opinionated Swift wrapper around [LibWally](https://github.com/ElementsProject/libwally-core),
a collection of useful primitives for cryptocurrency wallets.

Supports a minimal set of features based on v0.7.0. See also [original docs](https://wally.readthedocs.io/en/release_0.7.0).

- [ ] Core Functions
- [ ] Crypto Functions
- [ ] Address Functions
- [ ] BIP32 Functions
- [ ] BIP38 Functions
- [x] BIP39 Functions
- [ ] Script Functions
- [ ] Transaction Functions

Works with iOs 11+ on 64-bit devices and the simulator.

## Usage

```swift
let mnemonic = BIP39Mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
let masterKey = HDKey(mnemonic.seedHex("bip39 passphrase"))
```

See also the included [Playground](/DemoPlayground.playground/Contents.swift) and [tests](/LibWallyTests).

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
./build-libwally.sh
```

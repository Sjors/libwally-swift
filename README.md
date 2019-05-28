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

Currently only works on the simulator.

## Usage

```swift
let mnemonic = BIP39Mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
mnemonic.seedHex
```

See also the included [Playground](/DemoPlayground.playground/Contents.swift) and [tests](/LibWallyTests).

## Build

Clone the repository, including submodules:

```sh
git clone ... --recurse-submodules
```

```sh
cd libwally-core
mkdir dist
./configure --disable-shared --host=x86_64-apple-darwin --with-sysroot=$(xcrun --sdk iphoneos --show-sdk-path) --enable-static
make
cp src/.libs/libwallycore.a dist/libwallycore-simulator.a
```

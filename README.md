# LibWally Swift

Work in progress. Currently only works on the simulator, and supports a minimal set of features.

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

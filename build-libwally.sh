#!/usr/bin/env sh
set -e # abort if any command fails
echo "Build libwally-core for device and simulator and combine into a single library..."

set -v # display commands
cd libwally-core
sh ./tools/autogen.sh
export CC=`xcrun -find clang`
export CXX=`xcrun -find clang++`
make clean
mkdir -p build
rm -f build/*.a

set +v
echo "Configure and compile for the simulator..."
sleep 2
set -v
export CFLAGS="-O3 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
export CXXFLAGS="-O3 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
./configure --disable-shared --host=x86_64-apple-darwin --enable-static
make
cp src/.libs/libwallycore.a build/libwallycore-simulator.a

set +v
echo "Configure and cross-compile for the device..."
sleep 2
set -v

make clean
export CFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
export CXXFLAGS="-O3 -arch arm64 -isysroot -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
./configure --disable-shared --host=aarch64-apple-darwin14 --enable-static
make
cp src/.libs/libwallycore.a build/libwallycore-device.a

set +v
echo "Combine simulator and device libraries..."
set -v
lipo -create build/libwallycore-device.a build/libwallycore-simulator.a -o src/.libs/libwallycore.a

set +v
echo "Done"

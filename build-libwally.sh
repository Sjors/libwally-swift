#!/usr/bin/env sh
set -e # abort if any command fails

device=0
simulator=0
clean=0

while getopts "h?dsc" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    d)  device=1
        ;;
    s)  simulator=1
        ;;
    c)  clean=1
        ;;
    esac
done

if [ $device == 0 ] && [ $simulator == 0 ]; then
  echo "Set device (-d) and/or simulator (-s)"
  exit 1
fi

if [ $device == 1 ] && [ $simulator == 1 ]; then
  if [ $clean == 0 ]; then
    echo "Set clean (-c) when building both targets"
    exit 1
  fi
  echo "Build libwally-core for device and simulator and combine into a single library..."
fi

cd CLibWally/libwally-core

# Switch to vanilla libsecp256k1, rather than the more experimental libsecp256k1-zkp.
# Since libsecp256k1-zkp is rebased on vanilla libsecp256k1, we can simply checkout
# a common commit.
pushd src/secp256k1
  # Latest commit used in Bitcoin Core:
  # https://github.com/bitcoin/bitcoin/commits/master/src/secp256k1
  git checkout 8746600eec5e7fcd35dabd480839a3a4bdfee87b || exit 1
popd

if [ $clean == 1 ]; then
  rm -rf build
fi

if [ ! -d "build" ]; then
  sh ./tools/autogen.sh
fi
export CC=`xcrun -find clang`
export CXX=`xcrun -find clang++`

set +v
if [ $simulator == 1 ]; then
  if [ ! -d "build" ]; then
    echo "Configure and compile for the simulator..."
    set -v
    export CFLAGS="-O3 -arch arm64 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
    export CXXFLAGS="-O3 -arch arm64 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
    mkdir -p build

    ./configure --disable-shared --host=aarch64-apple-darwin --enable-static --disable-elements --enable-standard-secp

    if [ $clean == 1 ]; then
      set -v # display commands
      make clean
    fi
  fi
  make
  if [ $device == 1 ]; then
    cp src/.libs/libwallycore.a build/libwallycore-simulator.a
    cp src/secp256k1/.libs/libsecp256k1.a build/libsecp256k1-simulator.a
  fi
fi

if [ $device == 1 ]; then
  set +v
  if [ ! -d "build" ] || [ $clean == 1 ]; then
    echo "Configure and cross-compile for the device..."
    set -v
    export CFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
    export CXXFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
    mkdir -p build
    ./configure --disable-shared --host=aarch64-apple-darwin --enable-static --disable-elements --enable-standard-secp
    if [ $clean == 1 ]; then
      make clean
    fi
  fi
  make
  set +v
  if [ $simulator == 1 ]; then
    set -v
    cp src/.libs/libwallycore.a build/libwallycore-device.a
    cp src/secp256k1/.libs/libsecp256k1.a build/libsecp256k1-device.a
  fi
fi

set +v
if [ $device == 1 ] && [ $simulator == 1 ]; then
  echo "Combine simulator and device libraries..."
  set -v
  lipo -create build/libwallycore-device.a build/libwallycore-simulator.a -o src/.libs/libwallycore.a
  lipo -create build/libsecp256k1-device.a build/libsecp256k1-simulator.a -o src/.libs/libsecp256k1.a
fi

set +v
echo "Done"

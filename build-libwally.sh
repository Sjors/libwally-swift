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

if [ $device == 0 ] && [ $simulator == 0 ]
then
  echo "Set device (-d) and/or simulator (-s)"
  exit 1
fi

if [ $device == 1 ] && [ $simulator == 1 ]
then
  if [ $clean == 0]
  then
    echo "Set clean (-c) when building both targets"
    exit 1
  fi
  echo "Build libwally-core for device and simulator and combine into a single library..."
fi

set -v # display commands
cd libwally-core
sh ./tools/autogen.sh
export CC=`xcrun -find clang`
export CXX=`xcrun -find clang++`
mkdir -p build
set +v
if [ $clean == 1 ]
then
  set -v # display commands
  make clean
  rm -f build/*.a
fi

set +v
if [ $simulator == 1 ]
then
  echo "Configure and compile for the simulator..."
  sleep 2
  set -v
  export CFLAGS="-O3 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
  export CXXFLAGS="-O3 -arch x86_64 -fembed-bitcode-marker -mios-simulator-version-min=11.0 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path`"
  ./configure --disable-shared --host=x86_64-apple-darwin --enable-static
  make
  if [ $device == 1 ]
  then
    cp src/.libs/libwallycore.a build/libwallycore-simulator.a
  fi
fi

if [ $device == 1 ]
then
  set +v
  echo "Configure and cross-compile for the device..."
  sleep 2
  if [ $clean == 1]
  then
    make clean
  fi
  set -v
  export CFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
  export CXXFLAGS="-O3 -arch arm64 -isysroot -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
  ./configure --disable-shared --host=aarch64-apple-darwin14 --enable-static
  make
  set +v
  if [ $simulator == 1 ]
  then
    set -v
    cp src/.libs/libwallycore.a build/libwallycore-device.a
  fi
fi

set +v
if [ $device == 1 ] && [ $simulator == 1 ]
then
  echo "Combine simulator and device libraries..."
  set -v
  lipo -create build/libwallycore-device.a build/libwallycore-simulator.a -o src/.libs/libwallycore.a
fi

set +v
echo "Done"

#!/usr/bin/env sh
set -e # abort if any command fails

device=0
simulator=0
clean=0
PROJ_DIRECTORY=`pwd`
BIN_OUTPUT_DIRECTORY="`pwd`/build"

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

rm -rf build

cd CLibWally/libwally-core

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

    ./configure --disable-shared --host=aarch64-apple-darwin --enable-static --disable-elements

    if [ $clean == 1 ]; then
      set -v # display commands
      make clean
    fi
  fi
  make
  cd $PROJ_DIRECTORY
  xcodebuild archive -scheme LibWally -destination "generic/platform=iOS Simulator" -archivePath ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-Sim ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
  if [ $device != 1 ]; then
    xcodebuild -create-xcframework \
      -framework ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-Sim.xcarchive/Products/Library/Frameworks/LibWally.framework \
      -output ${BIN_OUTPUT_DIRECTORY}/LibwallySwift.xcframework
  fi
fi

if [ $device == 1 ]; then
  cd CLibWally/libwally-core
  set +v
  if [ ! -d "build" ] || [ $clean == 1 ]; then
    echo "Configure and cross-compile for the device..."
    set -v
    export CFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
    export CXXFLAGS="-O3 -arch arm64 -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"
    mkdir -p build
    ./configure --disable-shared --host=aarch64-apple-darwin --enable-static --disable-elements
    if [ $clean == 1 ]; then
      make clean
    fi
  fi
  make
  set +v
  cd $PROJ_DIRECTORY
  xcodebuild archive -scheme LibWally -destination "generic/platform=iOS" -archivePath ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
  if [ $simulator != 1 ]; then
    set -v
    xcodebuild -create-xcframework \
      -framework ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-iOS.xcarchive/Products/Library/Frameworks/LibWally.framework \
      -output ${BIN_OUTPUT_DIRECTORY}/LibwallySwift.xcframework
  fi
fi

set +v
if [ $device == 1 ] && [ $simulator == 1 ]; then
  echo "Combine simulator and device libraries..."
  set -v

  rm -rf ${BIN_OUTPUT_DIRECTORY}/LibwallySwift.xcframework

  xcodebuild -create-xcframework \
    -framework ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-iOS.xcarchive/Products/Library/Frameworks/LibWally.framework \
    -framework ${BIN_OUTPUT_DIRECTORY}/LibwallySwift-Sim.xcarchive/Products/Library/Frameworks/LibWally.framework \
    -output ${BIN_OUTPUT_DIRECTORY}/LibwallySwift.xcframework
fi

set +v
echo "Done"

#!/usr/bin/env sh
set -e # abort if any command fails

BIN_OUTPUT_DIRECTORY="`pwd`/build"

rm -rf $BIN_OUTPUT_DIRECTORY

git submodule update --init --recursive

xcodebuild archive -scheme LibWally \
  -destination "generic/platform=iOS Simulator" \
  -archivePath ${BIN_OUTPUT_DIRECTORY}/LibWally-Sim \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# We want to clean the libwally-core static build files for simulator so we can
# build the ones for device.
pushd CLibWally/libwally-core
  make clean
  rm -rf $(pwd)/build
popd

xcodebuild archive -scheme LibWally \
  -destination "generic/platform=iOS" \
  -archivePath ${BIN_OUTPUT_DIRECTORY}/LibWally-iOS \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework ${BIN_OUTPUT_DIRECTORY}/LibWally-iOS.xcarchive/Products/Library/Frameworks/LibWally.framework \
  -framework ${BIN_OUTPUT_DIRECTORY}/LibWally-Sim.xcarchive/Products/Library/Frameworks/LibWally.framework \
  -output ${BIN_OUTPUT_DIRECTORY}/LibWally.xcframework

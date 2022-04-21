#!/usr/bin/env sh
set -e # abort if any command fails

if [[ -f "${HOME}/.bash_profile" ]]; then
  source "${HOME}/.bash_profile"
fi

export PATH=$PATH:/opt/homebrew/bin/
export PYTHON="/usr/bin/python3"

cd CLibWally/libwally-core
pushd src/secp256k1
  # Latest commit used in Bitcoin Core:
  # https://github.com/bitcoin/bitcoin/commits/master/src/secp256k1
  git checkout 8746600eec5e7fcd35dabd480839a3a4bdfee87b || exit 1
popd
sh ./tools/autogen.sh

cd $PROJECT_DIR

if [[ ${ACTION:-build} = "build" ]]; then
  if [[ $PLATFORM_NAME = "macosx" ]]; then
    TARGET_OS="darwin"
  elif [[ $PLATFORM_NAME = "iphonesimulator" ]]; then
    TARGET_OS="iphonesimulator"
  else
    TARGET_OS="ios"
  fi

  if [[ $CONFIGURATION = "Debug" ]]; then
    CONFIGURATION="debug"
  else
    CONFIGURATION="release"
  fi

  ARCHES=()
  EXECUTABLES=()
  for ARCH in $ARCHS
  do
    ARCHES+=("-arch $ARCH")

    TARGET_ARCH=$ARCH
    if [[ $TARGET_ARCH = "arm64" ]]; then
      TARGET_ARCH="aarch64"
    fi

    pushd "CLibWally/libwally-core"
      export CFLAGS="-O3 ${ARCHES[@]} -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk ${PLATFORM_NAME} --show-sdk-path`"
      export CXXFLAGS="-O3 ${ARCHES[@]} -fembed-bitcode -mios-version-min=11.0 -isysroot `xcrun -sdk ${PLATFORM_NAME} --show-sdk-path`"

      ./configure --disable-shared --host="${TARGET_ARCH}-apple-${TARGET_OS}" --enable-static --disable-elements --enable-standard-secp
      make
    popd
  done
elif [[ $ACTION = "clean" ]]; then
  pushd "CLibWally/libwally-core"
    make clean
  popd
fi

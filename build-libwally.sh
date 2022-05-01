#!/usr/bin/env sh
set -e # abort if any command fails

export PATH=$PATH:/opt/homebrew/bin/
export PYTHON="/usr/bin/python3"

cd CLibWally/libwally-core

# Switch to vanilla libsecp256k1, rather than the more experimental libsecp256k1-zkp.
# Since libsecp256k1-zkp is rebased on vanilla libsecp256k1, we can simply checkout
# a common commit.
pushd src/secp256k1
  # Latest commit used in Bitcoin Core:
  # https://github.com/bitcoin/bitcoin/commits/master/src/secp256k1
  git checkout 8746600eec5e7fcd35dabd480839a3a4bdfee87b || exit 1
popd

BUILD_DIR="$(pwd)/build"

build() {
  SDK_NAME=$1 # iphonesimulator, iphoneos
  HOST=$2 # 'aarch64-apple-darwin' or 'x86_64-apple-darwin'
  EXTRA_CFLAGS=$3 # '-arch arm64 -mios...'
  CC="$(xcrun --sdk $SDK_NAME -f clang) -isysroot $(xcrun --sdk $SDK_NAME --show-sdk-path)"
  CC_FOR_BUILD="$(xcrun --sdk macosx -f clang) -isysroot $(xcrun --sdk macosx --show-sdk-path)"

  ./configure --disable-shared --host=$HOST --enable-static --disable-elements --enable-standard-secp \
    CC="$CC $EXTRA_CFLAGS" \
    CPP="$CC $EXTRA_CFLAGS -E" \
    CC_FOR_BUILD="$CC_FOR_BUILD" \
    CPP_FOR_BUILD="$CC_FOR_BUILD -E" \

  make

  SDK_DIR="${BUILD_DIR}/${SDK_NAME}"
  mkdir -p "${SDK_DIR}"

  cp src/.libs/libwallycore.a "${SDK_DIR}/libwallycore-$HOST.a"
  cp src/secp256k1/.libs/libsecp256k1.a "${SDK_DIR}/libsecp256k1-$HOST.a"

  make clean
}

if [[ ${ACTION:-build} = "build" || $ACTION = "install" ]]; then
  sh ./tools/autogen.sh

  if [[ $PLATFORM_NAME = "macosx" ]]; then
    TARGET_OS="macos"
  elif [[ $PLATFORM_NAME = "iphonesimulator" ]]; then
    TARGET_OS="ios-simulator"
  else
    TARGET_OS="ios"
  fi

  if [[ $CONFIGURATION = "Debug" ]]; then
    CONFIGURATION="debug"
  else
    CONFIGURATION="release"
  fi

  ARCHES=()
  LIBWALLYCORE_EXECUTABLES=()
  LIBSECP256K1_EXECUTABLES=()
  for ARCH in $ARCHS
  do
    TARGET_ARCH=$ARCH
    if [[ $TARGET_ARCH = "arm64" ]]; then
      TARGET_ARCH="aarch64"
    fi

    build ${PLATFORM_NAME} ${TARGET_ARCH}-apple-darwin "-arch ${ARCH} -m${TARGET_OS}-version-min=7.0 -fembed-bitcode"
    LIBWALLYCORE_EXECUTABLES+=("${BUILD_DIR}/${PLATFORM_NAME}/libwallycore-${TARGET_ARCH}-apple-darwin.a")
    LIBSECP256K1_EXECUTABLES+=("${BUILD_DIR}/${PLATFORM_NAME}/libsecp256k1-${TARGET_ARCH}-apple-darwin.a")
  done

  xcrun --sdk $PLATFORM_NAME lipo -create "${LIBWALLYCORE_EXECUTABLES[@]}" -output "${BUILD_DIR}/LibWallyCore"
  xcrun --sdk $PLATFORM_NAME lipo -create "${LIBSECP256K1_EXECUTABLES[@]}" -output "${BUILD_DIR}/libsecp256k1"
elif [[ $ACTION = "clean" ]]; then
  make clean
fi

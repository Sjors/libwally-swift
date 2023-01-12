#!/usr/bin/env sh
set -e # abort if any command fails

export PATH=$PATH:/opt/homebrew/bin/
export PYTHON="/usr/bin/python3"

cd CLibWally/libwally-core

# Switch to vanilla libsecp256k1, rather than the more experimental libsecp256k1-zkp.
# Since libsecp256k1-zkp is rebased on vanilla libsecp256k1, we can simply checkout
# a common commit.
pushd src/secp256k1
  # Latest tagged release used in Bitcoin Core:
  # https://github.com/bitcoin/bitcoin/commits/master/src/secp256k1
  git remote | grep bitcoin-core || git remote add bitcoin-core https://github.com/bitcoin-core/secp256k1.git
  git fetch bitcoin-core --tags
  git checkout v0.2.0 || exit 1
  git rev-parse HEAD | grep 21ffe4b22a9683cf24ae0763359e401d1284cc7a || exit 1
popd

BUILD_DIR="$(pwd)/build"

build() {
  SDK_NAME=$1 # iphonesimulator, iphoneos
  HOST=$2 # 'aarch64-apple-darwin' or 'x86_64-apple-darwin'
  EXTRA_CFLAGS=$3 # '-arch arm64 -mios...'
  CC="$(xcrun --sdk $SDK_NAME -f clang) -isysroot $(xcrun --sdk $SDK_NAME --show-sdk-path)"
  CC_FOR_BUILD="$(xcrun --sdk macosx -f clang) -isysroot $(xcrun --sdk macosx --show-sdk-path)"

  sh ./tools/autogen.sh
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
  NEEDS_LIPO=false

  for ARCH in $ARCHS
  do
    TARGET_ARCH=$ARCH
    if [[ $TARGET_ARCH = "arm64" ]]; then
      TARGET_ARCH="aarch64"
    fi

    LIBWALLY_DIR="${BUILD_DIR}/${PLATFORM_NAME}/libwallycore-${TARGET_ARCH}-apple-darwin.a"
    SECP_DIR="${BUILD_DIR}/${PLATFORM_NAME}/libsecp256k1-${TARGET_ARCH}-apple-darwin.a"

    # If we haven't built our static library, let's go ahead and build it. Else, we can probably just not try and build at all.
    if [ ! -f $LIBWALLY_DIR ] || [ ! -f $SECP_DIR ]
    then
      echo "DEBUG:: File not found, let's build!"
      build ${PLATFORM_NAME} ${TARGET_ARCH}-apple-darwin "-arch ${ARCH} -m${TARGET_OS}-version-min=7.0 -fembed-bitcode"

      # Tracks our list of executables so we know the static libraries we need to lipo later
      LIBWALLYCORE_EXECUTABLES+=($LIBWALLY_DIR)
      LIBSECP256K1_EXECUTABLES+=($SECP_DIR)

      # Something changed, we should lipo later.
      NEEDS_LIPO=true
    fi
  done

  # If nothing changed, we can just not try lipo at all and skip.
  if [ "$NEEDS_LIPO" = true ] ; then
    xcrun --sdk $PLATFORM_NAME lipo -create "${LIBWALLYCORE_EXECUTABLES[@]}" -output "${BUILD_DIR}/LibWallyCore"
    xcrun --sdk $PLATFORM_NAME lipo -create "${LIBSECP256K1_EXECUTABLES[@]}" -output "${BUILD_DIR}/libsecp256k1"
  fi
elif [[ $ACTION = "clean" ]]; then
  make clean
fi

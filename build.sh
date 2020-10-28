#! /bin/sh

## ./build.sh @<toolchain>
## ios arm64: ./build.sh ios.arm64
## ios simulator: ./build.sh ios.simulator.x86_64
## android arm64: ./build.sh android.arm64
## android emulator: ./build.sh android.x86_64
	
set -e	
set -u	

TOOLCHAIN="${1:-ios.arm64}"
MODULE_NAME="8-completed"
SHARED_NAME="libmain.so"
BINARY_NAME="ReveryWorkshop"

if [ ! -d "$TOOLCHAIN.esy.lock" ]; then
  esy
  esy generate $toolchain
fi

esy @$TOOLCHAIN
TARGET_FOLDER=$(esy @$TOOLCHAIN sh -c 'echo $cur__target_dir/default.$ESY_TOOLCHAIN')
	
# uses a temporary folder to avoid

if [ "$TOOLCHAIN" == "android.arm64" ] || [ "$TOOLCHAIN" == "android.x86_64" ]; then
  ARCH="arm64-v8a"
  if [ "$TOOLCHAIN" == "android.x86_64" ]; then
    ARCH="x86_64"
  fi

  esy @$TOOLCHAIN dune build -x $TOOLCHAIN --profile=android 8-completed.so
  cp "$TARGET_FOLDER/${MODULE_NAME}.so" Android/app/libs/$ARCH/$SHARED_NAME
fi
if [ "$TOOLCHAIN" == "ios.arm64" ] || [ "$TOOLCHAIN" == "ios.simulator.x86_64" ]; then
  cp "$TARGET_FOLDER/${MODULE_NAME}.exe" Xcode/ReveryWorkshop
fi


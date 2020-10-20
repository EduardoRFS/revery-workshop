#! /bin/sh

## ./build.sh @<toolchain>
## arm64: ./build.sh ios.arm64
## simulator: ./build.sh ios.simulator.x86_64
	
set -e	
set -u	

TOOLCHAIN="${1:-ios.arm64}"
SOURCE_BINARY_NAME="8-completed"
BINARY_NAME="ReveryWorkshop"

esy
esy generate $TOOLCHAIN
esy @$TOOLCHAIN
	
INSTALL_FOLDER=$(esy @$TOOLCHAIN sh -c 'echo $cur__target_dir/install/default.$ESY_TOOLCHAIN')
	
# uses a temporary folder to avoid

cd Xcode
cp $INSTALL_FOLDER/bin/* .
cp $SOURCE_BINARY_NAME $BINARY_NAME

copy_dylib () {
  FROM="$(otool -L $BINARY_NAME | grep $1 | awk '{print $1}')"
  cp $FROM $1.dylib
  install_name_tool -id @executable_path/$1.dylib $1.dylib
  install_name_tool -change $FROM @executable_path/$1.dylib $BINARY_NAME
}
patch_dylib () {
  FROM="$(otool -L $1.dylib| grep $2 | awk '{print $1}')"  
  install_name_tool -change $FROM @executable_path/$2.dylib $1.dylib
}

copy_dylib libcrypto
copy_dylib libssl
patch_dylib libssl libcrypto
copy_dylib libharfbuzz
# copy_dylib libSDL2
	
cd ..

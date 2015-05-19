#!/bin/sh
########################################################################
##################### copyright by smileEvday ##########################
##################### smileEvday.cnblogs.com ###########################
########################################################################

# FFMpeg, SDK版本号
SOURCEDIR="ffmpeg-0.11.5"
SDKVERSION="8.3"
PLATFORM="iPhoneOS"

DEPLOYMENT_TARGET="6.0"


# 源文件路径
BUILDDIR=`pwd`/"build"

# 获取xcode开发环境安装路径
DEVELOPER="/Applications/Xcode.app/Contents/Developer"
ARCHS="arm64 armv7 armv7s"

cd ${SOURCEDIR}

make clean

for ARCH in ${ARCHS}
do

    echo "building $ARCH..."
    mkdir -p "${BUILDDIR}/$ARCH"

    ./configure \
    --cc="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" \
    --as="/usr/local/bin/gas-preprocessor.pl" \
    --sysroot="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.3.sdk" \
    --target-os=darwin \
    --arch="${ARCH}" \
    --extra-cflags="-arch ${ARCH}" \
    --extra-ldflags="-arch ${ARCH}" \
    --prefix="${BUILDDIR}/${ARCH}" \
    --enable-cross-compile \
    --enable-nonfree \
    --enable-gpl \
    --disable-armv5te \
    --disable-swscale-alpha \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-asm \
    --disable-debug
    make && make install && make clean
     
done

########################################################################################################################
##################################################### 生成fat库 #########################################################
########################################################################################################################
mkdir -p ${BUILDDIR}/universal/lib
cd ${BUILDDIR}/armv7/lib

for file in *.a
do

cd ${BUILDDIR}
xcrun -sdk iphoneos lipo -output universal/lib/$file  -create -arch armv7 armv7/lib/$file -arch armv7s armv7s/lib/$file -arch arm64 arm64/lib/$file
echo "Universal $file created."

done
cp -r ${BUILDDIR}/armv7/include ${BUILDDIR}/universal/

echo "Done."
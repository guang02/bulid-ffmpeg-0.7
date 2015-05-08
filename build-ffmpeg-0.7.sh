#!/bin/sh

########################################################################
##################### copyright by smileEvday ##########################
##################### smileEvday.cnblogs.com ###########################
########################################################################

# FFMpeg，SDK版本号
VERSION="0.7.4"
SOURCE="ffmpeg-0.7.4"
SDKVERSION="8.3"

#最低支持的SDK版本号
MINSDKVERSION="7.0"

# 源文件路径
SRCDIR=$(pwd)
BUILDDIR="${SRCDIR}/build"
mkdir -p $BUILDDIR

# 获取xcode开发环境安装路径
DEVELOPER=`xcode-select -print-path`

# if [ ! -r $SOURCE ]
# then
# 	echo 'FFmpeg source not found. Trying to download...'
# 	curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj \
# 		|| exit 1
# fi

# 要编译的架构列表
ARCHS="armv7 armv7s i386"
for ARCH in ${ARCHS}
do
	if [ "${ARCH}" == "i386" ];
	then
		PLATFORM="iPhoneSimulator"
        EXTRA_CFLAGS="-arch i386"
		EXTRA_LDFLAGS="-arch i386 -mfpu=neon"
		EXTRA_CONFIG="--arch=i386 --cpu=i386"
	else
		PLATFORM="iPhoneOS"
        EXTRA_CFLAGS="-arch ${ARCH} -mfloat-abi=softfp"
		EXTRA_LDFLAGS="-arch ${ARCH} -mfpu=neon -mfloat-abi=softfp"
		EXTRA_CONFIG="--arch=arm --cpu=cortex-a9 --disable-armv5te"
	fi
	
	make clean

	# you can do any clip here 
	./configure --prefix="${BUILDDIR}/${ARCH}" 		\
				--disable-doc 						\
				--disable-ffmpeg 					\
				--disable-ffplay 					\
				--disable-ffserver 					\
				--disable-ffprobe					\
				--enable-cross-compile 				\
				--enable-pic 						\
				--disable-asm						\
				--target-os=darwin 					\
				${EXTRA_CONFIG}						\
				--cc="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" 										\
				--as="/usr/bin/gas-preprocessor.pl"																				\
				--sysroot="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk" 				\
				--extra-cflags="-miphoneos-version-min=${MINSDKVERSION} ${EXTRA_CFLAGS}"														\
				--extra-ldflags="-miphoneos-version-min=${MINSDKVERSION} ${EXTRA_LDFLAGS} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"

    make && make install && make clean
	 
done

########################################################################################################################
##################################################### 生成fat库 #########################################################
########################################################################################################################
mkdir -p ${BUILDDIR}/universal/lib
cd ${BUILDDIR}/armv7/lib

for file in *.a
do

cd ${SRCDIR}/build
xcrun -sdk iphoneos lipo -output universal/lib/$file  -create -arch armv7 armv7/lib/$file -arch armv7s armv7s/lib/$file -arch i386 i386/lib/$file
echo "Universal $file created."

done
cp -r ${BUILDDIR}/armv7/include ${BUILDDIR}/universal/

echo "Done."
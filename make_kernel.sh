#!/bin/bash

OUT_DIR=$PWD/output
KERNEL_DIR=$PWD
NC=$(nproc --all)
BUILD_START=$(date +"%s")
TOOLCHAIN=$PWD/toolchain
# Color Code Script
Black='\e[0;30m' # Black
Red='\e[0;31m' # Red
Green='\e[0;32m' # Green
Yellow='\e[0;33m' # Yellow
Blue='\e[0;34m' # Blue
Purple='\e[0;35m' # Purple
Cyan='\e[0;36m' # Cyan
White='\e[0;37m' # White
nocol='\033[0m' # Default


# Check Toolchain
if ! [ -a $TOOLCHAIN ];
then
git clone https://bitbucket.org/UBERTC/aarch64-linux-android-4.9.git toolchain/arm64
git clone https://bitbucket.org/UBERTC/arm-eabi-4.9.git toolchain/arm32
fi
# Clean
if [[ $1 = -c ]]
then
make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
exit 1
fi

# Build 32 Bit 
if [[ $1 = -o ]]
then
	KERNEL=$KERNEL_DIR/output/arch/arm/boot/zImage-dtb
	export ARCH=arm
	export SUBARCH=arm
	export KBUILD_BUILD_USER="YourName"
	export KBUILD_BUILD_HOST="YourBuildHost"
	export CROSS_COMPILE="$KERNEL_DIR/toolchain/arm32/bin/arm-eabi-"
	echo -e "$Green***********************************************"
	echo "            Compiling 32 Bit kernel "
	echo -e "***********************************************$nocol"
	make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
	make O=$OUT_DIR msm8937-perf_defconfig
	make O=$OUT_DIR -j$NC
fi

# Build 64 Bit 
if [[ $1 = -b ]]
then
	KERNEL=$KERNEL_DIR/output/arch/arm64/boot/Image.gz-dtb
	export ARCH=arm64
	export SUBARCH=arm64
	export KBUILD_BUILD_USER="YourName"
	export KBUILD_BUILD_HOST="YourBuildHost"
	export CROSS_COMPILE="$KERNEL_DIR/toolchain/arm64/bin/aarch64-linux-android-"
	export CROSS_COMPILE_ARM32="$KERNEL_DIR/toolchain/arm32/bin/arm-eabi-"

	echo -e "$Green***********************************************"
	echo "         	  Compiling 64 Bit Kernel "
	echo -e "***********************************************$nocol"
	make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
	make O=$OUT_DIR msm8937-perf_defconfig
	make O=$OUT_DIR -j$NC
fi

if ! [ -a $KERNEL ];
then
echo -e "$Red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi

if [ -z $1 ]
then
	echo " syntax: ./make_kernel.sh <option>"
	echo "   options   -o      For 32 Bit Build "
	echo "             -b      For 64 Bit Build "
	echo " 		   -c 	   For Clean Workdir"
else
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$Yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
fi


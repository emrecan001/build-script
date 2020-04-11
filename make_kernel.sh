#!/bin/bash


OUT_DIR=$PWD/output
KERNEL_DIR=$PWD
NC=$(nproc --all)
BUILD_START=$(date +"%s")
TOOLCHAIN=$PWD/toolchain
TOOLCHAINS=$PWD/toolchains
CONFIG=$2
USER=$3
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
setup_environment ()
{
clear
echo -e "$Blue********************************************"
echo -e " Cloning Resources And Installing Packages"
echo -e "********************************************$nocol"
echo
sudo apt update
sudo dpkg --add-architecture i386
sudo apt update
sudo apt-get install -y git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev zlib1g-dev:i386 g++-multilib python-networkx libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip
git clone https://bitbucket.org/UBERTC/aarch64-linux-android-4.9.git toolchain/arm64
git clone https://bitbucket.org/UBERTC/arm-eabi-4.9.git toolchain/arm32
git clone https://github.com/romman001/snapdragon_clang_compiler.git -b android-8.0 clang
echo
echo
echo -e "$Green!!!!!!!! Done !!!!!!!!$nocol"
exit 1
}

# Clean
if [[ $1 = -w ]]
then
make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
exit 1
fi


# Build 32 Bit
compile_arm32 ()
{
KERNEL=$KERNEL_DIR/output/arch/arm/boot/zImage-dtb
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="$3"
export KBUILD_BUILD_HOST="BuildHost"
export CROSS_COMPILE_ARM32="$KERNEL_DIR/toolchain/arm32/bin/arm-eabi-"
clear
echo -e "$Green***********************************************"
echo "            Compiling 32 Bit Kernel "
echo -e "***********************************************$nocol"
make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
make O=$OUT_DIR $CONFIG
make O=$OUT_DIR -j$NC


if ! [ -a $KERNEL ];
then
echo -e "$Red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}



# Build 64 Bit 
compile_arm64 ()
{
KERNEL=$KERNEL_DIR/output/arch/arm64/boot/Image.gz-dtb
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="$3"
export KBUILD_BUILD_HOST="BuildHost"
export CROSS_COMPILE="$KERNEL_DIR/toolchain/arm64/bin/aarch64-linux-android-"
export CROSS_COMPILE_ARM32="$KERNEL_DIR/toolchain/arm32/bin/arm-eabi-"
clear
echo -e "$Green***********************************************"
echo "         	  Compiling 64 Bit Kernel "
echo -e "***********************************************$nocol"
make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
make O=$OUT_DIR $CONFIG
make O=$OUT_DIR -j$NC


if ! [ -a $KERNEL ];
then
echo -e "$Red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}

# Compile With Clang
compile_clang ()
{
KERNEL=$KERNEL_DIR/output/arch/arm64/boot/Image.gz-dtb
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="$3"
export KBUILD_BUILD_HOST="BuildHost"
export LD_LIBRARY_PATH="$KERNEL_DIR/clang/toolchains/llvm-Snapdragon_LLVM_for_Android_8.0/prebuilt/linux-x86_64/lib/"
export REAL_CC="$KERNEL_DIR/clang/toolchains/llvm-Snapdragon_LLVM_for_Android_8.0/prebuilt/linux-x86_64/bin/clang"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="$KERNEL_DIR/toolchain/arm64/bin/aarch64-linux-android-"
export CROSS_COMPILE_ARM32="$KERNEL_DIR/toolchain/arm32/bin/arm-eabi-"
clear
echo -e "$Green***********************************************"
echo "            Compiling Kernel With Clang "
echo -e "***********************************************$nocol"
make O=$OUT_DIR clean && make O=$OUT_DIR mrproper
make O=$OUT_DIR $CONFIG
make O=$OUT_DIR -j$NC


if ! [ -a $KERNEL ];
then
echo -e "$Red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}


if [[ $1 = -r ]]
then
setup_environment
fi
if [[ $1 = -o ]]
then
compile_arm32
fi
if [[ $1 = -b ]]
then
compile_arm64
fi
if [[ $1 = -c ]]
then
compile_clang
fi


if [ -z $1 ]
then
	echo -e "$Blue./make_kernel.sh <option> <defconfig>$nocol"
	echo -e "$Green -r      For Clone Resources and Install Packages$nocol"
 	echo -e "$Yellow -w      For Clean Workdir$nocol"
	echo -e "$Blue -o      For 32 Bit Build$nocol"
	echo -e "$Purple -b      For 64 Bit Build$nocol"
  	echo -e "$Cyan -c      For Build With Clang$nocol"
fi


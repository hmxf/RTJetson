#!/bin/bash

# Red is 1
# Green is 2
# Reset is sgr0

BUILD_DIR=~/RTJetsonBuild/R35.3.1
cd $BUILD_DIR

tput setaf 2
echo "Extract files"
tput sgr0
sudo tar xpf Jetson_Linux_R35.3.1_aarch64.tbz2 
cd Linux_for_Tegra/rootfs/ 
sudo tar xpf ../../Tegra_Linux_Sample-Root-Filesystem_R35.3.1_aarch64.tbz2
cd ../../ 
tar -xvf aarch64--glibc--stable-final.tar.gz
sudo tar -xjf public_sources.tbz2
tar -xjf Linux_for_Tegra/source/public/kernel_src.tbz2

tput setaf 2
echo "Apply PREEMPT-RT patches"
tput sgr0
cd kernel/kernel-5.10/ 
./scripts/rt-patch.sh apply-patches 

tput setaf 2
echo "Compile kernel"
tput sgr0
TEGRA_KERNEL_OUT=kernel_out 
mkdir $TEGRA_KERNEL_OUT 
export CROSS_COMPILE=$BUILD_DIR/bin/aarch64-buildroot-linux-gnu-
make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig

tput setaf 2
echo "Confirm if these config options are chosen."
echo "Kernel Features -> Preemption  Model: Fully Preemptible Kernel (RT)"
echo "Kernel Features -> Timer frequency: 1000 HZ "
echo "If not, choose them in menuconfig interface."
echo "Else, quit menuconfig and compile will auto start."
echo "Press Return Key to continue........"
tput sgr0
read
make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig 
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j$(nproc) 

tput setaf 2
echo "Copying results"
tput sgr0
sudo cp kernel_out/arch/arm64/boot/Image $BUILD_DIR/Linux_for_Tegra/kernel/Image
sudo cp kernel_out/arch/arm64/boot/Image.gz $BUILD_DIR/Linux_for_Tegra/kernel/Image.gz
sudo cp -r kernel_out/arch/arm64/boot/dts/nvidia/* $BUILD_DIR/Linux_for_Tegra/kernel/dtb/ 
sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$BUILD_DIR/Linux_for_Tegra/rootfs/ 
cd $BUILD_DIR/Linux_for_Tegra/rootfs/ 
sudo tar --owner root --group root -cjf kernel_supplements.tbz2 lib/modules 
sudo mv kernel_supplements.tbz2  ../kernel/ 

tput setaf 2
echo "Appling binaries"
tput sgr0
cd .. 
sudo ./apply_binaries.sh

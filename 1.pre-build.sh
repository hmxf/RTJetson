#!/bin/bash

# Red is 1
# Green is 2
# Reset is sgr0

tput setaf 2
echo "Install Dependencies"
tput sgr0
sudo apt update && sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y build-essential bc libncurses5-dev lbzip2 pkg-config flex bison libssl-dev qemu-user-static

BUILD_DIR=~/RTJetsonBuild/R35.3.1
tput setaf 2
echo "Create build folder to $BUILD_DIR"
tput sgr0
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi
cd $BUILD_DIR

tput setaf 2
echo "Manually download files from links below since NVIDIA's website need login..."
echo "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/jetson_linux_r35.3.1_aarch64.tbz2"
echo "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/tegra_linux_sample-root-filesystem_r35.3.1_aarch64.tbz2"
echo "https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/sources/public_sources.tbz2"
echo "https://developer.nvidia.com/embedded/jetson-linux/bootlin-toolchain-gcc-93"
echo "and put them into $BUILD_DIR folder"
tput sgr0

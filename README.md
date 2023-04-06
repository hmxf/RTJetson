# RT Jetson

Preempt-RT Kernel Build Guide for NVIDIA Development Board

The system used to build the image is Ubuntu 20.04.6 LTS, which is recommended because the current version of L4T is based on Ubuntu 20.04.

- Jetpack version: 5.1.1
- Jetson Linux version: 35.3.1
- Linux Kernel version: 5.10

This guide and this [Reference](https://forums.developer.nvidia.com/t/preempt-rt-patches-for-jetson-nano/72941/10) only tested on the Xavier developer kit and Jetson Nano development board.

Since L4T and related source codes are common to all NVIDIA development boards, so this tutorial is theoretically applicable to all NVIDIA development boards supported by L4T.

The only thing to note is that a specific version of L4T and related source codes only support the development platforms supported by this version of L4T, and cross-version hardware support is hard to guarantee.

## Install Dependencies

	sudo apt update && sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
	sudo apt install -y build-essential bc libncurses5-dev lbzip2 pkg-config flex bison libssl-dev qemu-user-static

## Create build folder

	mkdir ~/nvidia-rt 
	cd ~/nvidia-rt 

## Download the following files in the nvidia-rt folder:

- [L4T Jetson Driver Package](https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/jetson_linux_r35.3.1_aarch64.tbz2)

- [L4T Sample Root File System](https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/tegra_linux_sample-root-filesystem_r35.3.1_aarch64.tbz2)

- [L4T Sources](https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/sources/public_sources.tbz2)

- [GCC Tool Chain for 64-bit BSP](https://developer.nvidia.com/embedded/jetson-linux/bootlin-toolchain-gcc-93)


## Extract files

	sudo tar xpf Jetson_Linux_R35.3.1_aarch64.tbz2 
	cd Linux_for_Tegra/rootfs/ 
	sudo tar xpf ../../Tegra_Linux_Sample-Root-Filesystem_R35.3.1_aarch64.tbz2
	cd ../../ 
	tar -xvf aarch64--glibc--stable-final.tar.gz
	sudo tar -xjf public_sources.tbz2
	tar -xjf Linux_for_Tegra/source/public/kernel_src.tbz2

## Apply PREEMPT-RT patches

	cd kernel/kernel-5.10/ 
	./scripts/rt-patch.sh apply-patches 

## Compile kernel

	TEGRA_KERNEL_OUT=kernel_out 
	mkdir $TEGRA_KERNEL_OUT 
	export CROSS_COMPILE=~/nvidia-rt/bin/aarch64-buildroot-linux-gnu-
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig 
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig 

## This option should already be selected:

	Kernel Features -> Preemption  Model: Fully Preemptible Kernel (RT)

## You can modify other options for your kernel, like the timer frequency (or anything you need):

	Kernel Features -> Timer frequency: 1000 HZ 

## After saving the configuration and exiting, start the kernel compilation

	make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j$(nproc) 

## Copy results

	sudo cp kernel_out/arch/arm64/boot/Image ~/nvidia-rt/Linux_for_Tegra/kernel/Image
	sudo cp kernel_out/arch/arm64/boot/Image.gz ~/nvidia-rt/Linux_for_Tegra/kernel/Image.gz
	sudo cp -r kernel_out/arch/arm64/boot/dts/nvidia/* ~/nvidia-rt/Linux_for_Tegra/kernel/dtb/ 
	sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=~/nvidia-rt/Linux_for_Tegra/rootfs/ 
	cd ~/nvidia-rt/Linux_for_Tegra/rootfs/ 
	sudo tar --owner root --group root -cjf kernel_supplements.tbz2 lib/modules 
	sudo mv kernel_supplements.tbz2  ../kernel/ 

## Apply binaries

	cd .. 
	sudo ./apply_binaries.sh

## Choose flash method and flash compiled system image

- Generate System Image for SD flash

    This method is mostly used in the case of directly using the SD card as the boot device and is not limited to Xavier, it can also support other NVIDIA development boards in theory, such as Jetson Nano.

	    cd tools
	    sudo ./jetson-disk-image-creator.sh -o nvidia-rt.img -b jetson-agx-xavier-devkit -d SD
        sudo ./create-jetson-nano-sd-card-image.sh -o jetson_nano.img -s 12G -r 100

- Set AGX Xavier at Recovery Mode and flash image to Xavier's onboard EMMC

	    cd tools
        sudo ./flash.sh jetson-agx-xavier-devkit mmcblk0p1

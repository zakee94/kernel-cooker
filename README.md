Kernel Cooker
=============

This script need to be placed in the root of your kernel directory.

To build:
	export CROSS_COMPILE=/path/to/toolchain
	export ARCH=$arch #arm / arm64
	chmod +x cooker.sh dtbToolCM
	./cooker.sh
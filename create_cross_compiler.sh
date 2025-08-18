#!/bin/bash
# create_cross_compiler.sh
# ------------------------
# This script sets up and builds a cross-compiler toolchain for i686-elf on Ubuntu.
# It downloads, decompresses, configures, and installs binutils and GCC into a local opt/cross directory.
# Intended for OS development and kernel projects.

# These commands were obtained from https://wiki.osdev.org/GCC_Cross-Compiler"

# Create and enter cross-compiler directory
mkdir -p cross-compiler
cd cross-compiler

# Set up environment variables
source set_env.sh

# Download sources
wget --show-progress https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz
wget --show-progress https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz

echo "Decompressing Binutils and GCC..."
tar -xf binutils-2.35.tar.xz
tar -xzf gcc-10.2.0.tar.gz
echo "Decompression finished successfully"

echo "Building and installing Binutils..."
# Build and install binutils
mkdir -p build-binutils
cd build-binutils
../binutils-2.35/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
cd ..
echo "Binutils built and installed successfully"

echo "Building and installing GCC..."
# Build and install gcc
mkdir -p build-gcc
cd build-gcc
../gcc-10.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
make all-gcc
make all-target-libgcc
make all-target-libstdc++-v3
make install-gcc
make install-target-libgcc
make install-target-libstdc++-v3
echo "GCC built and installed successfully"

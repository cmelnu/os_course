#!/bin/bash
# create_env.sh
# -------------
# This script sets up environment variables for building and using a cross-compiler toolchain (i686-elf).
# It determines the script's directory, sets the installation prefix, target architecture, and updates PATH.
# Intended for use in an OS development environment on Ubuntu 20.04 LTS.

# Set up environment variables
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PREFIX="$SCRIPT_DIR/cross-compiler/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
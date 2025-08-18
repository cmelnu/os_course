# os_course 🚀🖥️

This repository contains code and resources for a **Kernel Development Course** offered on [Udemy](https://www.udemy.com/course/developing-a-multithreaded-kernel-from-scratch/).

## Features

- ⚙️ Includes scripts for setting up the build environment and creating a cross-compiler toolchain (`set_env.sh`, `create_cross_compiler.sh`).

- 🧑‍💻 Learn how to build a multithreaded operating system kernel from scratch!
- 🛠️ Includes bootloader, low-level assembly, and C code for kernel development.
- 📚 Perfect for students and enthusiasts interested in OS internals and systems.
- 🗂️ Organized project structure: `src/boot/` for bootloader, `bin/` for binaries, `build/` for build files, and `docs/` for Sphinx documentation.
- 📝 Sphinx documentation with sections on real mode, disk access, CHS/LBA, and protected mode.
- 🏗️ Modern build system using CMake; bootloader assembled with NASM.
- 🛡️ Bootloader demonstrates transition from real mode to protected mode, GDT setup, and A20 line enabling.

## System Compatibility

This project is developed and tested on **Ubuntu 20.04 LTS (Focal Fossa)**.

## Dependencies

To build and run this project, you need:

- **NASM** (Netwide Assembler): Used to assemble the bootloader (`boot.asm`).
- **CMake**: Modern build system for managing builds and dependencies.
- **QEMU** (optional): Emulator for testing the bootloader binary.

Install on Ubuntu:
```sh
sudo apt update
sudo apt install nasm cmake qemu-system-x86
```

## Directory Structure

```
├── set_env.sh               # Script to set environment variables for cross-compiling
├── create_cross_compiler.sh # Script to download, build, and install binutils and GCC cross-compiler
├── bin/            		 # Output binaries (e.g., boot.bin)
├── build/          		 # Build files (CMake, etc.)
├── docs/           		 # Sphinx documentation
├── src/
│   └── boot/       		 # Bootloader source (boot.asm)
├── CMakeLists.txt  		 # Project build configuration
├── .gitignore      		 # Ignore build and binary files
```

## Building the Bootloader

1. Install NASM and CMake if not already installed.
2. Run:
	 ```sh
	 mkdir build && cd build
	 cmake ..
	 make
	 ```
	 The bootloader binary will be generated at `bin/boot.bin`.

## Running in QEMU

You can test the bootloader with QEMU:
```sh
qemu-system-x86_64 -hda bin/boot.bin
```

## Documentation

- Sphinx docs are in `docs/`. Build with:
	```sh
	cd docs
	make html
	```
- Open `docs/build/index.html` in your browser to view.

## Bootloader Highlights

- Real mode setup and BIOS parameter block reservation
- Disk access and sector reading (INT 13h)
- Global Descriptor Table (GDT) setup for protected mode
- Far jump to protected mode and segment register initialization
- A20 line enabling for access above 1MB

## License

See [LICENSE](LICENSE) for details.
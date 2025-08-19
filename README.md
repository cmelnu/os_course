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


This project is developed and tested on **Ubuntu 20.04 LTS (Focal Fossa)**. You can also use the provided Dockerfile to set up a reproducible build environment.


## Build Environment (Recommended: Docker)

You can build and run this project in a reproducible environment using Docker. The provided `Dockerfile` sets up Ubuntu 20.04 with all required dependencies, including the OSDev cross-compiler toolchain, NASM, CMake, QEMU, and more.

### Build the Docker image:
```sh
docker build -t osdev-kernel-course .
```

### Run the container (mount your workspace):
```sh
docker run -it --rm -v "$PWD":/workspace osdev-kernel-course
```

This will drop you into a shell with all tools pre-installed. You can then build and test the kernel as described below.

## Directory Structure

```
├── set_env.sh               # Script to set environment variables for cross-compiling (legacy)
├── Dockerfile               # Docker build file for reproducible environment and cross-compiler toolchain
├── bin/            		 # Output binaries (e.g., boot.bin)
├── build/          		 # Build files (CMake, etc.)
├── docs/           		 # Sphinx documentation
├── src/
│   └── boot/       		 # Bootloader source (boot.asm)
├── CMakeLists.txt  		 # Project build configuration
├── .gitignore      		 # Ignore build and binary files
```

## Building the Bootloader

1. If using Docker, start the container as described above.
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
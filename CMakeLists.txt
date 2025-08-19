cmake_minimum_required(VERSION 3.10)
project(os_course_kernel ASM)

# Toolchain support
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_C_COMPILER "${CMAKE_SOURCE_DIR}/opt/cross/bin/i686-elf-gcc")
set(CMAKE_ASM_COMPILER "${CMAKE_SOURCE_DIR}/opt/cross/bin/i686-elf-gcc")
set(CMAKE_LINKER "${CMAKE_SOURCE_DIR}/opt/cross/bin/i686-elf-ld")

# Directories
set(BIN_DIR ${CMAKE_SOURCE_DIR}/bin)
set(BUILD_DIR ${CMAKE_SOURCE_DIR}/build)
set(BOOT_SRC ${CMAKE_SOURCE_DIR}/src/boot/boot.asm)
set(KERNEL_SRC ${CMAKE_SOURCE_DIR}/src/kernel.asm)
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/src/linker.ld)

# Build kernel object
add_custom_command(
    OUTPUT ${BUILD_DIR}/kernel.asm.o
    COMMAND nasm -f elf -g ${KERNEL_SRC} -o ${BUILD_DIR}/kernel.asm.o
    DEPENDS ${KERNEL_SRC}
)

# Link kernel object
add_custom_command(
    OUTPUT ${BUILD_DIR}/kernelfull.o
    COMMAND ${CMAKE_LINKER} -g -relocatable ${BUILD_DIR}/kernel.asm.o -o ${BUILD_DIR}/kernelfull.o
    DEPENDS ${BUILD_DIR}/kernel.asm.o
)

# Build kernel binary
add_custom_command(
    OUTPUT ${BIN_DIR}/kernel.bin
    COMMAND ${CMAKE_C_COMPILER} -T ${LINKER_SCRIPT} -o ${BIN_DIR}/kernel.bin -ffreestanding -O0 -nostdlib ${BUILD_DIR}/kernelfull.o
    DEPENDS ${BUILD_DIR}/kernelfull.o ${LINKER_SCRIPT}
)

# Build bootloader binary
add_custom_command(
    OUTPUT ${BIN_DIR}/boot.bin
    COMMAND nasm -f bin ${BOOT_SRC} -o ${BIN_DIR}/boot.bin
    DEPENDS ${BOOT_SRC}
)

# Concatenate boot.bin and kernel.bin into os.bin
add_custom_command(
    OUTPUT ${BIN_DIR}/os.bin
    COMMAND rm -f ${BIN_DIR}/os.bin
    COMMAND dd if=${BIN_DIR}/boot.bin >> ${BIN_DIR}/os.bin
    COMMAND dd if=${BIN_DIR}/kernel.bin >> ${BIN_DIR}/os.bin
    COMMAND dd if=/dev/zero bs=512 count=100 >> ${BIN_DIR}/os.bin
    DEPENDS ${BIN_DIR}/boot.bin ${BIN_DIR}/kernel.bin
)

add_custom_target(all_bins ALL DEPENDS ${BIN_DIR}/os.bin)

# Clean target
add_custom_target(clean-all
    COMMAND rm -f ${BIN_DIR}/* ${BUILD_DIR}/*
    COMMENT "Cleaning all build and binary files"
)

# Sphinx documentation
add_custom_target(docs
    COMMAND make html
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/docs
    COMMENT "Building Sphinx documentation"
)
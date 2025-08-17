cmake_minimum_required(VERSION 3.10)
project(os_course LANGUAGES C ASM)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Add bootloader assembly source
add_custom_command(
    OUTPUT boot.bin
    COMMAND nasm -f bin ${CMAKE_SOURCE_DIR}/boot.asm -o boot.bin
    COMMAND dd if=message.txt >> boot.bin
    COMMAND dd if=/dev/zero bs=512 count=1
    DEPENDS ${CMAKE_SOURCE_DIR}/boot.asm
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building bootloader binary from boot.asm, then zeroing"
)

add_custom_target(bootloader ALL DEPENDS boot.bin)

# Optionally, add tests or other tools here

# Documentation build (optional)
add_custom_target(docs
    COMMAND make html
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/docs
    COMMENT "Building Sphinx documentation"
)

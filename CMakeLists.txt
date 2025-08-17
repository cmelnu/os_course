cmake_minimum_required(VERSION 3.10)
project(os_course LANGUAGES C ASM)

# Directory variables
set(BIN_DIR ${CMAKE_SOURCE_DIR}/bin)
set(BOOT_SRC_DIR ${CMAKE_SOURCE_DIR}/src/boot)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Add bootloader assembly source
add_custom_command(
    OUTPUT ${BIN_DIR}/boot.bin
    COMMAND nasm -f bin ${BOOT_SRC_DIR}/boot.asm -o ${BIN_DIR}/boot.bin
    DEPENDS ${BOOT_SRC_DIR}/boot.asm
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building bootloader binary from boot.asm, then zeroing"
)

add_custom_target(bootloader ALL DEPENDS ${BIN_DIR}/boot.bin)

# Optionally, add tests or other tools here

# Documentation build (optional)
add_custom_target(docs
    COMMAND make html
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/docs
    COMMENT "Building Sphinx documentation"
)

# Clean target to remove boot.bin
add_custom_target(clean-boot
    COMMAND ${CMAKE_COMMAND} -E rm -f ${BIN_DIR}/boot.bin
    COMMENT "Removing boot.bin from bin directory"
)

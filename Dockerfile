FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=i686-elf
ENV PREFIX=/opt/cross
ENV PATH="$PREFIX/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    texinfo \
    curl \
    git \
    qemu \
    nasm \
    grub-pc-bin \
    xorriso \
    cmake \
    nano \
    && apt-get clean

WORKDIR /tmp/osdev

# Download and extract Binutils 2.35
RUN curl -O https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.gz && \
    tar -xvzf binutils-2.35.tar.gz

# Download and extract GCC 10.2.0
RUN curl -O https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz && \
    tar -xvzf gcc-10.2.0.tar.gz && \
    cd gcc-10.2.0 && \
    ./contrib/download_prerequisites && \
    cd ..

# Build and install Binutils
RUN mkdir build-binutils && cd build-binutils && \
    ../binutils-2.35/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror && \
    make -j$(nproc) && \
    make install

# Build and install GCC
RUN mkdir build-gcc && cd build-gcc && \
    ../gcc-10.2.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers && \
    make -j$(nproc) all-gcc && \
    make -j$(nproc) all-target-libgcc && \
    make install-gcc && \
    make install-target-libgcc

# Clone the os_course repository
RUN git clone https://github.com/cmelnu/os_course.git

# Clean up source files
RUN rm -rf /tmp/osdev

CMD ["/bin/bash"]
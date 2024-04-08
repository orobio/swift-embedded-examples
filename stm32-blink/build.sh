#!/bin/sh

set -vex

# Determine file paths
REPOROOT=$(git rev-parse --show-toplevel)
TOOLSROOT=$REPOROOT/Tools
SRCROOT=$REPOROOT/stm32-blink
BUILDROOT=$SRCROOT/.build

# Setup tools and build flags
TARGET=armv7em-none-none-eabi

SWIFT_EXEC=swiftc
SWIFT_FLAGS="-target $TARGET -Osize -import-bridging-header $SRCROOT/BridgingHeader.h -wmo -enable-experimental-feature Embedded -Xcc -D__APPLE__ -Xcc -D__MACH__ -Xcc -ffreestanding -Xfrontend -function-sections"

CLANG_EXEC=clang
CLANG_FLAGS="-target $TARGET -Oz"

LD_EXEC=${LD_EXEC:-$CLANG_EXEC}
LD_FLAGS="-target $TARGET -nostdlib -static -Wl,-gc-sections -Wl,-T,$SRCROOT/STM32F746NG.ld"

# Create build directory
mkdir -p $BUILDROOT

# Build Swift sources
$SWIFT_EXEC $SWIFT_FLAGS -c $SRCROOT/*.swift -o $BUILDROOT/blink.o

# Build C sources
$CLANG_EXEC $CLANG_FLAGS -c $SRCROOT/Startup.c -o $BUILDROOT/Startup.o

# Link objects into executable
$LD_EXEC $LD_FLAGS $BUILDROOT/blink.o $BUILDROOT/Startup.o -o $BUILDROOT/blink

# Extract sections from executable into flashable binary
arm-none-eabi-objcopy -O binary $BUILDROOT/blink $BUILDROOT/blink.bin

# Echo final binary path
ls -al $BUILDROOT/blink.bin

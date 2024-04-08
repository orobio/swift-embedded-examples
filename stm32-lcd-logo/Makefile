##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift open source project
##
## Copyright (c) 2023 Apple Inc. and the Swift project authors.
## Licensed under Apache License v2.0 with Runtime Library Exception
##
## See https://swift.org/LICENSE.txt for license information
##
##===----------------------------------------------------------------------===##

# Determine file paths
REPOROOT := $(shell git rev-parse --show-toplevel)
TOOLSROOT := $(REPOROOT)/Tools
SRCROOT := $(REPOROOT)/stm32-lcd-logo
BUILDROOT := $(SRCROOT)/.build

# Setup tools and build flags
TARGET := armv7em-none-none-eabi
BASEADDRESS := 0x00200000

SWIFT_EXEC := swiftc
SWIFT_FLAGS := -target $(TARGET) -Osize -import-bridging-header $(SRCROOT)/Support/BridgingHeader.h -wmo -enable-experimental-feature Embedded -Xcc -D__APPLE__ -Xcc -D__MACH__ -Xcc -ffreestanding -Xfrontend -function-sections

CLANG_EXEC := clang
CLANG_FLAGS := -target $(TARGET) -Oz

LD_EXEC := $(CLANG_EXEC)
LD_FLAGS := -target $(TARGET) -nostdlib -static -Wl,-gc-sections -Wl,-T,$(SRCROOT)/STM32F746NG.ld

.PHONY: all
all: $(BUILDROOT)/lcd-logo.bin

$(BUILDROOT):
	# Create build directory
	mkdir -p $(BUILDROOT)

$(BUILDROOT)/lcd-logo.o: $(SRCROOT)/Main.swift $(SRCROOT)/Support/*.swift | $(BUILDROOT)
	# Build Swift sources
	$(SWIFT_EXEC) $(SWIFT_FLAGS) -c $^ -o $@

$(BUILDROOT)/Startup.o: $(SRCROOT)/Support/Startup.c | $(BUILDROOT)
	# Build C sources
	$(CLANG_EXEC) $(CLANG_FLAGS) -c $^ -o $@

$(BUILDROOT)/PixelData.o: $(SRCROOT)/Support/PixelData.c | $(BUILDROOT)
	# Build C sources
	$(CLANG_EXEC) $(CLANG_FLAGS) -c $^ -o $@

$(BUILDROOT)/lcd-logo: $(BUILDROOT)/lcd-logo.o $(BUILDROOT)/Startup.o $(BUILDROOT)/PixelData.o
	# Link objects into executable
	$(LD_EXEC) $(LD_FLAGS) $^ -o $@

$(BUILDROOT)/lcd-logo.bin: $(BUILDROOT)/lcd-logo
	# Extract sections from executable into flashable binary
	arm-none-eabi-objcopy -O binary $^ $@
	# Echo final binary path
	ls -al $(BUILDROOT)/lcd-logo.bin

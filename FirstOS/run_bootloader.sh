#!/bin/bash

# Create output directory
mkdir -p output_boot

# Compile bootloader
nasm -f bin kernel/bootloader.asm -o output_boot/bootloader.iso

# Compile main.c to 16-bit
gcc -c kernel/main.c -o output_boot/main.o -m16 -march=i386 -ffreestanding -nostdlib -mpreferred-stack-boundary=2


# Run in QEMU
qemu-system-x86_64 -drive format=raw,file=output_boot/bootloader.iso

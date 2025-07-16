#!/bin/bash

# Toolchain Configuration File
# This file contains shared configuration for all toolchain processing scripts

# Base module name for SiFive Freedom Tools
BASE_MODULE="sifive/freedom-tools/toolsuite"

# Supported toolchain versions
TOOLCHAIN_VERSIONS=(
  "1.0.7"
  "2.0.3"
  "3.1.5"
  "4.0.0"
  "4.0.1"
  "4.0.2"
  "4.0.3"
)

# Default compiler names
DEFAULT_GCC_TRIPLE="riscv64-unknown-elf-gcc"
DEFAULT_CLANG_TRIPLE="riscv64-unknown-elf-clang"

# Function to check if a version is valid
is_valid_version() {
    local version="$1"
    for v in "${TOOLCHAIN_VERSIONS[@]}"; do
        if [ "$v" == "$version" ]; then
            return 0
        fi
    done
    return 1
}

# Function to list all available versions
list_versions() {
    echo "Available toolchain versions:"
    for v in "${TOOLCHAIN_VERSIONS[@]}"; do
        echo "  $v"
    done
}
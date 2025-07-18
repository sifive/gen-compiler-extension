#!/bin/bash

# Load toolchain configuration
source "$(dirname "$0")/toolchain_config.sh"

# Default configuration
OUTPUT_DIR="mcpu_lists"
VERBOSE=0
FORCE=0
GCC_COMPILER="$DEFAULT_GCC_TRIPLE"
CLANG_COMPILER="$DEFAULT_CLANG_TRIPLE"

# Copy toolchain versions from config
VERSIONS=("${TOOLCHAIN_VERSIONS[@]}")

# Function to print usage information
print_usage() {
    echo "Usage: $0 [-v|--verbose] [-f|--force] [-o|--output-dir DIR] [-m|--module MODULE]"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -f, --force           Force processing even if CSV files already exist"
    echo "  -o, --output-dir DIR  Specify output directory (default: mcpu_lists)"
    echo "  -m, --module MODULE   Specify base module name (default: $BASE_MODULE)"
    echo "  -h, --help            Show this help message"
}

# Function to print verbose messages
verbose_echo() {
    if [ $VERBOSE -eq 1 ]; then
        echo "VERBOSE: $1"
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -f|--force)
                FORCE=1
                shift
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -m|--module)
                BASE_MODULE="$2"
                shift 2
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

# Function to check if a compiler exists in PATH
check_compiler() {
    local compiler="$1"
    if ! command -v "$compiler" &> /dev/null; then
        echo "Error: $compiler not found in PATH"
        return 1
    fi
    return 0
}

# Function to process a specific toolchain version
process_toolchain_version() {
    local version="$1"
    local output_dir="$2"
    
    echo "Processing toolchain version $version..."
    
    # Check if the combined CSV already exists and not in force mode
    if [ -f "$output_dir/$version/mcpu_list.csv" ] && [ $FORCE -eq 0 ]; then
        echo "CSV file for version $version already exists, skipping..."
        return 0
    fi
    
    # If in force mode and files exist, inform the user
    if [ -f "$output_dir/$version/mcpu_list.csv" ] && [ $FORCE -eq 1 ]; then
        echo "Force mode enabled: Regenerating CSV files for version $version..."
    fi
    
    # Unload any existing toolchain module
    module unload "$BASE_MODULE" 2>/dev/null
    
    # Load the specific toolchain version
    if ! module load "$BASE_MODULE/$version"; then
        echo "[ERROR] Failed to load module $BASE_MODULE/$version"
        return 1
    fi
    
    # Check if compilers are available
    if ! check_compiler "$GCC_COMPILER"; then
        echo "[WARNING] GCC compiler not found for version $version"
    else
        # Create version-specific output directory
        mkdir -p "$output_dir/$version"
        
        # Run the mcpu extraction script for GCC
        echo "Extracting GCC mcpu values for version $version..."
        ./parse_mcpu_values.sh -c "$GCC_COMPILER" -o "$output_dir/$version/gcc_mcpu.csv"
    fi
    
    if ! check_compiler "$CLANG_COMPILER"; then
        echo "[WARNING] Clang compiler not found for version $version"
    else
        # Create version-specific output directory
        mkdir -p "$output_dir/$version"
        
        # Run the mcpu extraction script for Clang
        echo "Extracting Clang mcpu values for version $version..."
        ./parse_mcpu_values.sh -c "$CLANG_COMPILER" -o "$output_dir/$version/clang_mcpu.csv"
    fi
    
    # Generate combined CSV for this version
    if [ -f "$output_dir/$version/gcc_mcpu.csv" ] && [ -f "$output_dir/$version/clang_mcpu.csv" ]; then
        echo "Generating combined mcpu list for version $version..."
        ./parse_mcpu_values.sh -c "$GCC_COMPILER" -c "$CLANG_COMPILER" -o "$output_dir/$version/mcpu_list.csv"
    fi
    
    # Unload the module to prepare for the next version
    module unload "$BASE_MODULE" 2>/dev/null
    
    return 0
}

# Function to generate a comparison across all versions
generate_version_comparison() {
    local output_dir="$1"
    local comparison_file="$output_dir/compiler-mcpu.csv"
    
    echo "Generating version comparison across all toolchain versions..."
    
    # Collect all unique CPU names across all versions
    local all_cpus_file=$(mktemp)
    for version in "${VERSIONS[@]}"; do
        if [ -f "$output_dir/$version/mcpu_list.csv" ]; then
            # Skip header line and extract CPU column
            tail -n +2 "$output_dir/$version/mcpu_list.csv" | cut -d, -f1 >> "$all_cpus_file"
        fi
    done
    
    # Sort and get unique CPU names
    local unique_cpus_file=$(mktemp)
    sort "$all_cpus_file" | uniq > "$unique_cpus_file"
    
    # Create header row with version numbers
    echo -n "CPU" > "$comparison_file"
    for version in "${VERSIONS[@]}"; do
        echo -n ",$version-GCC,$version-Clang" >> "$comparison_file"
    done
    echo "" >> "$comparison_file"
    
    # Process each CPU
    while read -r cpu; do
        echo -n "$cpu" >> "$comparison_file"
        
        # Check each version
        for version in "${VERSIONS[@]}"; do
            local gcc_mark=""
            local clang_mark=""
            
            if [ -f "$output_dir/$version/mcpu_list.csv" ]; then
                # Check if this CPU is supported by GCC in this version
                if grep -q "^$cpu,X," "$output_dir/$version/mcpu_list.csv"; then
                    gcc_mark="X"
                fi
                
                # Check if this CPU is supported by Clang in this version
                if grep -q "^$cpu,.*,X$" "$output_dir/$version/mcpu_list.csv"; then
                    clang_mark="X"
                fi
            fi
            
            echo -n ",$gcc_mark,$clang_mark" >> "$comparison_file"
        done
        
        echo "" >> "$comparison_file"
    done < "$unique_cpus_file"
    
    # Clean up
    rm -f "$all_cpus_file" "$unique_cpus_file"
    
    echo "Version comparison saved to $comparison_file"
    
    # Convert the CSV to Excel format
    if command -v python3 &> /dev/null; then
        echo "Converting version comparison to Excel format..."
        if python3 ./mcpu_csv_to_excel.py -c "$comparison_file"; then
            echo "Excel conversion complete: ${comparison_file%.csv}.xlsx"
        else
            echo "Warning: Excel conversion failed"
        fi
    else
        echo "Warning: Python 3 not found, skipping Excel conversion"
    fi
}

# Main function
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    echo "Starting to process all toolchain versions..."
    echo "Output directory: $OUTPUT_DIR"
    echo "Base module: $BASE_MODULE"
    if [ $FORCE -eq 1 ]; then
        echo "Force mode: Enabled (will regenerate existing CSV files)"
    fi

    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Process each toolchain version
    for version in "${VERSIONS[@]}"; do
        process_toolchain_version "$version" "$OUTPUT_DIR"
    done
    
    # Generate version comparison
    generate_version_comparison "$OUTPUT_DIR"
    
    echo "Completed processing all toolchain versions!"
    echo "Results saved to $OUTPUT_DIR"
    
    return 0
}

# Run the main function with all arguments
main "$@"

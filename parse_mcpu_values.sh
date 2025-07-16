#!/bin/bash

# Default configuration
OUTPUT_FILE="mcpu_list.csv"
VERBOSE=0
DUMP_MODE=0
COMPILERS=("riscv64-unknown-elf-gcc" "riscv64-unknown-elf-clang")

# Function to print usage information
print_usage() {
    echo "Usage: $0 [-v|--verbose] [-d|--dump] [-o|--output FILE] [-c|--compiler COMPILER]"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -d, --dump            Dump mcpu list without saving to CSV"
    echo "  -o, --output FILE     Specify output CSV file (default: gcc_mcpu_values.csv)"
    echo "  -c, --compiler COMP   Specify compiler to extract mcpu values from"
    echo "                        Can be specified multiple times for multiple compilers"
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
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -c|--compiler)
                COMPILERS+=("$2")
                shift 2
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            -d|--dump)
                DUMP_MODE=1
                shift
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

# Function to dump mcpu list for a compiler
dump_mcpu_list() {
    local compiler="$1"
    local output_file="$2"
    
    echo "Dumping mcpu list for $compiler..."
    
    # Check if compiler exists
    if ! check_compiler "$compiler"; then
        return 1
    fi
    
    # Get architecture
    local arch=$(get_architecture "$compiler")
    echo "Architecture: $arch"
    
    # Extract CPU values based on compiler type
    if [[ "$compiler" == *"clang"* ]]; then
        echo "Using clang extraction method"
        extract_clang_mcpu_values "$compiler" | while read -r cpu; do
            echo "  - $cpu"
        done
    else
        echo "Using gcc extraction method"
        extract_mcpu_values "$compiler" | while read -r cpu; do
            echo "  - $cpu"
        done
    fi
    
    return 0
}

# Function to extract mcpu section from help output
extract_mcpu_section() {
    local temp_file="$1"
    local mcpu_section=""
    
    # Try different patterns to find the mcpu section
    for pattern in "Known valid arguments for -mcpu= option:" "Known valid values for -mcpu=" "Use -mcpu="; do
        if grep -q "$pattern" "$temp_file"; then
            start_line=$(grep -n "$pattern" "$temp_file" | head -1 | cut -d: -f1)
            
            # Find the end of the section
            if [[ "$pattern" == *"arguments"* ]]; then
                end_pattern="Known valid arguments for -mtune= option:"
            elif [[ "$pattern" == *"values"* ]]; then
                end_pattern="Known valid values for -mtune="
            else
                end_pattern="Use -mtune="
            fi
            
            if grep -q "$end_pattern" "$temp_file"; then
                end_line=$(grep -n "$end_pattern" "$temp_file" | head -1 | cut -d: -f1)
                end_line=$((end_line - 1))
                mcpu_section=$(sed -n "${start_line},${end_line}p" "$temp_file")
            else
                # Try to find next section header
                next_section=$(tail -n +$((start_line+1)) "$temp_file" | grep -n "^[A-Z].*:" | head -1)
                if [ -n "$next_section" ]; then
                    end_line=$((start_line + $(echo "$next_section" | cut -d: -f1) - 1))
                    mcpu_section=$(sed -n "${start_line},${end_line}p" "$temp_file")
                else
                    # If no next section, use to end of file
                    mcpu_section=$(tail -n +$start_line "$temp_file")
                fi
            fi
            
            break
        fi
    done
    
    echo "$mcpu_section"
}

# Function to extract mcpu values from gcc help output
extract_mcpu_values() {
    local gcc_command="$1"
    
    verbose_echo "Getting help output from $gcc_command"
    
    # Run the gcc command to get help for target options
    local help_output=$($gcc_command --help=target 2>/dev/null)
    
    if [ -z "$help_output" ]; then
        echo "Error: No output from $gcc_command --help=target" >&2
        return 1
    fi
    
    # Save the help output to a temporary file for more reliable processing
    local temp_file=$(mktemp)
    echo "$help_output" > "$temp_file"
    
    # Extract the mcpu section
    local mcpu_section=$(extract_mcpu_section "$temp_file")
    
    # Clean up
    rm "$temp_file"
    
    if [ -z "$mcpu_section" ]; then
        echo "Warning: Could not find mcpu section in help output" >&2
        return 1
    fi
    
    verbose_echo "Found mcpu section, extracting CPU values"
    
    # Extract the actual values using a more robust approach
    # Skip the header line and extract only valid CPU names
    local mcpu_values=$(echo "$mcpu_section" | tail -n +2 | tr -s ' ' '\n' | grep -v '^$' | grep -E '^[a-zA-Z0-9_-]+$' | sort | uniq)
    
    # Filter out common words that are not CPU names
    mcpu_values=$(echo "$mcpu_values" | grep -v -E '^(Known|valid|arguments|for|option|values|are|the|following|See|Use|to|set)$')
    
    if [ -z "$mcpu_values" ]; then
        echo "Warning: No CPU values found in mcpu section" >&2
        return 1
    fi
    
    # Return the values
    echo "$mcpu_values"
    return 0
}

# Function to get architecture name from compiler
get_architecture() {
    local compiler="$1"
    
    # Extract architecture from compiler name
    if [[ "$compiler" == *"riscv"* ]]; then
        echo "RISC-V"
    elif [[ "$compiler" == *"arm"* ]]; then
        echo "ARM"
    elif [[ "$compiler" == *"aarch64"* ]]; then
        echo "AArch64"
    elif [[ "$compiler" == *"x86_64"* ]]; then
        echo "x86_64"
    elif [[ "$compiler" == *"i?86"* ]]; then
        echo "x86"
    elif [[ "$compiler" == *"powerpc"* || "$compiler" == *"ppc"* ]]; then
        echo "PowerPC"
    elif [[ "$compiler" == *"mips"* ]]; then
        echo "MIPS"
    else
        # Default to compiler prefix if architecture can't be determined
        echo "${compiler%%-*}" | tr '[:lower:]' '[:upper:]'
    fi
}

# Function to extract mcpu values from clang help output
extract_clang_mcpu_values() {
    local clang_command="$1"
    
    verbose_echo "Getting mcpu help output from $clang_command"
    
    # Run the clang command to get help for mcpu
    local help_output=$($clang_command -mcpu=help 2>&1)
    
    if [ -z "$help_output" ]; then
        echo "Error: No output from $clang_command -mcpu=help" >&2
        return 1
    fi
    
    # Save the help output to a temporary file for more reliable processing
    local temp_file=$(mktemp)
    echo "$help_output" > "$temp_file"
    
    # Extract the mcpu section - starts after "Available CPUs for this target:"
    # and ends before "Use -mcpu or -mtune to specify the target's processor."
    local start_pattern="Available CPUs for this target:"
    local end_pattern="Use -mcpu or -mtune to specify the target's processor."
    
    if ! grep -q "$start_pattern" "$temp_file"; then
        echo "Warning: Could not find mcpu section in clang help output" >&2
        rm "$temp_file"
        return 1
    fi
    
    start_line=$(grep -n "$start_pattern" "$temp_file" | head -1 | cut -d: -f1)
    
    if grep -q "$end_pattern" "$temp_file"; then
        end_line=$(grep -n "$end_pattern" "$temp_file" | head -1 | cut -d: -f1)
        end_line=$((end_line - 1))
    else
        # If end pattern not found, use to end of file
        end_line=$(wc -l < "$temp_file")
    fi
    
    # Extract the section
    local mcpu_section=$(sed -n "$((start_line+1)),$end_line p" "$temp_file")
    
    # Clean up
    rm "$temp_file"
    
    if [ -z "$mcpu_section" ]; then
        echo "Warning: Empty mcpu section in clang help output" >&2
        return 1
    fi
    
    verbose_echo "Found clang mcpu section, extracting CPU values"
    
    # Extract the actual values - clang format is different, each CPU is on its own line
    local mcpu_values=$(echo "$mcpu_section" | tr -s ' ' | sed 's/^ *//' | grep -v '^$' | cut -d' ' -f1 | sort | uniq)
    
    if [ -z "$mcpu_values" ]; then
        echo "Warning: No CPU values found in clang mcpu section" >&2
        return 1
    fi
    
    # Return the values
    echo "$mcpu_values"
    return 0
}

# Function to extract and save mcpu values for a specific compiler
extract_and_save() {
    local compiler="$1"
    local output_file="$2"
    local arch=$(get_architecture "$compiler")
    
    echo "Extracting mcpu values for $compiler..."
    
    # Create CSV header
    echo "Architecture,CPU" > "$output_file"
    
    # Extract values based on compiler type
    if [[ "$compiler" == *"clang"* ]]; then
        extract_clang_mcpu_values "$compiler" | while read -r cpu; do
            echo "$arch,$cpu" >> "$output_file"
        done
    else
        extract_mcpu_values "$compiler" | while read -r cpu; do
            echo "$arch,$cpu" >> "$output_file"
        done
    fi
    
    # Count lines
    local count=$(wc -l < "$output_file")
    count=$((count - 1))  # Subtract header line
    
    echo "Saved $count CPU values to $output_file"
    return 0
}

# Function to merge two CSV files into one
merge_csv_files() {
    local gcc_file="$1"
    local clang_file="$2"
    local output_file="$3"
    
    echo "Merging $gcc_file and $clang_file into $output_file..."
    
    # Create a temporary file for GCC CPUs
    local gcc_temp=$(mktemp)
    tail -n +2 "$gcc_file" | cut -d, -f2 | sort > "$gcc_temp"
    
    # Create a temporary file for Clang CPUs
    local clang_temp=$(mktemp)
    tail -n +2 "$clang_file" | cut -d, -f2 | sort > "$clang_temp"
    
    # Create a combined list of all unique CPU values
    local combined_temp=$(mktemp)
    cat "$gcc_temp" "$clang_temp" | sort | uniq > "$combined_temp"
    
    # Create CSV header
    echo "CPU,GCC,Clang" > "$output_file"
    
    # Process each CPU in the combined list
    while read -r cpu; do
        local gcc_mark=""
        local clang_mark=""
        
        # Check if GCC has this CPU
        if grep -q "^$cpu$" "$gcc_temp"; then
            gcc_mark="X"
        fi
        
        # Check if Clang has this CPU
        if grep -q "^$cpu$" "$clang_temp"; then
            clang_mark="X"
        fi
        
        # Add to CSV
        echo "$cpu,$gcc_mark,$clang_mark" >> "$output_file"
    done < "$combined_temp"
    
    # Clean up
    rm -f "$gcc_temp" "$clang_temp" "$combined_temp"
    
    # Count lines
    local count=$(wc -l < "$output_file")
    count=$((count - 1))  # Subtract header line
    
    echo "Merged $count unique CPU values into $output_file"
    return 0
}

# Main function
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    echo "Starting to parse mcpu values..."
    verbose_echo "Output file: $OUTPUT_FILE"
    verbose_echo "Compilers: ${COMPILERS[*]}"
    
    # If in dump mode, just dump the mcpu list for each compiler
    if [ $DUMP_MODE -eq 1 ]; then
        for compiler in "${COMPILERS[@]}"; do
            echo "----------------------------------------"
            dump_mcpu_list "$compiler"
            echo "----------------------------------------"
        done
        return 0
    fi
    
    # Identify gcc and clang compilers
    local gcc_compiler=""
    local clang_compiler=""
    
    for compiler in "${COMPILERS[@]}"; do
        if [[ "$compiler" == *"clang"* ]]; then
            clang_compiler="$compiler"
        else
            gcc_compiler="$compiler"
        fi
    done
    
    # Create temporary files for individual compiler outputs
    local gcc_file=$(mktemp)
    local clang_file=$(mktemp)
    
    # Extract and save mcpu values for each compiler
    if [ -n "$gcc_compiler" ] && check_compiler "$gcc_compiler"; then
        extract_and_save "$gcc_compiler" "$gcc_file"
    fi
    
    if [ -n "$clang_compiler" ] && check_compiler "$clang_compiler"; then
        extract_and_save "$clang_compiler" "$clang_file"
    fi
    
    # Merge the two CSV files
    merge_csv_files "$gcc_file" "$clang_file" "$OUTPUT_FILE"
    
    # Clean up
    rm -f "$gcc_file" "$clang_file"
    
    # Print summary
    echo "Completed! CPU values saved to $OUTPUT_FILE"
    
    if [ $VERBOSE -eq 1 ]; then
        echo "VERBOSE: CSV file contents:"
        cat "$OUTPUT_FILE"
    fi
    
    return 0
}

# Run the main function with all arguments
main "$@"
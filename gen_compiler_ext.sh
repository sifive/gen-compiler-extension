#!/bin/bash

# Display help information
show_help() {
  echo "Usage: ./gen_compiler_ext.sh [OPTIONS]"
  echo ""
  echo "Generate CSV files of compiler extensions from RISC-V toolchains."
  echo ""
  echo "Options:"
  echo "  --help, -h              Show this help message and exit"
  echo "  --force                 Force regeneration of all output files"
  echo "  --output-dir DIR        Set output directory (default: ./csv)"
  echo "  --merged-file FILE      Set merged output file name (default: compiler-ext.csv)"
  echo "  --gcc-triple NAME       Use specific GCC triple name (default: riscv64-unknown-elf-gcc)"
  echo "  --clang-triple NAME     Use specific Clang triple name (default: riscv64-unknown-elf-clang)"
  echo "  --version VER           Process specific version only"
  echo "  --list-versions         List available versions and exit"
  echo "  --no-description        Filter out description column in the merged output"
  echo ""
  echo "Examples:"
  echo "  ./gen_compiler_ext.sh"
  echo "  ./gen_compiler_ext.sh --force"
  echo "  ./gen_compiler_ext.sh --output-dir ./my-reports"
  echo "  ./gen_compiler_ext.sh --gcc-triple riscv64-linux-gnu-gcc"
  echo "  ./gen_compiler_ext.sh --version 3.1.4"
  echo "  ./gen_compiler_ext.sh --no-description"
}

base_module="sifive/freedom-tools/toolsuite"
output_folder="./csv"
output_merged="compiler-ext.csv"
gcc_triple_name="riscv64-unknown-elf-gcc"
clang_triple_name="riscv64-unknown-elf-clang"
specific_version=""
no_description=""

# Toolchain versions
versions=(
  "1.0.6"
  "1.0.7"
  "2.0.3"
  "3.0.0"
  "3.1.0"
  "3.1.2"
  "3.1.3"
  "3.1.4"
)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --force)
      echo "🔧 Force mode enabled. Re-running full processing..."
      force_full=1
      ;;
    --output-dir)
      output_folder="$2"
      echo "📁 Output directory set to: $output_folder"
      shift
      ;;
    --merged-file)
      output_merged="$2"
      echo "📄 Merged output file set to: $output_merged"
      shift
      ;;
    --gcc-triple)
      gcc_triple_name="$2"
      echo "🔍 Using GCC triple: $gcc_triple_name"
      shift
      ;;
    --clang-triple)
      clang_triple_name="$2"
      echo "🔍 Using Clang triple: $clang_triple_name"
      shift
      ;;
    --version)
      specific_version="$2"
      echo "🔍 Processing specific version: $specific_version"
      shift
      ;;
    --list-versions)
      echo "Available versions:"
      for v in "${versions[@]}"; do
        echo "  $v"
      done
      exit 0
      ;;
    --no-description)
      echo "📝 Description column will be filtered out from the merged output"
      no_description="--no-description"
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
  shift
done

# Check if specific version is valid
if [ -n "$specific_version" ]; then
  version_found=0
  for v in "${versions[@]}"; do
    if [ "$v" == "$specific_version" ]; then
      version_found=1
      break
    fi
  done
  
  if [ $version_found -eq 0 ]; then
    echo "Error: Version $specific_version not found in available versions."
    echo "Available versions:"
    for v in "${versions[@]}"; do
      echo "  $v"
    done
    exit 1
  fi
  
  # Override versions array with just the specific version
  versions=("$specific_version")
fi

# If output folder doesn't exist or force mode is enabled, run full processing
if [ ! -d "$output_folder" ] || [ $force_full -eq 1 ]; then
  echo "🛠  Running full processing..."

  # Create (or recreate) the output folder
  rm -rf "$output_folder"
  mkdir -p "$output_folder"

  for version in "${versions[@]}"; do
    echo "=== Processing version $version ==="

    module unload "$base_module"
    if ! module load "$base_module/$version"; then
      echo "[ERROR] Failed to load module $base_module/$version"
      continue
    fi

    output_file="$output_folder/gcc-$version.txt"
    if ! $gcc_triple_name -march=help > "$output_file"; then
      echo "[ERROR] GCC command failed for version $version"
    fi

    # Check if output file is empty or has minimal content
    if [ ! -s "$output_file" ] || [ $(wc -l < "$output_file") -lt 2 ]; then
      echo "[WARNING] GCC output file is empty or too small, skipping CSV generation"
      rm $output_file
    else
      output_csv="$output_folder/gcc-$version.csv"
      echo "[INFO] Successfully generated $output_file"
      python3 gen_txt2csv.py "$output_file" "$output_csv"
    fi

    output_file2="$output_folder/clang-$version.txt"
    if ! $clang_triple_name --print-supported-extensions > "$output_file2"; then
      echo "[ERROR] Clang command failed for version $version"
    fi
    
    # Check if output file is empty or has minimal content
    if [ ! -s "$output_file2" ] || [ $(wc -l < "$output_file2") -lt 2 ]; then
      echo "[WARNING] Clang output file is empty or too small, skipping CSV generation"
      rm $output_file2
    else
      output_csv2="$output_folder/clang-$version.csv"
      echo "[INFO] Successfully generated $output_file2"
      python3 gen_txt2csv.py "$output_file2" "$output_csv2"
    fi
  done
else
  echo "📁 Output folder exists. Skipping processing and running merge only."
  echo "    Use --force to regenerate all files."
fi

# Always run merge step
echo "📦 Merging CSV files into $output_merged"
python3 merge_riscv_extensions.py -i "$output_folder"/clang*.csv "$output_folder"/gcc*.csv -o "$output_merged" $no_description
echo "✅ Done."

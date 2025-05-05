#!/bin/bash

base_module="sifive/freedom-tools/toolsuite"
output_folder="./csv"
output_merged="compiler-ext.csv"

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

# Check for --force option
force_full=0
if [[ "$1" == "--force" ]]; then
  echo "🔧 Force mode enabled. Re-running full processing..."
  force_full=1
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
    if ! riscv64-unknown-elf-gcc -march=help > "$output_file"; then
      echo "[ERROR] GCC command failed for version $version"
    fi

    output_file2="$output_folder/clang-$version.txt"
    if ! riscv64-unknown-elf-clang --print-supported-extensions > "$output_file2"; then
      echo "[ERROR] Clang command failed for version $version"
    fi

    output_csv="$output_folder/gcc-$version.csv"
    echo "[INFO] Successfully generated $output_file"
    python3 gen_txt2csv.py "$output_file" "$output_csv"

    output_csv2="$output_folder/clang-$version.csv"
    echo "[INFO] Successfully generated $output_file2"
    python3 gen_clang_txt2csv.py "$output_file2" "$output_csv2"
  done
else
  echo "📁 Output folder exists. Skipping processing and running merge only."
fi

# Always run merge step
echo "📦 Merging CSV files into $output_merged"
python3 merge_riscv_extensions.py -i csv/clang*.csv csv/gcc*.csv -o "$output_merged"
echo "✅ Done."


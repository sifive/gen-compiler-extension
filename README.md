# SiFive Toolchain Supported Extensions List Generator

This project provides a script to automate the extraction and comparison of available RISC-V extensions across different versions of the SiFive Freedom Tools RISC-V toolchain.

The script will:
1. Load each specified toolchain module.
2. Run `riscv64-unknown-elf-gcc -march=help` and `riscv64-unknown-elf-clang --print-supported-extensions` to extract supported extensions.
3. Convert the outputs to CSV format.
4. Merge all CSVs into a combined, sorted output file showing which extensions are supported in each toolchain version.

---

## 🔧 Requirements

- Bash shell
- `module` command (e.g., Lmod or Environment Modules)
- Python 3
- RISC-V toolchains available as modules
- Two Python scripts in the same directory:
  - `gen_txt2csv.py` — Converts GCC/Clang output to CSV
  - `merge_riscv_extensions.py` — Merges all CSVs into one

---

## 📁 Folder Structure

```bash
.
├── gen_compiler_ext.sh         # The main bash script
├── gen_txt2csv.py              # Converts compiler output to CSV
├── merge_riscv_extensions.py   # Merges multiple CSV files
└── csv/                        # Output folder (auto-generated)
```

## 🚀 Usage

### Basic Usage

Run full processing (if csv/ doesn't exist):
```bash
./gen_compiler_ext.sh
```

Force full processing (even if output folder exists):
```bash
./gen_compiler_ext.sh --force
```

### Command Line Options

The script supports several command-line options:

```
Options:
  --help, -h              Show help message and exit
  --force                 Force regeneration of all output files
  --output-dir DIR        Set output directory (default: ./csv)
  --merged-file FILE      Set merged output file name (default: compiler-ext.csv)
  --gcc-triple NAME       Use specific GCC triple name (default: riscv64-unknown-elf-gcc)
  --clang-triple NAME     Use specific Clang triple name (default: riscv64-unknown-elf-clang)
  --version VER           Process specific version only
  --list-versions         List available versions and exit
  --no-description       Filter out description column in the merged output
```

### Examples

Process all toolchain versions:
```bash
./gen_compiler_ext.sh
```

Process a specific version only:
```bash
./gen_compiler_ext.sh --version 3.1.4
```

Change the output directory:
```bash
./gen_compiler_ext.sh --output-dir ./my-reports
```

Use a different GCC triple:
```bash
./gen_compiler_ext.sh --gcc-triple riscv64-linux-gnu-gcc
```

List all available versions:
```bash
./gen_compiler_ext.sh --list-versions

Filter out description column from output:
```bash
./gen_compiler_ext.sh --no-description
```

## 📦 Output Files

After successful execution, you will get:

```bash
csv/
├── gcc-1.0.6.csv
├── gcc-1.0.7.csv
├── ...
├── gcc-3.1.4.csv
├── clang-1.0.6.csv
├── clang-1.0.7.csv
├── ...
└── clang-3.1.4.csv

compiler-ext.csv    # Combined & sorted CSV of all versions
```

The merged CSV file includes columns for each toolchain version, showing whether each extension is supported ('Y') or not ('N').



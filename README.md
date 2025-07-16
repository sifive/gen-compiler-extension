# SiFive Toolchain Supported Extensions and MCPUs List Generator

This project provides scripts to automate the extraction and comparison of available RISC-V extensions and supported MCPUs across different versions of the SiFive Freedom Tools RISC-V toolchain.

The scripts will:
1. Load each specified toolchain module.
2. Extract supported extensions and MCPUs from GCC and Clang compilers.
3. Convert the outputs to CSV format.
4. Merge all CSVs into combined, sorted output files showing which extensions/MCPUs are supported in each toolchain version.
5. Generate Excel files with conditional formatting for easy visualization.

---

## 🔧 Requirements

- Bash shell
- `module` command (e.g., Lmod or Environment Modules)
- Python 3
- RISC-V toolchains available as modules
- Python dependencies: `pandas`, `openpyxl`

Install Python dependencies:
```bash
pip install pandas openpyxl
```

---

## 📁 Folder Structure

```bash
.
├── gen_compiler_ext.sh         # Extract RISC-V extensions
├── gen_compiler_mcpu.sh        # Extract supported MCPUs
├── toolchain_config.sh         # Shared toolchain configuration
├── gen_txt2csv.py              # Converts compiler output to CSV
├── merge_riscv_extensions.py   # Merges multiple CSV files
├── gen_csv2xlsx.py             # Converts CSV to Excel with formatting
├── parse_mcpu_values.sh        # Extracts MCPU values from compilers
├── mcpu_csv_to_excel.py        # Converts MCPU CSV to Excel
├── csv/                        # Extensions output folder (auto-generated)
└── mcpu_lists/                 # MCPU output folder (auto-generated)
```

---

## 🚀 RISC-V Extensions Analysis

### Usage

Run full processing (if csv/ doesn't exist):
```bash
./gen_compiler_ext.sh
```

Force full processing (even if output folder exists):
```bash
./gen_compiler_ext.sh --force
```

### Command Line Options

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
./gen_compiler_ext.sh --version 3.1.5
```

Change the output directory:
```bash
./gen_compiler_ext.sh --output-dir ./my-reports
```

List all available versions:
```bash
./gen_compiler_ext.sh --list-versions
```

Filter out description column from output:
```bash
./gen_compiler_ext.sh --no-description
```

### Output Files

After successful execution, you will get:

```bash
csv/
├── gcc-1.0.7.csv
├── gcc-2.0.3.csv
├── ...
├── clang-1.0.7.csv
├── clang-2.0.3.csv
├── ...
└── compiler-ext.csv    # Combined & sorted CSV of all versions
    compiler-ext.xlsx   # Excel version with conditional formatting
```

---

## 🖥️ MCPU Analysis

### Usage

Run full processing:
```bash
./gen_compiler_mcpu.sh
```

Force regeneration of all files:
```bash
./gen_compiler_mcpu.sh --force
```

### Command Line Options

```
Options:
  -v, --verbose         Enable verbose output
  -f, --force           Force processing even if CSV files already exist
  -o, --output-dir DIR  Specify output directory (default: mcpu_lists)
  -m, --module MODULE   Specify base module name (default: sifive/freedom-tools/toolsuite)
  -h, --help            Show this help message
```

### Examples

Process all toolchain versions with verbose output:
```bash
./gen_compiler_mcpu.sh --verbose
```

Change the output directory:
```bash
./gen_compiler_mcpu.sh --output-dir ./mcpu-reports
```

Force regeneration of existing files:
```bash
./gen_compiler_mcpu.sh --force
```

### Output Files

After successful execution, you will get:

```bash
mcpu_lists/
├── 1.0.7/
│   ├── gcc_mcpu.csv
│   ├── clang_mcpu.csv
│   └── mcpu_list.csv
├── 2.0.3/
│   ├── gcc_mcpu.csv
│   ├── clang_mcpu.csv
│   └── mcpu_list.csv
├── ...
├── compiler-mcpu.csv   # Combined comparison across all versions
└── compiler-mcpu.xlsx  # Excel version with conditional formatting
```

---

## 📊 Excel Output Features

Both scripts generate Excel files with the following features:

- **Conditional Formatting**: Green highlighting for supported extensions/MCPUs ('Y' or 'X')
- **Frozen Panes**: First row and column frozen for easy navigation
- **Auto-sized Columns**: Columns automatically adjusted to content width
- **Multiple Sheets**: Separate sheets for different data views (extensions only)

### Manual Excel Conversion

You can also convert CSV files to Excel manually:

```bash
# Convert extensions CSV
python gen_csv2xlsx.py compiler-ext.csv --separate-sheets --freeze

# Convert MCPU comparison CSV
python mcpu_csv_to_excel.py -c mcpu_lists/compiler-mcpu.csv
```

---

## 🔍 Supported Toolchain Versions

Toolchain versions are configured in `toolchain_config.sh`. Current supported versions:
- 1.0.7
- 2.0.3
- 3.1.5
- 4.0.0
- 4.0.1
- 4.0.2
- 4.0.3

To add or modify versions, edit the `TOOLCHAIN_VERSIONS` array in `toolchain_config.sh`.

---

## 📝 Notes

- The scripts automatically skip processing if output files already exist (use `--force` to override)
- Module loading/unloading is handled automatically
- Error handling is included for missing compilers or failed module loads
- Both GCC and Clang outputs are processed and compared
- Excel conversion requires `pandas` and `openpyxl` Python packages



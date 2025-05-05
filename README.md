# SiFive Toolchain Supported Extensions List Generator

This project provides a script to automate the extraction and comparison of available `-march` options across different versions of the SiFive Freedom Tools RISC-V toolchain.

The script will:
1. Load each specified toolchain module.
2. Run `riscv64-unknown-elf-gcc -march=help` and save the output.
3. Convert the output to a CSV format.
4. Merge all CSVs into a combined, sorted output file.

---

## 🔧 Requirements

- Bash shell
- `module` command (e.g., Lmod or Environment Modules)
- Python 3
- RISC-V toolchains available as modules
- Two Python scripts in the same directory:
  - `gen_txt2csv.py` — Converts GCC output to CSV
  - `merge_riscv_extensions.py` — Merges all CSVs into one

---

## 📁 Folder Structure

```bash
.
├── process_gcc_features.sh       # The main bash script
├── gen_txt2csv.py                # Converts GCC output to CSV
├── merge_riscv_extensions.py     # Merges multiple CSV files
└── csv/                          # Output folder (auto-generated)
```

## 🚀 Usage
Run full processing (if csv/ doesn't exist):
```bash
./gen_compiler_ext.sh
```
Force full processing (even if output folder exists):
```bash
./gen_compiler_ext.sh --force
```
Result
Individual version CSVs are stored in the ./csv folder

Final merged CSV is saved as compiler-ext.csv

## 📦 Output Example
After successful execution, you will get:

```bash
csv/
├── gcc-1.0.6.csv
├── gcc-1.0.7.csv
...
├── gcc-3.1.4.csv

compiler-ext.csv    # Combined & sorted CSV of all versions
```


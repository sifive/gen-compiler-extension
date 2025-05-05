import csv
import sys
import os

def main():
    if len(sys.argv) != 3:
        print("Usage: python txt_to_csv_converter.py <input_file> <output_file>")
        return

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.exists(input_file):
        print(f"[ERROR] File not found: {input_file}")
        return

    data = []

    # Read and parse the input file
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    for line in lines:
        line = line.strip()
        # Skip empty lines or irrelevant headers
        if not line or line.startswith('All available') or line.startswith('Name'):
            continue
        parts = line.split()
        if len(parts) >= 2:
            version = parts[-1]
            name = ' '.join(parts[:-1])
            data.append([name, version])

    if not data:
        print("[WARNING] No valid data found. Please check the input file format.")
        return

    # Write data to CSV
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Name', 'Version'])
        writer.writerows(data)

    print(f"[INFO] Conversion complete. Output file: {output_file}")

if __name__ == "__main__":
    main()


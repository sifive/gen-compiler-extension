import csv
import sys
import re

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file.txt> <output_file.csv>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    rows = [["Name", "Version", "Description"]]

    # Match: name + version + rest of line as description
    pattern = re.compile(r"^\s*(\S+)\s+(\S+)\s+(.+)$")
    
    # Lines to skip
    skip_lines = [
        "All available -march extensions for RISC-V",
        "Experimental extensions",
        "Use -march to specify the target's extension.",
        "For example, clang"
    ]
    
    # Lines to skip that match patterns (header or empty lines)
    skip_patterns = [
        re.compile(r"^\s*$"),  # Empty lines
        re.compile(r"^\s*Name\s+Version\s+Description\s*$")  # Header line
    ]

    with open(input_file, "r", encoding="utf-8") as f:
        for line in f:
            # Skip lines that are in the skip list
            if any(skip_text in line for skip_text in skip_lines):
                continue
                
            # Skip lines that match any pattern in skip_patterns
            if any(skip_pattern.match(line) for skip_pattern in skip_patterns):
                continue
                
            match = pattern.match(line)
            if match:
                name, version, description = match.groups()
                rows.append([name, version, description.strip()])

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    print(f"Done: {len(rows) - 1} rows written to {output_file}")

if __name__ == "__main__":
    main()

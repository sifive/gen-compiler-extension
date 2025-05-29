#!/usr/bin/env python3
import csv
import sys
import re
import os

def main():
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <input_file.txt> <output_file.csv>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.exists(input_file):
        print(f"[ERROR] File not found: {input_file}")
        sys.exit(1)

    # Define header row with all possible columns
    rows = [["Name", "Version", "Description"]]

    # Match pattern for name, version, and description
    pattern = re.compile(r"^\s*(\S+(?:\s+\S+)*?)\s+(\S+(?:,\s*\S+)*)\s*(.*)$")
    
    # Lines to skip
    skip_lines = [
        "All available -march extensions for RISC-V",
        "Experimental ",
        "Supported ",
        "Use -march to specify the target's extension.",
        "For example, clang"
    ]
    
    # Lines to skip that match patterns (header or empty lines)
    skip_patterns = [
        re.compile(r"^\s*$"),  # Empty lines
        re.compile(r"^\s*Name\s+Version\s*$"),  # Header line of gcc
        re.compile(r"^\s*Name\s+Version\s+Description\s*$")  # Header line of clang
    ]

    with open(input_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            
            # Skip lines that are in the skip list
            if any(skip_text in line for skip_text in skip_lines):
                continue
                
            # Skip lines that match any pattern in skip_patterns
            if any(skip_pattern.match(line) for skip_pattern in skip_patterns):
                continue
            
            match = pattern.match(line)
            if match:
                name, version, description = match.groups()
                
                # Special handling for new GCC format
                if version.endswith(',') and description.strip() and description.strip()[0].isdigit():
                    version = version + description
                    description = ""
                
                # If we have a version at the end but no description
                if not description.strip() and ' ' in name:
                    # Try to extract version from the end of name
                    parts = name.split()
                    if len(parts) >= 2:
                        # Move last part to version if version is empty
                        if not version.strip():
                            version = parts[-1]
                            name = ' '.join(parts[:-1])
                
                # Check if version contains comma-separated values
                if ',' in version:
                    # Split by comma and create a row for each version
                    versions = [v.strip() for v in version.split(',')]
                    for v in versions:
                        if v:  # Skip empty versions
                            rows.append([name.strip(), v, description.strip()])
                else:
                    rows.append([name.strip(), version.strip(), description.strip()])
            elif line:  # If line is not empty but didn't match the pattern
                parts = line.split()
                if len(parts) >= 2:
                    # Simple fallback parsing
                    version = parts[-1]
                    name = ' '.join(parts[:-1])
                    rows.append([name, version, ""])

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    print(f"[INFO] Conversion complete: {len(rows) - 1} rows written to {output_file}")

if __name__ == "__main__":
    main()

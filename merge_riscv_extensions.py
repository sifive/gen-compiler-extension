#!/usr/bin/env python3
import csv
import argparse
import os
import glob
from collections import defaultdict

def read_csv_file(filepath):
    """Read CSV file and extract extension data based on format."""
    extensions = {}
    with open(filepath, 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        headers = next(reader)  # Read header row
        
        # Determine file format based on header
        has_description = 'Description' in headers
        
        for row in reader:
            if len(row) < 2:  # Skip empty rows
                continue
                
            name = row[0].strip()
            version = row[1].strip()
            
            # Create a unique key using name-version
            key = f"{name}-{version}"
            
            # Store description if available
            if has_description and len(row) > 2:
                extensions[key] = {
                    'name': name,
                    'version': version,
                    'description': row[2]  # Preserve quotes in description
                }
            else:
                extensions[key] = {
                    'name': name,
                    'version': version,
                    'description': ""
                }
    
    return extensions

def merge_csv_files(input_files, output_file, include_description=True):
    """Merge multiple CSV files into one consolidated file."""
    all_extensions = {}
    file_sources = []
    
    # Read all input files
    for input_file in input_files:
        filename = os.path.basename(input_file)
        # Remove .csv extension from the displayed column name
        column_name = os.path.splitext(filename)[0]
        file_sources.append(column_name)
        extensions = read_csv_file(input_file)
        
        # Add to all_extensions
        for key, ext_data in extensions.items():
            if key not in all_extensions:
                all_extensions[key] = {
                    'name': ext_data['name'],
                    'version': ext_data['version'],
                    'description': ext_data['description'],
                    'sources': {}
                }
            elif not all_extensions[key]['description'] and ext_data['description']:
                # Update description if it was empty and we now have one
                all_extensions[key]['description'] = ext_data['description']
                
            # Mark this file as having this extension
            all_extensions[key]['sources'][column_name] = True
    
    # Write consolidated output
    with open(output_file, 'w', newline='', encoding='utf-8') as file:
        # Include or exclude the Description column based on the include_description flag
        headers = ['Name', 'Version']
        if include_description:
            headers.append('Description')
        headers.extend(file_sources)
        
        writer = csv.writer(file)
        writer.writerow(headers)
        
        # Sort by name and then by version
        sorted_keys = sorted(all_extensions.keys(), 
                            key=lambda k: (all_extensions[k]['name'], all_extensions[k]['version']))
        
        for key in sorted_keys:
            ext = all_extensions[key]
            row = [
                ext['name'],
                ext['version']
            ]
            
            # Add description if needed
            if include_description:
                row.append(ext['description'])
            
            # Add Y/N for each source file
            for source in file_sources:
                row.append('Y' if source in ext['sources'] else 'N')
                
            writer.writerow(row)
    
    print(f"Successfully merged {len(input_files)} files into {output_file}")
    print(f"Found {len(all_extensions)} unique extensions")

def main():
    parser = argparse.ArgumentParser(description='Merge RISC-V extension CSV files.')
    parser.add_argument('--input', '-i', nargs='+', required=True, 
                        help='Input CSV files to merge (wildcards supported)')
    parser.add_argument('--output', '-o', required=True, 
                        help='Output CSV file path')
    parser.add_argument('--no-description', action='store_true',
                        help='Filter out description column in the output')
    
    args = parser.parse_args()
    
    # Expand wildcards in input paths
    import glob
    input_files = []
    for pattern in args.input:
        matched_files = glob.glob(pattern)
        if not matched_files:
            print(f"Warning: No files match pattern '{pattern}'")
        input_files.extend(matched_files)
    
    if not input_files:
        print("Error: No input files found after expanding wildcards")
        return 1
    
    # Validate input files exist
    for file in input_files:
        if not os.path.isfile(file):
            print(f"Error: Input file '{file}' does not exist or is not a file.")
            return 1
    
    print(f"Processing {len(input_files)} input files")
    # Pass the include_description flag (negation of no-description)
    merge_csv_files(input_files, args.output, not args.no_description)
    return 0

if __name__ == "__main__":
    exit(main())

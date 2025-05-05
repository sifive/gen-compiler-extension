import sys
import pandas as pd
import os

def main():
    if len(sys.argv) < 4:
        print("Usage: python merge_csv_chainable_multi.py <input1.csv> <input2.csv> [input3.csv ...] <output.csv>")
        return

    *input_files, output_file = sys.argv[1:]

    # Check if all input files exist
    for f in input_files:
        if not os.path.exists(f):
            print(f"File not found: {f}")
            return

    # Read the first input file
    print(f"Reading {input_files[0]}...")
    merged_df = pd.read_csv(input_files[0])
    merged_columns = merged_df.columns.tolist()

    # Detect key columns (exclude Y/N flags if already present)
    if any(col.endswith('.csv') for col in merged_columns):
        key_columns = [col for col in merged_columns if not col.endswith('.csv')]
    else:
        key_columns = merged_columns

    # Add presence flag for the first file
    first_file_column = os.path.splitext(os.path.basename(input_files[0]))[0]
    merged_df[first_file_column] = "Y"

    # Merge each subsequent file
    for file in input_files[1:]:
        print(f"Merging {file}...")
        new_df = pd.read_csv(file)

        # Keep only key columns
        new_df = new_df[key_columns]

        # Merge with current merged DataFrame
        merged_df = pd.concat([merged_df[key_columns], new_df]).drop_duplicates().reset_index(drop=True)

        # Update key_columns list if needed
        for col in merged_df.columns:
            if col.endswith('.csv'):
                continue
            if col not in key_columns:
                key_columns.append(col)

        # Add Y/N flags for previously seen files
        for prev_file in input_files[:input_files.index(file)]:
            prev_col = os.path.splitext(os.path.basename(prev_file))[0]
            if prev_col not in merged_df.columns:
                merged_df[prev_col] = merged_df.apply(
                    lambda row: "Y" if check_presence(row, pd.read_csv(prev_file), key_columns) else "N",
                    axis=1
                )

        # Add Y/N flag for current file
        new_col = os.path.splitext(os.path.basename(file))[0]
        merged_df[new_col] = merged_df.apply(
            lambda row: "Y" if check_presence(row, pd.read_csv(file), key_columns) else "N",
            axis=1
        )

    # ✅ Sort by key columns before output
    merged_df.sort_values(by=key_columns, inplace=True, ignore_index=True)

    # Write output
    merged_df.to_csv(output_file, index=False)
    print(f"✅ Merge complete! Output file: {output_file}")

def check_presence(row, df, keys):
    match = df
    for k in keys:
        if k not in row or k not in df.columns:
            return False
        match = match[match[k] == row[k]]
    return not match.empty

if __name__ == "__main__":
    main()


#!/bin/bash

# Usage: ./combine.sh file1 file2 file3 outputfile

# Read input arguments
file1="$1"
file2="$2"
file3="$3"
output="$4"

# Check if all files exist
for f in "$file1" "$file2" "$file3"; do
  if [ ! -f "$f" ]; then
    echo "Error: File '$f' not found!"
    exit 1
  fi
done

# Clear existing content in the output file (or create new one)
> "$output"

# Append content of all files to output file
cat "$file1" "$file2" "$file3" >> "$output"

echo "✅ Combined files into '$output'"


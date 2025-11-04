#!/bin/bash

# Timestamp file to track last compilation
TIMESTAMP_FILE=".compile_timestamps"

# Get all chapter files starting with ch
files=(ch*.tex)

echo "Starting compilation of chapter files..."

# Create timestamp file if it doesn't exist
touch "$TIMESTAMP_FILE"

compiled_count=0
skipped_count=0

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        basename="${file%.tex}"

        # Get the modification time of the tex file
        current_mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)

        # Get the stored modification time
        stored_mtime=$(grep "^$file:" "$TIMESTAMP_FILE" | cut -d: -f2)

        # Check if file needs compilation
        if [[ "$current_mtime" != "$stored_mtime" ]]; then
            echo "Processing $file (updated)..."

            # Run lualatex, biber, lualatex, lualatex
            echo "  Running lualatex (1/4)..."
            lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1

            echo "  Running biber...(2/4)"
            biber "$basename" > /dev/null 2>&1

            echo "  Running lualatex (3/4)..."
            lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1

            echo "  Running lualatex (4/4)..."
            lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1

            # Clean up intermediate files
            echo "  Cleaning up intermediate files..."
            rm -f "${basename}.aux" "${basename}.bbl" "${basename}.bcf" "${basename}.blg" \
                  "${basename}.idx" "${basename}.log" "${basename}.ltjruby" "${basename}.out" \
                  "${basename}.run.xml" "${basename}.toc" "${basename}.fls" "${basename}.fdb_latexmk" \
                  "${basename}.synctex.gz" "${basename}.nav" "${basename}.snm" "${basename}.vrb"

            # Update timestamp in file
            # Remove old entry if exists
            grep -v "^$file:" "$TIMESTAMP_FILE" > "$TIMESTAMP_FILE.tmp" 2>/dev/null || touch "$TIMESTAMP_FILE.tmp"
            echo "$file:$current_mtime" >> "$TIMESTAMP_FILE.tmp"
            mv "$TIMESTAMP_FILE.tmp" "$TIMESTAMP_FILE"

            echo "  Completed $file"
            ((compiled_count++))
        else
            echo "Skipping $file (no changes)"
            ((skipped_count++))
        fi
    fi
done

echo ""
echo "Compilation summary:"
echo "  Compiled: $compiled_count file(s)"
echo "  Skipped: $skipped_count file(s)"
echo "PDFs and TEX files remain, intermediate files removed."

# Execute compile1text.sh from two directories up
echo ""
echo "Executing ../../compile1text.sh..."
if [[ -f "../../compile1text.sh" ]]; then
    bash "../../compile1text.sh"
    echo "compile1text.sh completed."
else
    echo "Warning: ../../compile1text.sh not found, skipping."
fi
#!/bin/bash

# Change to the contents_basic directory
cd /Users/pythagoras/Library/CloudStorage/Dropbox/Git/psychometrics_syllabus/Psychometrics/contents_basic

# Get all chapter files starting with ch
files=(ch*.tex)

echo "Starting compilation of chapter files..."

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        basename="${file%.tex}"
        echo "Processing $file..."
        
        # Run lualatex, biber, lualatex, lualatex
        echo "  Running lualatex (1/4)..."
        lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1
        
        echo "  Running biber..."
        biber "$basename" > /dev/null 2>&1
        
        echo "  Running lualatex (2/4)..."
        lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1
        
        echo "  Running lualatex (3/4)..."
        lualatex -interaction=nonstopmode "$file" > /dev/null 2>&1
        
        # Clean up intermediate files
        echo "  Cleaning up intermediate files..."
        rm -f "${basename}.aux" "${basename}.bbl" "${basename}.bcf" "${basename}.blg" \
              "${basename}.idx" "${basename}.log" "${basename}.ltjruby" "${basename}.out" \
              "${basename}.run.xml" "${basename}.toc" "${basename}.fls" "${basename}.fdb_latexmk" \
              "${basename}.synctex.gz" "${basename}.nav" "${basename}.snm" "${basename}.vrb"
        
        echo "  Completed $file"
    fi
done

echo "All chapter files have been processed."
echo "PDFs and TEX files remain, intermediate files removed."
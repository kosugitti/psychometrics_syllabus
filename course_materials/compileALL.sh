#!/usr/bin/bash
rm *.pdf
lualatex textbook
upbibtex textbook
lualatex textbook
lualatex textbook

rm *.aux
rm *.log
rm *.dvi
rm *.toc
rm *.bbl
rm *.blg
rm *.out
rm *.fls
rm *.fdb_latexmk
rm *.synctex.gz
rm *.xbb
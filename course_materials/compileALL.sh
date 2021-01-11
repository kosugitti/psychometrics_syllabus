#!/usr/bin/bash
rm *.pdf
lualatex Dkiso1_book
upbibtex Dkiso1_book
lualatex Dkiso1_book
lualatex Dkiso1_book

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
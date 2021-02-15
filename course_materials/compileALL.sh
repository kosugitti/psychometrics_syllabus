#!/usr/bin/bash
rm *.pdf
textlint *.tex --fix
lualatex Dkiso1_book
upbibtex Dkiso1_book
lualatex Dkiso1_book
lualatex Dkiso1_book
upmendex -r -c -g -s indexStyle.ist Dkiso1_book
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
rm *.ltjruby
rm *.ilg
rm *.idx
rm *.ind

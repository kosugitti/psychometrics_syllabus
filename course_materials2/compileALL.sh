#!/usr/bin/bash
rm *.pdf
textlint *.tex --fix
lualatex Dkiso2_book
upbibtex Dkiso2_book
lualatex Dkiso2_book
lualatex Dkiso2_book
upmendex -r -c -g -s indexStyle.ist Dkiso2_book
lualatex Dkiso2_book

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

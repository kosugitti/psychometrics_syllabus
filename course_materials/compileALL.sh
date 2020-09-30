#!/usr/bin/bash
rm *.pdf
uplatex -src-special -interaction=nonstopmode -shell-escape textbook.tex
uplatex -src-special -interaction=nonstopmode -shell-escape textbook.tex
upbibtex textbook
uplatex -src-special -interaction=nonstopmode -shell-escape textbook.tex
uplatex -src-special -interaction=nonstopmode -shell-escape textbook.tex
dvipdfmx textbook.dvi
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
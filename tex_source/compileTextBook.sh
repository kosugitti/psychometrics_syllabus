#!/usr/bin/bash
cd `dirname $0`
uplatex textbook.tex
upbibtex textbook
uplatex textbook.tex
uplatex textbook.tex
dvipdfmx textbook.dvi
rm *.aux
rm *.log
rm *.dvi
rm *.toc
rm *.bbl
rm *.blg
mv -f textbook.pdf ../textbook.pdf

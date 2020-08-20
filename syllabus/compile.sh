#!/usr/bin/bash
cd `dirname $0`
uplatex syllabus.tex
upbibtex syllabus
uplatex syllabus.tex
uplatex syllabus.tex
dvipdfmx syllabus.dvi
rm *.aux
rm *.log
rm *.dvi
rm *.toc
rm *.bbl
rm *.blg
rm *.out
rm *.fls
rm *.fdb_latexmk
mv -f syllabus.pdf ../syllabus.pdf

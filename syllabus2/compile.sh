#!/usr/bin/bash
lualatex syllabus.tex
upbibtex syllabus
lualatex syllabus.tex
lualatex syllabus.tex
rm *.aux
rm *.log
rm *.dvi
rm *.toc
rm *.bbl
rm *.blg
rm *.out
rm *.fls
rm *.fdb_latexmk

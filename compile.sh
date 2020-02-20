#!/usr/bin/bash
rm *.aux
rm *.log
rm *.bbl
rm *.blg
uplatex syllabus.tex
upbibtex syllabus
uplatex syllabus.tex
uplatex syllabus.tex
dvipdfmx syllabus.dvi


#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials/tex"
cd $path

pandoc text1_chap01.tex -f latex -t markdown -o 1-text01.Rmd
pandoc text1_chap02.tex -f latex -t markdown -o 2-text01.Rmd
pandoc text1_chap03.tex -f latex -t markdown -o 3-text01.Rmd
pandoc text1_chap04.tex -f latex -t markdown -o 4-text01.Rmd
pandoc text1_chap05.tex -f latex -t markdown -o 5-text01.Rmd
pandoc text1_chap06.tex -f latex -t markdown -o 6-text01.Rmd
pandoc text1_chap07.tex -f latex -t markdown -o 7-text01.Rmd
pandoc text1_chap08.tex -f latex -t markdown -o 8-text01.Rmd
pandoc text1_chap09.tex -f latex -t markdown -o 9-text01.Rmd
pandoc text1_chap10.tex -f latex -t markdown -o 10-text01.Rmd
pandoc text1_chap11.tex -f latex -t markdown -o 11-text01.Rmd
pandoc text1_chap12.tex -f latex -t markdown -o 12-text01.Rmd
pandoc text1_chap13.tex -f latex -t markdown -o 13-text01.Rmd
pandoc text1_chap14.tex -f latex -t markdown -o 14-text01.Rmd
pandoc text1_chap15.tex -f latex -t markdown -o 15-text01.Rmd
pandoc text1_chap16.tex -f latex -t markdown -o 16-text01.Rmd
pandoc text1_chap17.tex -f latex -t markdown -o 17-text01.Rmd
pandoc text1_chap18.tex -f latex -t markdown -o 18-text01.Rmd
pandoc text1_chap19.tex -f latex -t markdown -o 19-text01.Rmd
pandoc text1_chap20.tex -f latex -t markdown -o 20-text01.Rmd
pandoc text1_chap21.tex -f latex -t markdown -o 21-text01.Rmd
pandoc text1_chap22.tex -f latex -t markdown -o 22-text01.Rmd
pandoc text1_chap23.tex -f latex -t markdown -o 23-text01.Rmd
pandoc text1_chap24.tex -f latex -t markdown -o 24-text01.Rmd
pandoc text1_chap25.tex -f latex -t markdown -o 25-text01.Rmd
pandoc text1_chap26.tex -f latex -t markdown -o 26-text01.Rmd
pandoc text1_chap27.tex -f latex -t markdown -o 27-text01.Rmd

mv -f *.Rmd ../Rmd/
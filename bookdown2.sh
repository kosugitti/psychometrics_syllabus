#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials2/tex"
cd $path

pandoc text2_chap01.tex -f latex -t markdown -o 1-text02.Rmd
pandoc text2_chap02.tex -f latex -t markdown -o 2-text02.Rmd
pandoc text2_chap03.tex -f latex -t markdown -o 3-text02.Rmd
pandoc text2_chap04.tex -f latex -t markdown -o 4-text02.Rmd
pandoc text2_chap05.tex -f latex -t markdown -o 5-text02.Rmd
pandoc text2_chap06.tex -f latex -t markdown -o 6-text02.Rmd
pandoc text2_chap07.tex -f latex -t markdown -o 7-text02.Rmd
pandoc text2_chap08.tex -f latex -t markdown -o 8-text02.Rmd
pandoc text2_chap09.tex -f latex -t markdown -o 9-text02.Rmd
pandoc text2_chap10.tex -f latex -t markdown -o 10-text02.Rmd
pandoc text2_chap11.tex -f latex -t markdown -o 11-text02.Rmd
pandoc text2_chap12.tex -f latex -t markdown -o 12-text02.Rmd
pandoc text2_chap13.tex -f latex -t markdown -o 13-text02.Rmd
pandoc text2_chap14.tex -f latex -t markdown -o 14-text02.Rmd
pandoc text2_chap15.tex -f latex -t markdown -o 15-text02.Rmd
pandoc text2_chap16.tex -f latex -t markdown -o 16-text02.Rmd
pandoc text2_chap17.tex -f latex -t markdown -o 17-text02.Rmd
pandoc text2_chap18.tex -f latex -t markdown -o 18-text02.Rmd
pandoc text2_chap19.tex -f latex -t markdown -o 19-text02.Rmd
pandoc text2_chap20.tex -f latex -t markdown -o 20-text02.Rmd
pandoc text2_chap21.tex -f latex -t markdown -o 21-text02.Rmd
pandoc text2_chap22.tex -f latex -t markdown -o 22-text02.Rmd
pandoc text2_chap23.tex -f latex -t markdown -o 23-text02.Rmd
pandoc text2_chap24.tex -f latex -t markdown -o 24-text02.Rmd
pandoc text2_chap25.tex -f latex -t markdown -o 25-text02.Rmd
pandoc text2_chap26.tex -f latex -t markdown -o 26-text02.Rmd
pandoc text2_chap27.tex -f latex -t markdown -o 27-text02.Rmd
pandoc text2_chap28.tex -f latex -t markdown -o 28-text02.Rmd
pandoc text2_chap29.tex -f latex -t markdown -o 29-text02.Rmd
pandoc text2_chap30.tex -f latex -t markdown -o 30-text02.Rmd

mv -f *.Rmd ../Rmd/
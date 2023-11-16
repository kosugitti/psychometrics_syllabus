#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials/tex_Eng"
filename="Dkiso1_bookE"
cd $path
## backup
cp ${filename}.tex ${filename}.old

## LateX Main
rm error.log
lualatex tmp
upbibtex tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error.log
grep 'multiply' tmp.log >> error.log
grep 'Citation' tmp.log >> error.log
grep 'Overfull' tmp.log >> error.log


## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
rm tmp.*
rm *.aux
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

cd ..
cd ..


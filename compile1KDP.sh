#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials/tex"
filename="Dkiso1_book_kdp"
cd $path
## backup
cp ${filename}.tex ${filename}.old
cp ${filename}.tex tmp.tex
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

echo $(date)
echo '出版用PDFを作成しました。出版用PDFには後書きと奥付があり，著作権表示が異なります。'
cat syllabus/error.log
#!/usr/bin/bash
#####################################################################text 2
## changePath
path="Psychometrics/v1_2/course_materials2/tex"
filename="Dkiso2_book_kdp"
cd $path
## backup
cp ${filename}.tex ${filename}.old
cp ${filename}.tex tmpK.tex
## LateX Main
rm errorK.log
lualatex tmpK
biber tmpK
lualatex tmpK
lualatex tmpK
upmendex -r -c -g -s ../../indexStyle.ist tmpK
lualatex tmpK
## Tex Warning Check
grep 'undefined' tmpK.log > errorK.log
grep 'multiply' tmpK.log >> errorK.log
grep 'Citation' tmpK.log >> errorK.log
grep 'Overfull' tmpK.log >> errorK.log


## cleanup
mv tmpK.pdf ../../${filename}.pdf
mv tmpK.log ../../${filename}.log
rm tmpK.*
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

########################## Show Message
echo $(date)
echo 'データ解析応用の出版用PDFを作成しました。出版用PDFには後書きと奥付があり，著作権表示が異なります。'
cat course_materials2/tex/errorK.log

today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m "$today"
git push
#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials/tex"
filename="Dkiso1_book_kdp"
cd $path

# 最新のbibファイルを取得
echo "最新のbibファイルを取得しています..."
cp ../../myBiber.bib ../../syllabus_bib.bib

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

echo $(date)
echo '出版用PDFを作成しました。出版用PDFには後書きと奥付があり，著作権表示が異なります。'
cat course_materials/tex/errorK.log

today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m $today
git push
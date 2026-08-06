#!/usr/bin/bash
set -euo pipefail
#####################################################################text 2
## changePath
path="Psychometrics/v1_2/course_materials2/tex"
filename="Dkiso2_book_kdp"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }
# 最新のbibファイルを取得
echo "最新のbibファイルを取得しています..."
cp ../../../../../myBiber.bib ../../../../syllabus_bib.bib

## backup
cp ${filename}.tex ${filename}.old
cp ${filename}.tex tmpK.tex
## LateX Main
rm -f errorK.log
lualatex tmpK
biber tmpK
lualatex tmpK
lualatex tmpK
upmendex -r -c -g -s ../../../../indexStyle.ist tmpK
lualatex tmpK
## Tex Warning Check
grep 'undefined' tmpK.log > errorK.log || true
grep 'multiply' tmpK.log >> errorK.log || true
grep 'Citation' tmpK.log >> errorK.log || true
grep 'Overfull' tmpK.log >> errorK.log || true
## cleanup
mv tmpK.pdf ../../${filename}.pdf
mv tmpK.log ../../${filename}.log
rm -f tmpK.*
rm -f *.aux
rm -f *.dvi
rm -f *.toc
rm -f *.bbl
rm -f *.blg
rm -f *.out
rm -f *.fls
rm -f *.fdb_latexmk
rm -f *.synctex.gz
rm -f *.ltjruby
rm -f *.ilg
rm -f *.idx
rm -f *.ind

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
#!/usr/bin/bash
set -euo pipefail
## --push を付けたときだけ git commit / push する（既定はコンパイルのみ）
DO_PUSH=0
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    if [ "$arg" = "--push" ]; then DO_PUSH=1; fi
  done
fi
#####################################################################text1
## changePath
path="Psychometrics/v1_2/course_materials/tex"
filename="Dkiso1_book_kdp"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }

## backup
cp ${filename}.tex ${filename}.old
cp ${filename}.tex tmpK.tex
## LateX Main
rm -f errorK.log
lualatex -interaction=nonstopmode tmpK || true
biber tmpK || true
lualatex -interaction=nonstopmode tmpK || true
lualatex -interaction=nonstopmode tmpK || true
upmendex -r -c -g -s ../../../../indexStyle.ist tmpK || true
upmendex -r -c -g -s ../../../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
lualatex -interaction=nonstopmode tmpK || true
## Tex Warning Check
grep 'undefined' tmpK.log > errorK.log || true
grep 'multiply' tmpK.log >> errorK.log || true
grep 'Citation' tmpK.log >> errorK.log || true
grep 'Overfull' tmpK.log >> errorK.log || true
## cleanup
mv tmpK.pdf ../../${filename}.pdf
mv tmpK.log ../../${filename}.log
rm -f tmpK.*
## 中間ファイルの掃除（gitに入れない・作業ツリーに残さない）
rm -f *.aux *.dvi *.toc *.lot *.lof
rm -f *.bbl *.blg *.bcf *.run.xml
rm -f *.out *.fls *.fdb_latexmk *.synctex.gz
rm -f *.ltjruby *.ilg *.idx *.ind
## 章別コンパイルの副産物（本体のログは上で mv 済み）
rm -f ch*.log ch*.pdf m*.log b*.log

cd ..
cd ..
cd ..
cd ..

echo $(date)
echo '出版用PDFを作成しました。出版用PDFには後書きと奥付があり，著作権表示が異なります。'
cat Psychometrics/v1_2/course_materials/tex/errorK.log

if [ "$DO_PUSH" -eq 1 ]; then
  today=$(LANG="ja_JP.UTF-8" date)
  git add --all
  git commit -m "$today"
  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi
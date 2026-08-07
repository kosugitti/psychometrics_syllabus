#!/usr/bin/bash
set -euo pipefail
#####################################################################text1
## changePath
## 注意: common_contents はリポジトリ直下の symlink（実体は Psychometrics/common_contents）。
## 外部コマンドは物理パスで解決するため，相対パスは実体基準で1階層深く書くこと。
path="common_contents/only_tex"
filename="common_contents"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }
## backup
cp ${filename}.tex ${filename}.old
cp ${filename}.tex tmp.tex
## LateX Main
rm -f error.log
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../../indexStyle.ist tmp || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > error.log || true
grep 'multiply' tmp.log >> error.log || true
grep 'Citation' tmp.log >> error.log || true
grep 'Overfull' tmp.log >> error.log || true
## cleanup
mv tmp.pdf ../../../${filename}.pdf
mv tmp.log ../../../${filename}.log
rm -f tmp.*
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
cd ..


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
upmendex -r -c -g -s ../../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
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


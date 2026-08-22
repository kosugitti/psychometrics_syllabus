#!/usr/bin/bash
set -euo pipefail
## --push を付けたときだけ git commit / push する（既定はコンパイルのみ）
DO_PUSH=0
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    if [ "$arg" = "--push" ]; then DO_PUSH=1; fi
  done
fi
#####################################################################

## 2024/1/23よりBiBLateXに乗り換える

## changePath
path="Psychometrics/v1_2/course_materials2/tex"
filename="Dkiso2_book1"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }

## backup
cp ${filename}.tex ${filename}.old
########### upgrade patch
val=$(sed -n 4p ${filename}.tex )
version=`echo $val | sed -E "s/lhead{version.//" | sed -E "s/}//"`
version=${version#\\}

if [[ ${version} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  all=${BASH_REMATCH[0]}
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
fi

plusOne=`expr "$patch" "+" "1"`
newVer=${major}.${minor}.${plusOne}
newval=`echo $val | sed -e "s/$version/$newVer/"`
#echo $val | sed -e "s/$val/$newval/"
echo "New version"$newVer
echo "応用テキスト(前期)の現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用テキスト(前期)の最新バージョンは"$newVer "です。" >| ../../Book_versions2a.md


## LateX Main
rm -f error1.log
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > error1.log || true
grep 'multiply' tmp.log >> error1.log || true
grep 'Citation' tmp.log >> error1.log || true
grep 'Overfull' tmp.log >> error1.log || true
## cleanup
mv tmp.pdf ../../${filename}.pdf

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
rm -f *.run.xml
rm -f *.ltjruby
rm -f *.ilg
rm -f *.idx
rm -f *.ind

cd ..
cd ..

echo $(date)
echo 'データ解析応用のテキスト(前期)を改定しました。'
cat Book_versions2a.md
cat course_materials2/tex/error1.log

if [ "$DO_PUSH" -eq 1 ]; then
  today=$(LANG="ja_JP.UTF-8" date)
  git add --all
  git commit -m "$today"
  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi

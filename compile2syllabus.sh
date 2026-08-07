#!/usr/bin/bash
set -euo pipefail
## --push を付けたときだけ git commit / push する（既定はコンパイルのみ）
DO_PUSH=0
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    if [ "$arg" = "--push" ]; then DO_PUSH=1; fi
  done
fi
#####################################################################syl 2
## changePath
path="Psychometrics/v1_2/syllabus2/tex"
filename="syllabus2a"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }
# 最新のbibファイルを取得
echo "最新のbibファイルを取得しています..."
cp ../../../../../myBiber.bib ../../../../syllabus_bib.bib

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
echo "応用シラバス2A，現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用シラバス2Aの最新バージョンは"$newVer "です。" >| ../../Syllabus_versions2a.md

## LateX Main
rm -f error.log
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist tmp || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > error2a.log || true
grep 'multiply' tmp.log >> error2a.log || true
grep 'Citation' tmp.log >> error2a.log || true
grep 'Overfull' tmp.log >> error2a.log || true
## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
rm -f tmp.*

################################################ 2B
filename="syllabus2b"
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
echo "応用シラバス2B，現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用シラバス2Bの最新バージョンは"$newVer "です。" >| ../../Syllabus_versions2b.md

## LateX Main
rm -f error.log
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist tmp || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > error2b.log || true
grep 'multiply' tmp.log >> error2b.log || true
grep 'Citation' tmp.log >> error2b.log || true
grep 'Overfull' tmp.log >> error2b.log || true
## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
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
rm -f *.run.xml
rm -f *.bcf
cd ..

########################## Show Message
echo $(date)
echo 'データ解析応用のシラバスを改定しました。'
cat Syllabus_versions2a.md
cat Syllabus_versions2b.md
cat syllabus2/error2a.log
cat syllabus2/error2b.log


if [ "$DO_PUSH" -eq 1 ]; then
  today=$(LANG="ja_JP.UTF-8" date)
  git add --all
  git commit -m "$today"
  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi

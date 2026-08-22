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
path="Psychometrics/syllabus_basic"
filename="syllabus_basic"
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
echo "基礎シラバス，現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "基礎シラバスの最新バージョンは"$newVer "です。" >| ../Syllabus_versions1.md

## LateX Main
rm -f error.log
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../indexStyle.ist tmp || true
upmendex -r -c -g -s ../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > error.log || true
grep 'multiply' tmp.log >> error.log || true
grep 'Citation' tmp.log >> error.log || true
grep 'Overfull' tmp.log >> error.log || true
## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
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

########################## Show Message
echo $(date)
echo 'データ解析基礎のシラバスを改定しました。'
cat Psychometrics/Syllabus_versions1.md

if [ "$DO_PUSH" -eq 1 ]; then
  today=$(LANG="ja_JP.UTF-8" date)
  git add --all
  git commit -m "$today"
  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi

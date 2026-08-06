#!/usr/bin/bash
set -euo pipefail
#####################################################################text1
## changePath
path="Psychometrics/contents_basic/"
filename="BasicBook3"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }
# 最新のbibファイルを取得
echo "最新のbibファイルを取得しています..."
cp ../../../myBiber.bib ../../syllabus_bib.bib

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
echo "基礎テキストの現在のバージョンです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "基礎テキストの最新バージョンは"$newVer "です。" >| ../../Book_versions1.md

## LateX Main
rm -f error.log
lualatex tmp
biber tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error.log || true
grep 'multiply' tmp.log >> error.log || true
grep 'Citation' tmp.log >> error.log || true
grep 'Overfull' tmp.log >> error.log || true
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

cd ..
cd ..

echo $(date)
echo 'データ解析基礎のテキストを改定しました。'
cat Book_versions1.md
echo 'Gitにコミットします。'

# Remove git lock file if it exists
if [ -f .git/index.lock ]; then
  echo 'Removing stale git lock file...'
  rm -f .git/index.lock
fi

# Wait a moment for any background git processes to complete
sleep 1

today=$(LANG="ja_JP.UTF-8" date)
git add --all

# Wait for git add to complete
sleep 1

git commit -m "$today"

# Wait for post-commit hooks to complete
sleep 2

git push

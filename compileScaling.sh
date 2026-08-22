#!/usr/bin/bash
set -euo pipefail
#####################################################################text1
## changePath
path="Scaling/tex"
filename="Scaling"
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

## cleanup
rm -f *.pdf
rm -f *.log
## 中間ファイルの掃除（gitに入れない・作業ツリーに残さない）
rm -f *.aux *.dvi *.toc *.lot *.lof
rm -f *.bbl *.blg *.bcf *.run.xml
rm -f *.out *.fls *.fdb_latexmk *.synctex.gz
rm -f *.ltjruby *.ilg *.idx *.ind
## 章別コンパイルの副産物（本体のログは上で mv 済み）
rm -f ch*.log ch*.pdf m*.log b*.log


plusOne=`expr "$patch" "+" "1"`
newVer=${major}.${minor}.${plusOne}
newval=`echo $val | sed -e "s/$version/$newVer/"`
#echo $val | sed -e "s/$val/$newval/"
echo "New version"$newVer
echo "心理尺度テキストの現在のバージョンです"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえましたぞ"
cat ${filename}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "広大集中講義テキストの最新バージョンは"$newVer "です。" >| ../../Hiroshima_versions.md

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
echo '広大集中講義のテキストを改定しました。'
cat Hiroshima_versions.md
cat Scaling/tex/error.log

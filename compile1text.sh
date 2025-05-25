#!/usr/bin/bash
#####################################################################text1
## changePath
path="Psychometrics/contents_basic/"
filename="BasicBook3"
cd $path
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
cat ${filname}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "基礎テキストの最新バージョンは"$newVer "です。" >| ../../Book_versions1.md

## LateX Main
rm error.log
lualatex tmp
biber tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error.log
grep 'multiply' tmp.log >> error.log
grep 'Citation' tmp.log >> error.log
grep 'Overfull' tmp.log >> error.log


## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
rm tmp.*
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
echo 'データ解析基礎のテキストを改定しました。'
cat Book_versions1.md
echo 'Gitにコミットします。'
today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m "$today"
git push

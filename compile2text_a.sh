#!/usr/bin/bash
#####################################################################

## 2024/1/23よりBiBLateXに乗り換える

## changePath
path="course_materials2/tex"
filename="Dkiso2_book1"
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
echo "応用テキスト(前期)の現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filname}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用テキスト(前期)の最新バージョンは"$newVer "です。" >| ../../Book_versions2a.md


## LateX Main
rm error1.log
lualatex tmp
biber tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error1.log
grep 'multiply' tmp.log >> error1.log
grep 'Citation' tmp.log >> error1.log
grep 'Overfull' tmp.log >> error1.log


## cleanup
mv tmp.pdf ../../${filename}.pdf

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
rm *.run.xml
rm *.ltjruby
rm *.ilg
rm *.idx
rm *.ind

cd ..
cd ..

echo $(date)
echo 'データ解析応用のテキスト(前期)を改定しました。'
cat Book_versions2a.md
cat course_materials2/tex/error1.log

today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m "$today"
git push

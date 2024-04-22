#!/usr/bin/bash
#####################################################################syl 2
## changePath
path="syllabus2/tex"
filename="syllabus2a"
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
echo "応用シラバス2A，現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filname}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用シラバス2Aの最新バージョンは"$newVer "です。" >| ../../Syllabus_versions2a.md

## LateX Main
rm error.log
lualatex tmp
biber tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error2a.log
grep 'multiply' tmp.log >> error2a.log
grep 'Citation' tmp.log >> error2a.log
grep 'Overfull' tmp.log >> error2a.log


## cleanup
mv tmp.pdf ../../${filename}.pdf
mv tmp.log ../../${filename}.log
rm tmp.*

################################################ 2B
filename="syllabus2b"
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
echo "応用シラバス2B，現在のバージョンは次の通りです。"
cat ${filename}.tex
echo "かきかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえました"
cat ${filname}.tex
echo "コンパイルを始めます"
cp ${filename}.tex tmp.tex

echo "応用シラバス2Bの最新バージョンは"$newVer "です。" >| ../../Syllabus_versions2b.md

## LateX Main
rm error.log
lualatex tmp
biber tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s ../../indexStyle.ist tmp
lualatex tmp
## Tex Warning Check
grep 'undefined' tmp.log > error2b.log
grep 'multiply' tmp.log >> error2b.log
grep 'Citation' tmp.log >> error2b.log
grep 'Overfull' tmp.log >> error2b.log


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
rm *.run.xml
rm *.bcf
cd ..

########################## Show Message
echo $(date)
echo 'データ解析応用のシラバスを改定しました。'
cat Syllabus_versions2a.md
cat Syllabus_versions2b.md
cat syllabus2/error2a.log
cat syllabus2/error2b.log
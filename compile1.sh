#!/usr/bin/bash
#####################################################################text1
## changePath
path="course_materials"
filename="Dkiso1_book"
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
echo "元のファイルはこうだぞ"
cat ${filename}.tex
echo "かきかえるぞ"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえたぞ"
cat ${filname}.tex
echo "コンパイル始めます"
cp ${filename}.tex tmp.tex

echo "基礎テキストの最新バージョンは"$newVer "です。" >| Book_versions1.md

## LateX Main
lualatex tmp
upbibtex tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s indexStyle.ist tmp
lualatex tmp

## cleanup
mv tmp.pdf ../${filename}.pdf

rm tmp.*
rm *.aux
rm *.log
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

#####################################################################syl 1
## changePath
path="syllabus"
filename="syllabus"
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
echo "元のファイルはこうだぞ"
cat ${filename}.tex
echo "かきかえるぞ"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "かきかえたぞ"
cat ${filname}.tex
echo "コンパイル始めます"
cp ${filename}.tex tmp.tex

echo "基礎シラバスの最新バージョンは"$newVer "です。" >| Syllabbus_versions1.md

## LateX Main
lualatex tmp
upbibtex tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s indexStyle.ist tmp
lualatex tmp

## cleanup
mv tmp.pdf ../${filename}.pdf

rm tmp.*
rm *.aux
rm *.log
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


########################## git commit & push
today=$(date "+%Y%m%d")
git commit -a -m $today
git push

today=$(LANG="ja_JP.UTF-8" date)
echo "最後にコンパイルされたのは"$today "です。" >| versions1.md

#!/usr/bin/bash
#####################################################################text1
## changePath
path="LABC/tex"
filename="LABC"
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

echo "線形代数テキストの最新バージョンは"$newVer "です。" >| ../../LA_versions1.md

## LateX Main
rm error.log
lualatex tmp
upbibtex tmp
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

########################## Show Message
echo $(date)
echo '線形代数のテキストを改定しました。'
cat LA_versions1.md
cat LABC/tex/error.log

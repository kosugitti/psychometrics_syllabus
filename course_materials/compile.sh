#!/usr/bin/bash
## backup
cp $1.tex $1.old
########### upgrade patch
val=$(sed -n 4p $1.tex )
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
cat $1.tex | (rm $1.tex; sed "s/$val/$newval/" > $1.tex)
cp $1.tex tmp.tex

## LateX Main
lualatex tmp
upbibtex tmp
lualatex tmp
lualatex tmp
upmendex -r -c -g -s indexStyle.ist tmp
lualatex tmp

## cleanup
cp tmp.pdf $1.pdf

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


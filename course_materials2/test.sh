cp syllabus2.tex syllabus2.old
########### upgrade patch
val=$(sed -n 4p Dkiso2_book.tex )
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
#sed -i -e "s/$val/$newval/" Dkiso2_book.tex
cat Dkiso2_book.tex | (rm Dkiso2_book.tex; sed "s/$val/$newval/" > Dkiso2_book.tex)

### Main Latex
lualatex Dkiso2_book
upbibtex Dkiso2_book
lualatex Dkiso2_book
lualatex Dkiso2_book
upmendex -r -c -g -s indexStyle.ist Dkiso2_book
lualatex Dkiso2_book
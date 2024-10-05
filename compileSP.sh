#!/usr/bin/bash
#####################################################################text1
## changePath
path="SocialPsychology/tex"
cd $path

# すべての *.tex ファイルをループで処理
for texfile in *.tex; do
    filename="${texfile%.tex}"  # 拡張子を除いたファイル名

    ## backup
    cp ${filename}.tex ${filename}.old

    echo "コンパイルを始めます: ${filename}.tex"
    cp ${filename}.tex tmp.tex

    ## LaTeX Main
    lualatex tmp
    biber tmp
    lualatex tmp
    lualatex tmp
    upmendex -r -c -g -s ../../indexStyle.ist tmp
    lualatex tmp
    rm tmp.*
done

# 全体を上の階層に
mv SocialPsychology_SP.pdf ../../SocialPsychology_SP.pdf

## cleanup

rm *.aux
rm *.dvi
rm *.toc
rm *.bbl
rm *.blg
rm *.out
rm *.fls
rm *.fdb_latexmk
rm *.run.xml
rm *.ltjruby
rm *.ilg
rm *.idx
rm *.ind
cd ..
cd ..

echo $(date)
echo '社会心理学特殊講義のテキストをコンパイルしました。'

today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m "$today"
git push

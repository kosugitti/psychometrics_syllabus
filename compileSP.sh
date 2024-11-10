#!/usr/bin/bash
#####################################################################text1
## changePath
path="SocialPsychology/tex"
cd $path

# 掃除
rm -f *.aux
rm -f *.bbl
rm -f *.bcf
rm -f *.blg
rm -f *.idx
rm -f *.ilg
rm -f *.ltjruby
rm -f *.out
rm -f *.run.xml
rm -f *.toc

# 仮想環境が存在しない場合は作成
if [ ! -d "venv" ]; then
    echo "仮想環境を作成しています..."
    python3 -m venv venv
    source venv/bin/activate
    pip install pandas
else
    source venv/bin/activate
fi

# スクリプトを実行
python formatter.py

# 仮想環境を無効化
deactivate

cp SocialPsychology_SP.tex ../tex_formatted/SocialPsychology_SP.tex

cd ../tex_formatted

# すべての *.tex ファイルをループで処理
for texfile in *.tex
do
    filename="${texfile%.tex}"  # 拡張子を除いたファイル名

    ## backup
    cp "${filename}.tex" "${filename}.old"

    echo "コンパイルを始めます: ${filename}.tex"
    cp "${filename}.tex" tmp.tex

    ## LaTeX Main
    lualatex "${filename}.tex"
    biber "${filename}"
    
    # SocialPsychology_SP.tex の場合のみ索引を作成
    if [ "$filename" = "SocialPsychology_SP" ]; then
        echo "索引を作成します: ${filename}"
        upmendex -r -c -g -s ../../indexStyle.ist "${filename}" nameidx.idx -o nameidx.ind
        upmendex -r -c -g -s ../../indexStyle.ist "${filename}" termidx.idx -o termidx.ind    
    fi
    
    lualatex "${filename}.tex"
    lualatex "${filename}.tex"
done

# 全体を上の階層に
mv SocialPsychology_SP.pdf ../../SocialPsychology_SP.pdf

## cleanup
rm -f *.aux
rm -f *.bbl
rm -f *.bcf
rm -f *.blg
rm -f *.idx
rm -f *.ilg
rm -f *.ltjruby
rm -f *.out
rm -f *.run.xml
rm -f *.toc
rm -f tmp.tex

cd ..
cd ..

echo $(date)
echo '社会心理学特殊講義のテキストをコンパイルしました。'

today=$(LANG="ja_JP.UTF-8" date)
git add --all
git commit -m "$today"
git push

#!/bin/bash
set -euo pipefail
#####################################################################
## SocialPsychology コンパイルスクリプト
## changePath
path="SocialPsychology/tex_formatted"
cd "$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }
echo "$(date): 社会心理学特殊講義のコンパイルを開始します..."

# 最新のbibファイルを取得
echo "最新のbibファイルを取得しています..."
cp ../../../myBiber.bib ../../syllabus_bib.bib

# 掃除
echo "一時ファイルをクリーンアップしています..."
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
rm -f *.log
rm -f *.ind

# メインファイルのコンパイル
filename="SocialPsychology_SP"
echo "メインファイルをコンパイルします: ${filename}.tex"

## backup
cp "${filename}.tex" "${filename}.old"

echo "1回目: lualatex"
lualatex "${filename}.tex"

echo "2回目: biber (参考文献処理)"
biber "${filename}"

echo "3回目: lualatex (参考文献とインデックス反映)"
lualatex "${filename}.tex"

echo "4回目: lualatex (最終調整)"
lualatex "${filename}.tex"

# PDFを上の階層にコピー
echo "PDFファイルを配置しています..."
cp SocialPsychology_SP.pdf ../../SocialPsychology_SP.pdf

## 最終クリーンアップ
echo "一時ファイルを削除しています..."
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
rm -f *.log
rm -f *.old

# 作業ディレクトリを元に戻す
cd ../..

echo "$(date): コンパイル完了"
echo "社会心理学特殊講義のテキストをコンパイルしました。"
echo "出力ファイル: SocialPsychology_SP.pdf"

# Git操作（オプション）
read -p "Gitにコミット・プッシュしますか？ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    today=$(LANG="ja_JP.UTF-8" date)
    git add --all
    git commit -m "SocialPsychology コンパイル完了: $today"
    git push
    echo "Gitにプッシュしました。"
else
    echo "Gitへのプッシュをスキップしました。"
fi

echo "スクリプト実行完了。"

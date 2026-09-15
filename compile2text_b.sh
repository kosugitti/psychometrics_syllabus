#!/usr/bin/env bash
set -euo pipefail
## --push を付けたときだけ git commit / push する（既定はコンパイルのみ）
DO_PUSH=0
SET_VER=""
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    case "$arg" in
      --push) DO_PUSH=1 ;;
      --set=*) SET_VER="${arg#--set=}" ;;
    esac
  done
fi
## --set=X.Y.Z でバージョンを直接指定できる（既定はパッチを+1）
#####################################################################
## 2024/1/23よりBiBLateXに乗り換える
## 2026/9/15より Dropbox 外の一時ディレクトリでビルドする。
##   Dropbox配下だと lualatex がPDFの書き出し中に落ち，末尾が壊れたPDFが
##   できることがあるため（落ちる位置は毎回変わる）。
#####################################################################

REPO=$(cd "$(dirname "$0")" && pwd)
path="Psychometrics/v1_2/course_materials2/tex"
filename="Dkiso2_book2"
errorlog="error2.log"
verfile="Book_versions2b.md"   # v1_2直下に置く版数ファイル
label="後期"

cd "$REPO/$path" || { echo "ディレクトリが見つかりません: $path" >&2; exit 1; }

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

if [ -n "$SET_VER" ]; then
  newVer="$SET_VER"
else
  plusOne=`expr "$patch" "+" "1"`
  newVer=${major}.${minor}.${plusOne}
fi
newval=`echo $val | sed -e "s/$version/$newVer/"`
echo "New version"$newVer
echo "応用テキスト(${label})のバージョンを ${version} から ${newVer} にあげます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "応用テキスト(${label})の最新バージョンは"$newVer "です。" >| ../../${verfile}

#####################################################################
## Dropbox外の作業場を用意して，必要なものだけを複製する
#####################################################################
BUILD=$(mktemp -d "${TMPDIR:-/tmp}/dkiso2.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT
WORK="$BUILD/psychometrics_syllabus"
mkdir -p "$WORK/Psychometrics"
echo "作業場: $BUILD"

## myBiber.bib はリポジトリの1つ上にある（myStyle.styが相対パスで引く）
cp -L "$REPO/../myBiber.bib" "$BUILD/myBiber.bib"
## ルート直下のスタイル・書誌・索引設定
rsync -aL "$REPO"/*.sty "$REPO"/*.bib "$REPO"/*.ist "$REPO"/*.bbx "$REPO"/*.cbx \
          "$REPO"/*.dbx "$REPO"/*.lbx "$REPO"/*.bst "$REPO"/*.md "$WORK/"
## 本文が読み込む資源
rsync -aL --exclude '.git' "$REPO/Scaling" "$WORK/"
rsync -aL --exclude '.git' "$REPO/Psychometrics/common_contents" "$REPO/Psychometrics/v1_2" "$WORK/Psychometrics/"

cd "$WORK/$path"
cp ${filename}.tex tmp.tex

## LateX Main
rm -f ${errorlog}
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist tmp || true
upmendex -r -c -g -s ../../../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
lualatex -interaction=nonstopmode tmp || true
## Tex Warning Check
grep 'undefined' tmp.log > ${errorlog} || true
grep 'multiply' tmp.log >> ${errorlog} || true
grep 'Citation' tmp.log >> ${errorlog} || true
grep 'Overfull' tmp.log >> ${errorlog} || true

## 成果物をDropbox側へ戻す。PDFが壊れていたら差し替えない
if [ ! -f tmp.pdf ]; then
  echo "PDFができていません。ビルドに失敗しています。" >&2
  exit 1
fi
if ! pdfinfo tmp.pdf > /dev/null 2>&1; then
  echo "できたPDFが壊れています。差し替えを中止します。" >&2
  exit 1
fi
cp tmp.pdf "$REPO/Psychometrics/v1_2/${filename}.pdf"
cp ${errorlog} "$REPO/$path/${errorlog}"

cd "$REPO"
echo $(date)
echo "データ解析応用のテキスト(${label})を改定しました。"
pdfinfo "Psychometrics/v1_2/${filename}.pdf" | grep -i pages
cat "Psychometrics/v1_2/${verfile}"
cat "$path/${errorlog}"

if [ "$DO_PUSH" -eq 1 ]; then
  today=$(LANG="ja_JP.UTF-8" date)
  git add --all
  git commit -m "$today"
  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi

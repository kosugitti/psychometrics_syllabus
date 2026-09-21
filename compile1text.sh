#!/usr/bin/bash
set -euo pipefail
## --push を付けたときだけ git commit / push する（既定はコンパイルのみ）
DO_PUSH=0
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    if [ "$arg" = "--push" ]; then DO_PUSH=1; fi
  done
fi
#####################################################################text1
## changePath
path="Psychometrics/contents_basic/"
filename="BasicBook3"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

plusOne=`expr "$patch" "+" "1"`
newVer=${major}.${minor}.${plusOne}
newval=`echo $val | sed -e "s/$version/$newVer/"`
echo "New version"$newVer
echo "基礎テキストのバージョンを書きかえます"
cat ${filename}.tex | (rm ${filename}.tex; sed "s/$val/$newval/" > ${filename}.tex)
echo "基礎テキストの最新バージョンは"$newVer "です。" >| "$REPO/Book_versions1.md"

#####################################################################
## Dropbox の外でビルドする
##
## この本は図版PNGを数百枚読む。リポジトリの実体が Dropbox のファイルプロバイダ
## 配下にあるため，そのままビルドすると実体化が追いつかず lualatex が
## `Input/output error` で落ちる。**LaTeXのエラーは1件も出ず，PDFが途中で
## 切れるだけ**なので原稿の問題と誤診しやすい（2026-08-07・2026-09-21に遭遇）。
## そこで必要なものを /tmp へ複製してビルドし，PDFとログだけ書き戻す。
##
## 複製するもの（相対パス構造を保てばこれで通る）:
##   <work>/myBiber.bib                     ← myStyle.sty が ../../../ で探す
##   <work>/root/{myStyle.sty,indexStyle.ist,*.bib}
##   <work>/root/Psychometrics/{contents_basic,common_contents}
#####################################################################
WORK=$(mktemp -d "${TMPDIR:-/tmp}/bb3build.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
BUILD="$WORK/root"
mkdir -p "$BUILD/Psychometrics"

## myBiber.bib は symlink のことがあるので実体を追って複製する
if [ -e "$REPO/../myBiber.bib" ]; then
  cp -L "$REPO/../myBiber.bib" "$WORK/myBiber.bib"
else
  echo "警告: myBiber.bib が見つかりません。引用が未定義になります" >&2
fi
cp "$REPO"/myStyle.sty "$REPO"/indexStyle.ist "$BUILD"/
cp "$REPO"/*.bib "$BUILD"/ 2>/dev/null || true
rsync -a --exclude '.git' "$REPO/Psychometrics/contents_basic" "$BUILD/Psychometrics/"
rsync -a --exclude '.git' "$REPO/Psychometrics/common_contents" "$BUILD/Psychometrics/"

cd "$BUILD/Psychometrics/contents_basic"
cp ${filename}.tex tmp.tex
echo "コンパイルを始めます(作業場所: ${BUILD})"

## LateX Main
lualatex -interaction=nonstopmode tmp || true
biber tmp || true
lualatex -interaction=nonstopmode tmp || true
upmendex -r -c -g -s ../../indexStyle.ist tmp || true
upmendex -r -c -g -s ../../indexStyle.ist ridx.idx -o ridx.ind > /dev/null 2>&1 || true
lualatex -interaction=nonstopmode tmp || true

## PDFが最後まで出ているか確かめる（途中で落ちても lualatex は 0 を返すことがある）
if ! grep -q "Output written on tmp.pdf" tmp.log; then
  echo "エラー: PDFが生成されませんでした。tmp.log を見てください" >&2
  cp tmp.log "$REPO/${filename}.log"
  exit 1
fi
if ! tail -c 1024 tmp.pdf | grep -q "%%EOF"; then
  echo "エラー: PDFが途中で切れています（末尾に %%EOF がありません）" >&2
  cp tmp.log "$REPO/${filename}.log"
  exit 1
fi
grep "Output written on tmp.pdf" tmp.log | tail -1

## Tex Warning Check
rm -f "$REPO/error.log"
grep 'undefined' tmp.log >  "$REPO/error.log" || true
grep 'multiply'  tmp.log >> "$REPO/error.log" || true
grep 'Citation'  tmp.log >> "$REPO/error.log" || true
grep 'Overfull'  tmp.log >> "$REPO/error.log" || true

## 成果物を書き戻す
cp tmp.pdf "$REPO/${filename}.pdf"
cp tmp.log "$REPO/${filename}.log"

## 作業ディレクトリは trap で消えるので，リポジトリ側の掃除だけしておく
cd "$REPO/$path"
rm -f tmp.* *.aux *.dvi *.toc *.lot *.lof
rm -f *.bbl *.blg *.bcf *.run.xml
rm -f *.out *.fls *.fdb_latexmk *.synctex.gz
rm -f *.ltjruby *.ilg *.idx *.ind
rm -f ch*.log ch*.pdf m*.log b*.log

cd "$REPO"

echo $(date)
echo 'データ解析基礎のテキストを改定しました。'
cat Book_versions1.md
if [ "$DO_PUSH" -eq 1 ]; then
  echo 'Gitにコミットします。'

  # Remove git lock file if it exists
  if [ -f .git/index.lock ]; then
    echo 'Removing stale git lock file...'
    rm -f .git/index.lock
  fi

  # Wait a moment for any background git processes to complete
  sleep 1

  today=$(LANG="ja_JP.UTF-8" date)
  git add --all

  # Wait for git add to complete
  sleep 1

  git commit -m "$today"

  # Wait for post-commit hooks to complete
  sleep 2

  git push
else
  echo "コンパイルのみ実行しました。コミット・プッシュするには --push を付けてください。"
fi

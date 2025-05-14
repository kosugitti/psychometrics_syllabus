#!/bin/bash

# TeX Live 2025 パッケージインストールスクリプト
echo "TeX Live 2025 用パッケージインストールスクリプトを実行します"
echo "管理者権限が必要な場合はパスワードを入力してください"

# 必要なパッケージのリスト
PACKAGES=(
  # 基本パッケージ
  "natbib"
  "biblatex" 
  "biber"
  "bxpapersize"
  "geometry"
  "amsmath"
  "amssymb"
  "url"
  "graphicx"
  "lineno"
  "lscape"
  "luatexja-ruby"
  "epsdice"
  "fancyvrb"
  "ulem"
  "bm"
  "pdfpages"
  "wrapfig"
  "multirow"
  "tikz"
  "tikz-3dplot"
  "lltjext"
  "longtable"
  "tablefootnote"
  "luatexja-fontspec"
  "nicematrix"
  "booktabs"
  "accents"
  
  # ソースコード用パッケージ
  "colortbl"
  "xcolor"
  "listingsutf8"
  "hyperref"
  
  # 各種ライブラリ
  "tcolorbox"
  "capt-of"
  "makeidx"
  "fancyhdr"
  
  # 日本語関連パッケージ
  "collection-langjapanese"
  
  # さらに依存関係があるかもしれないパッケージ
  "pgf"          # tikzの基礎パッケージ
  "etoolbox"     # 多くのパッケージの依存関係
  "ifptex"       # 日本語TeX関連
  "luatexja"     # LuaTeX日本語対応
  "fontspec"     # フォント設定
  "docmute"      # 質問に関連
)

# エラーが出たパッケージを記録するリスト
FAILED_PACKAGES=()

echo "以下のパッケージをインストールします:"
for pkg in "${PACKAGES[@]}"; do
  echo "- $pkg"
done
echo ""
echo "インストールを開始します..."

# パッケージのインストール
for pkg in "${PACKAGES[@]}"; do
  echo "パッケージ '$pkg' をインストールしています..."
  
  # tlmgrでインストールを試みる
  sudo tlmgr install "$pkg"
  
  # インストール結果を確認
  if [ $? -ne 0 ]; then
    echo "警告: パッケージ '$pkg' のインストールに問題が発生しました。"
    FAILED_PACKAGES+=("$pkg")
  else
    echo "パッケージ '$pkg' のインストールが完了しました。"
  fi
  echo "----------------------------"
done

# TeXデータベースの更新
echo "TeXデータベースを更新しています..."
sudo mktexlsr
sudo texhash

# 結果の表示
echo ""
echo "インストールが完了しました。"

if [ ${#FAILED_PACKAGES[@]} -ne 0 ]; then
  echo "以下のパッケージのインストールに問題が発生しました:"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo "- $pkg"
  done
  echo "これらのパッケージは手動でインストールするか、代替方法を検討してください。"
else
  echo "すべてのパッケージが正常にインストールされました！"
fi

echo ""
echo "注意: 一部のパッケージ名はTeX Liveのパッケージ名と異なる場合があります。"
echo "その場合は手動で正しいパッケージ名を確認してインストールしてください。"
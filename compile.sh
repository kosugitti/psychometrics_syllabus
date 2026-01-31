#!/bin/bash
#####################################################################
# compile.sh - LaTeX統合コンパイルスクリプト
#####################################################################

# スクリプトのルートディレクトリ
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# エラー収集用
COMPILE_REPORT=""
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

#####################################################################
# メニュー表示
#####################################################################
show_menu() {
    echo ""
    echo -e "${BLUE}=== LaTeX統合コンパイラ ===${NC}"
    echo ""
    echo "コンパイルする本を選択してください:"
    echo ""
    echo "  1) 基礎テキスト (BasicBook3)"
    echo "  2) 応用テキスト前期 (Dkiso2_book1)"
    echo "  3) 応用テキスト後期 (Dkiso2_book2)"
    echo "  4) 基礎KDP版 (Dkiso1_book_kdp)"
    echo "  5) 応用KDP版 (Dkiso2_book_kdp)"
    echo "  6) 線形代数 (LABC)"
    echo "  7) 社会心理学特殊講義 (SocialPsychology_SP)"
    echo "  8) 基礎シラバス"
    echo "  9) 応用シラバス (2A + 2B)"
    echo " 10) 心理尺度・広大 (Scaling)"
    echo " 11) 共通部分"
    echo ""
    echo -e "  ${GREEN}a) 全部コンパイル${NC}"
    echo -e "  ${YELLOW}q) 終了${NC}"
    echo ""
}

#####################################################################
# バージョン更新関数
#####################################################################
update_version() {
    local filename=$1
    local version_file=$2
    local description=$3

    # 4行目からバージョン情報を取得
    # 形式: \lhead{version X.Y.Z}
    local val=$(sed -n 4p "${filename}.tex")
    # "." は正規表現で任意の1文字にマッチ（スペースにも対応）
    local version=$(echo "$val" | sed -E "s/.*lhead\{version.//" | sed -E "s/\}.*//" | sed 's/^[\\]*//')

    if [[ ${version} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        local major="${BASH_REMATCH[1]}"
        local minor="${BASH_REMATCH[2]}"
        local patch="${BASH_REMATCH[3]}"

        local plusOne=$((patch + 1))
        local newVer="${major}.${minor}.${plusOne}"

        echo -e "${GREEN}バージョン更新: ${version} -> ${newVer}${NC}"

        # バージョン書き換え (macOS対応)
        sed -i '' "s/${version}/${newVer}/" "${filename}.tex"

        # バージョンファイル出力
        if [ -n "$version_file" ]; then
            echo "${description}の最新バージョンは ${newVer} です。" > "${ROOT_DIR}/${version_file}"
        fi

        echo "$newVer"
    else
        echo -e "${YELLOW}バージョン情報が見つかりません: ${version}${NC}"
    fi
}

#####################################################################
# クリーンアップ関数
#####################################################################
cleanup_tex() {
    rm -f *.aux *.dvi *.toc *.bbl *.blg *.out *.fls *.fdb_latexmk 2>/dev/null
    rm -f *.synctex.gz *.ltjruby *.ilg *.idx *.ind *.run.xml *.bcf 2>/dev/null
}

#####################################################################
# エラー解析・レポート関数
#####################################################################
analyze_errors() {
    local logfile=$1
    local description=$2
    local report=""

    # 存在チェック
    [ ! -f "$logfile" ] && return

    # grepの結果を変数に格納（改行を除去）
    local undefined_refs
    local multiply_defs
    local citation_errs
    local overfull

    undefined_refs=$(grep -c 'undefined' "$logfile" 2>/dev/null | tr -d '\n') || undefined_refs=0
    multiply_defs=$(grep -c 'multiply' "$logfile" 2>/dev/null | tr -d '\n') || multiply_defs=0
    citation_errs=$(grep -c 'Citation' "$logfile" 2>/dev/null | tr -d '\n') || citation_errs=0
    overfull=$(grep -c 'Overfull' "$logfile" 2>/dev/null | tr -d '\n') || overfull=0

    # 空の場合は0に
    [ -z "$undefined_refs" ] && undefined_refs=0
    [ -z "$multiply_defs" ] && multiply_defs=0
    [ -z "$citation_errs" ] && citation_errs=0
    [ -z "$overfull" ] && overfull=0

    local total=$((undefined_refs + multiply_defs + citation_errs))

    if [ "$total" -gt 0 ] || [ "$overfull" -gt 0 ]; then
        report="${description}:\n"
        [ "$citation_errs" -gt 0 ] && report="${report}  - 未定義の引用: ${citation_errs}件\n"
        [ "$undefined_refs" -gt "$citation_errs" ] && report="${report}  - 未定義の参照: $((undefined_refs - citation_errs))件\n"
        [ "$multiply_defs" -gt 0 ] && report="${report}  - 重複定義: ${multiply_defs}件\n"
        [ "$overfull" -gt 0 ] && report="${report}  - Overfull警告: ${overfull}件\n"

        TOTAL_ERRORS=$((TOTAL_ERRORS + citation_errs + multiply_defs))
        TOTAL_WARNINGS=$((TOTAL_WARNINGS + overfull))
        COMPILE_REPORT="${COMPILE_REPORT}${report}\n"
    fi
}

show_final_report() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}コンパイルレポート${NC}"
    echo -e "${BLUE}========================================${NC}"

    if [ -n "$COMPILE_REPORT" ]; then
        echo -e "${YELLOW}問題が検出されました:${NC}"
        echo -e "$COMPILE_REPORT"
        echo -e "${RED}エラー合計: ${TOTAL_ERRORS}件${NC}"
        echo -e "${YELLOW}警告合計: ${TOTAL_WARNINGS}件${NC}"
    else
        echo -e "${GREEN}すべてのコンパイルが正常に完了しました${NC}"
    fi
    echo ""
}

#####################################################################
# LuaLaTeXコンパイル関数
#####################################################################
compile_book() {
    local path=$1
    local filename=$2
    local has_version=$3
    local version_file=$4
    local description=$5

    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}コンパイル開始: ${description}${NC}"
    echo -e "${BLUE}========================================${NC}"

    cd "${ROOT_DIR}/${path}" || { echo -e "${RED}ディレクトリが見つかりません: ${path}${NC}"; return 1; }

    # バックアップ
    cp "${filename}.tex" "${filename}.old"

    # バージョン更新
    if [ "$has_version" = "yes" ]; then
        update_version "$filename" "$version_file" "$description"
    fi

    echo "コンパイルを始めます..."

    # 事前クリーンアップ
    rm -f error.log 2>/dev/null

    # LaTeX コンパイル（元のファイル名を使用して相対パスを保持）
    echo -e "${YELLOW}[1/5] lualatex (1回目)...${NC}"
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1

    echo -e "${YELLOW}[2/5] biber...${NC}"
    biber "${filename}" > /dev/null 2>&1

    echo -e "${YELLOW}[3/5] lualatex (2回目)...${NC}"
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1

    echo -e "${YELLOW}[4/5] upmendex...${NC}"
    upmendex -r -c -g -s "${ROOT_DIR}/indexStyle.ist" "${filename}" > /dev/null 2>&1

    echo -e "${YELLOW}[5/5] lualatex (最終)...${NC}"
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1

    # エラーチェック
    grep 'undefined' "${filename}.log" > error.log 2>/dev/null
    grep 'multiply' "${filename}.log" >> error.log 2>/dev/null
    grep 'Citation' "${filename}.log" >> error.log 2>/dev/null
    grep 'Overfull' "${filename}.log" >> error.log 2>/dev/null

    # PDF検証と移動
    if [ -f "${filename}.pdf" ]; then
        # Dropbox同期対策: 移動前に少し待機
        sync 2>/dev/null
        sleep 1

        cp "${filename}.pdf" "${ROOT_DIR}/${filename}.pdf"
        cp "${filename}.log" "${ROOT_DIR}/${filename}.log"

        # 移動後に再度同期を待つ
        sync 2>/dev/null
        sleep 1

        # PDF検証
        if pdfinfo "${ROOT_DIR}/${filename}.pdf" > /dev/null 2>&1; then
            echo -e "${GREEN}PDF生成成功${NC}"
        else
            echo -e "${RED}警告: PDFが破損している可能性があります${NC}"
        fi
    else
        echo -e "${RED}エラー: PDFが生成されませんでした${NC}"
        cd "$ROOT_DIR"
        return 1
    fi

    # クリーンアップ
    cleanup_tex

    # エラー解析
    if [ -s error.log ]; then
        analyze_errors "error.log" "$description"
        echo -e "${YELLOW}警告/エラーあり (詳細は最終レポートで)${NC}"
    fi

    cd "$ROOT_DIR"

    echo -e "${GREEN}完了: ${description}${NC}"
    echo "$(date)"

    return 0
}

#####################################################################
# 社会心理学特殊講義の特別処理
#####################################################################
compile_sp() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}コンパイル開始: 社会心理学特殊講義${NC}"
    echo -e "${BLUE}========================================${NC}"

    cd "${ROOT_DIR}/SocialPsychology/tex" || return 1

    # 最新のbibファイルを取得
    echo "最新のbibファイルを取得しています..."
    cp ../../myBiber.bib ../../syllabus_bib.bib

    # 掃除
    cleanup_tex

    # Python仮想環境でformatter実行
    if [ ! -d "venv" ]; then
        echo "仮想環境を作成しています..."
        python3 -m venv venv
        source venv/bin/activate
        pip install pandas > /dev/null 2>&1
    else
        source venv/bin/activate
    fi

    python3 formatter.py
    deactivate

    cp SocialPsychology_SP.tex ../tex_formatted/SocialPsychology_SP.tex

    cd ../tex_formatted

    local filename="SocialPsychology_SP"
    cp "${filename}.tex" "${filename}.old"

    echo -e "${YELLOW}[1/4] lualatex (1回目)...${NC}"
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1

    echo -e "${YELLOW}[2/4] biber...${NC}"
    biber "${filename}" > /dev/null 2>&1

    echo -e "${YELLOW}[3/4] upmendex (2種類)...${NC}"
    upmendex -r -c -g -s "${ROOT_DIR}/indexStyle.ist" nameidx.idx -o nameidx.ind > /dev/null 2>&1
    upmendex -r -c -g -s "${ROOT_DIR}/indexStyle.ist" termidx.idx -o termidx.ind > /dev/null 2>&1

    echo -e "${YELLOW}[4/4] lualatex (最終2回)...${NC}"
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1
    lualatex -interaction=nonstopmode "${filename}.tex" > /dev/null 2>&1

    if [ -f SocialPsychology_SP.pdf ]; then
        mv SocialPsychology_SP.pdf "${ROOT_DIR}/SocialPsychology_SP.pdf"
        echo -e "${GREEN}PDF生成成功${NC}"
    else
        echo -e "${RED}エラー: PDFが生成されませんでした${NC}"
    fi

    cleanup_tex
    rm -f tmp.tex 2>/dev/null

    cd "$ROOT_DIR"

    echo -e "${GREEN}完了: 社会心理学特殊講義${NC}"
    echo "$(date)"

    return 0
}

#####################################################################
# Git操作
#####################################################################
do_git_commit() {
    echo ""
    echo -e "${BLUE}Gitにコミット・プッシュします...${NC}"

    cd "$ROOT_DIR"

    # ロックファイル削除
    if [ -f .git/index.lock ]; then
        echo 'ロックファイルを削除...'
        rm -f .git/index.lock
    fi

    sleep 1

    local today=$(LANG="ja_JP.UTF-8" date)
    git add --all
    sleep 1
    git commit -m "$today"
    sleep 2
    git push

    echo -e "${GREEN}Git操作完了${NC}"
}

#####################################################################
# 選択実行
#####################################################################
run_selection() {
    local selection=$1
    local do_git_after="no"

    case $selection in
        1)
            compile_book "Psychometrics/contents_basic" "BasicBook3" "yes" "Book_versions1.md" "基礎テキスト"
            do_git_after="yes"
            ;;
        2)
            compile_book "Psychometrics/v1_2/course_materials2/tex" "Dkiso2_book1" "yes" "Psychometrics/v1_2/Book_versions2a.md" "応用テキスト(前期)"
            do_git_after="yes"
            ;;
        3)
            compile_book "Psychometrics/v1_2/course_materials2/tex" "Dkiso2_book2" "yes" "Psychometrics/v1_2/Book_versions2b.md" "応用テキスト(後期)"
            do_git_after="yes"
            ;;
        4)
            compile_book "Psychometrics/v1_2/course_materials/tex" "Dkiso1_book_kdp" "no" "" "基礎KDP版"
            do_git_after="yes"
            ;;
        5)
            compile_book "Psychometrics/v1_2/course_materials2/tex" "Dkiso2_book_kdp" "no" "" "応用KDP版"
            do_git_after="yes"
            ;;
        6)
            compile_book "LABC/tex" "LABC" "yes" "LA_versions1.md" "線形代数"
            do_git_after="yes"
            ;;
        7)
            compile_sp
            do_git_after="yes"
            ;;
        8)
            compile_book "Psychometrics/syllabus_basic" "syllabus_basic" "yes" "Psychometrics/Syllabus_versions1.md" "基礎シラバス"
            do_git_after="yes"
            ;;
        9)
            compile_book "Psychometrics/v1_2/syllabus2/tex" "syllabus2a" "yes" "Psychometrics/v1_2/Syllabus_versions2a.md" "応用シラバス2A"
            compile_book "Psychometrics/v1_2/syllabus2/tex" "syllabus2b" "yes" "Psychometrics/v1_2/Syllabus_versions2b.md" "応用シラバス2B"
            do_git_after="yes"
            ;;
        10)
            compile_book "Scaling/tex" "Scaling" "yes" "Hiroshima_versions.md" "心理尺度(広大)"
            do_git_after="no"
            ;;
        11)
            compile_book "common_contents/only_tex" "common_contents" "no" "" "共通部分"
            do_git_after="no"
            ;;
        a|A)
            echo -e "${GREEN}全てのテキストをコンパイルします${NC}"
            # レポート初期化
            COMPILE_REPORT=""
            TOTAL_ERRORS=0
            TOTAL_WARNINGS=0
            for i in 1 2 3 4 5 6 7 8 9 10 11; do
                run_selection $i
            done
            # 最終レポート表示
            show_final_report
            do_git_after="yes"
            ;;
        q|Q)
            echo "終了します"
            exit 0
            ;;
        *)
            echo -e "${RED}無効な選択です${NC}"
            return 1
            ;;
    esac

    # Git操作確認
    if [ "$do_git_after" = "yes" ] && [ "$selection" != "a" ] && [ "$selection" != "A" ]; then
        echo ""
        read -p "Gitにコミット・プッシュしますか? [y/N]: " git_confirm
        if [[ "$git_confirm" =~ ^[Yy]$ ]]; then
            do_git_commit
        fi
    fi
}

#####################################################################
# メイン処理
#####################################################################
main() {
    # 引数があれば直接実行
    if [ -n "$1" ]; then
        run_selection "$1"
        exit 0
    fi

    # 対話モード
    while true; do
        show_menu
        read -p "選択 [1-11/a/q]: " choice
        run_selection "$choice"

        if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
            break
        fi

        echo ""
        read -p "続けますか? [Y/n]: " continue_choice
        if [[ "$continue_choice" =~ ^[Nn]$ ]]; then
            break
        fi
    done
}

main "$@"

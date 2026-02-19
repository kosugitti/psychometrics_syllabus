#!/bin/bash
#
# watcher.sh - レポート通知 + ステータス + レポート内容表示
#
# report.md / task.md の変更を検知し、ステータス一覧 + レポート内容 + ログを表示。
# report.md 更新時はベル音を鳴らす。
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUEUE_DIR="${SCRIPT_DIR}/queue"

AGENT_NAME1="クラリネット"; AGENT_ROLE1="整合性"
AGENT_NAME2="オーボエ";     AGENT_ROLE2="校閲"
AGENT_NAME3="ファゴット";   AGENT_ROLE3="ビルド"
AGENT_NAME4="フルート";     AGENT_ROLE4="Form"

trap 'echo ""; echo "Watcher 停止"; exit 0' INT TERM

# ── ANSI カラー ──
C_RED="\033[1;31m"
C_YEL="\033[1;33m"
C_GRN="\033[1;32m"
C_CYN="\033[1;36m"
C_BLU="\033[1;34m"
C_MAG="\033[1;35m"
C_DIM="\033[2m"
C_BOLD="\033[1m"
C_RST="\033[0m"

# 背景色
BG_BLU="\033[44m"
BG_RST="\033[49m"

# ── クロスプラットフォーム mtime 取得 ──
get_mtime() {
  if stat -f %m "$1" >/dev/null 2>&1; then
    stat -f %m "$1"
  else
    stat -c %Y "$1" 2>/dev/null || echo 0
  fi
}

read_field() {
  grep "^- ${2}:" "$1" 2>/dev/null | head -1 | sed "s/^- ${2}: *//"
}

# report.md の Details セクション以降を取得
read_details() {
  local file="$1"
  if [ ! -f "$file" ]; then return; fi
  sed -n '/^## Details/,$ p' "$file" 2>/dev/null | tail -n +2
}

status_icon() {
  case "$1" in
    needs_approval)  printf "${C_YEL}[!]${C_RST}" ;;
    completed)       printf "${C_GRN}[v]${C_RST}" ;;
    pending)         printf "${C_CYN}[>]${C_RST}" ;;
    error)           printf "${C_RED}[x]${C_RST}" ;;
    idle)            printf "${C_DIM}[-]${C_RST}" ;;
    *)               printf "${C_DIM}[-]${C_RST}" ;;
  esac
}

agent_color() {
  case "$1" in
    1) printf "${C_CYN}" ;;
    2) printf "${C_MAG}" ;;
    3) printf "${C_BLU}" ;;
    4) printf "${C_GRN}" ;;
  esac
}

# ── 経過時間の計算 ──
elapsed_str() {
  local start=$1
  local now
  now=$(date +%s)
  if [ "$start" -eq 0 ] || [ "$start" -gt "$now" ]; then
    echo ""
    return
  fi
  local diff=$((now - start))
  local min=$((diff / 60))
  local sec=$((diff % 60))
  if [ "$min" -gt 0 ]; then
    printf "%dm%02ds" "$min" "$sec"
  else
    printf "%ds" "$sec"
  fi
}

# ── 画面描画 ──
redraw() {
  clear
  printf "${C_BOLD}${BG_BLU} %-38s${BG_RST}${C_RST}\n" ""
  printf "${C_BOLD}${BG_BLU}  psychometrics_syllabus  %s  ${BG_RST}${C_RST}\n" "$(date '+%H:%M:%S')"
  printf "${C_BOLD}${BG_BLU} %-38s${BG_RST}${C_RST}\n" ""

  for N in 1 2 3 4; do
    eval "NAME=\$AGENT_NAME${N}"
    eval "ROLE=\$AGENT_ROLE${N}"

    local t_status r_status r_summary icon elapsed
    t_status=$(read_field "$QUEUE_DIR/agent${N}/task.md" "status")
    r_status=$(read_field "$QUEUE_DIR/agent${N}/report.md" "status")
    r_summary=$(read_field "$QUEUE_DIR/agent${N}/report.md" "summary")
    icon=$(status_icon "$r_status")
    ACOL=$(agent_color "$N")

    # 経過時間
    eval "local ts=\$TASK_START${N}"
    elapsed=""
    if [ "${t_status}" = "pending" ] || [ "${t_status}" = "approved" ]; then
      if [ -n "$ts" ] && [ "$ts" -gt 0 ] 2>/dev/null; then
        elapsed=" ${C_DIM}$(elapsed_str "$ts")${C_RST}"
      fi
    fi

    echo ""
    printf "  %b ${ACOL}${C_BOLD}%s${C_RST} ${C_DIM}%s${C_RST}%b\n" "$icon" "$NAME" "$ROLE" "$elapsed"

    # task ステータス
    if [ "$t_status" = "pending" ] || [ "$t_status" = "approved" ]; then
      printf "     ${C_CYN}task: %s${C_RST}\n" "$t_status"
    fi

    # report 内容表示（idle/none 以外）
    if [ "$r_status" != "idle" ] && [ "$r_status" != "none" ] && [ -n "$r_status" ]; then
      if [ -n "$r_summary" ] && [ "$r_summary" != "待機中" ]; then
        case "$r_status" in
          needs_approval) printf "     ${C_YEL}%s${C_RST}\n" "$r_summary" ;;
          error)          printf "     ${C_RED}%s${C_RST}\n" "$r_summary" ;;
          completed)      printf "     ${C_GRN}%s${C_RST}\n" "$r_summary" ;;
          *)              printf "     %s\n" "$r_summary" ;;
        esac
      fi
      # Details の内容を表示
      local details
      details=$(read_details "$QUEUE_DIR/agent${N}/report.md")
      if [ -n "$details" ]; then
        printf "     ${C_DIM}─────${C_RST}\n"
        echo "$details" | while IFS= read -r line; do
          printf "     ${C_DIM}%s${C_RST}\n" "$line"
        done
      fi
    fi
  done

  echo ""
  printf "${C_DIM}  ──────────────────────────────────────${C_RST}\n"
  printf "  ${C_BOLD}Events${C_RST}\n"
  echo ""
  local count=0
  for line in "${EVENT_LOG[@]}"; do
    if [ $count -ge 6 ]; then break; fi
    printf "  %b\n" "$line"
    count=$((count + 1))
  done
}

# ── イベントログ ──
EVENT_LOG=()

add_event() {
  EVENT_LOG=("[$(date '+%H:%M:%S')] $1" "${EVENT_LOG[@]}")
  if [ ${#EVENT_LOG[@]} -gt 30 ]; then
    EVENT_LOG=("${EVENT_LOG[@]:0:30}")
  fi
}

# ── 初期化 ──
for N in 1 2 3 4; do
  eval "TASK_MTIME${N}=$(get_mtime "$QUEUE_DIR/agent${N}/task.md")"
  eval "REPORT_MTIME${N}=$(get_mtime "$QUEUE_DIR/agent${N}/report.md")"
  eval "TASK_START${N}=0"
done

add_event "Watcher 起動"
redraw

# ── メインループ ──
while true; do
  CHANGED=0

  for N in 1 2 3 4; do
    eval "NAME=\$AGENT_NAME${N}"

    # ─ task.md 変更チェック ─
    TASK_FILE="$QUEUE_DIR/agent${N}/task.md"
    NEW_MT=$(get_mtime "$TASK_FILE")
    eval "OLD_MT=\$TASK_MTIME${N}"
    if [ "$NEW_MT" != "$OLD_MT" ]; then
      eval "TASK_MTIME${N}=$NEW_MT"
      T_STATUS=$(read_field "$TASK_FILE" "status")
      if [ "$T_STATUS" = "pending" ]; then
        add_event "${NAME}にタスクを投入"
        eval "TASK_START${N}=$(date +%s)"
      elif [ "$T_STATUS" = "approved" ]; then
        add_event "${NAME}に承認を送信"
        eval "TASK_START${N}=$(date +%s)"
      elif [ "$T_STATUS" = "none" ]; then
        eval "TASK_START${N}=0"
      fi
      CHANGED=1
    fi

    # ─ report.md 変更チェック ─
    REPORT_FILE="$QUEUE_DIR/agent${N}/report.md"
    NEW_MT=$(get_mtime "$REPORT_FILE")
    eval "OLD_MT=\$REPORT_MTIME${N}"
    if [ "$NEW_MT" != "$OLD_MT" ]; then
      eval "REPORT_MTIME${N}=$NEW_MT"
      R_STATUS=$(read_field "$REPORT_FILE" "status")

      if [ "$R_STATUS" != "idle" ] && [ "$R_STATUS" != "none" ] && [ -n "$R_STATUS" ]; then
        eval "local ts=\$TASK_START${N}"
        elapsed=""
        if [ -n "$ts" ] && [ "$ts" -gt 0 ] 2>/dev/null; then
          elapsed=" ($(elapsed_str "$ts"))"
        fi
        case "$R_STATUS" in
          needs_approval) add_event "${C_YEL}${NAME}から報告${elapsed} [${R_STATUS}]${C_RST}" ;;
          error)          add_event "${C_RED}${NAME}から報告${elapsed} [${R_STATUS}]${C_RST}" ;;
          completed)      add_event "${C_GRN}${NAME}から報告${elapsed} [${R_STATUS}]${C_RST}" ;;
          *)              add_event "${NAME}から報告${elapsed} [${R_STATUS}]" ;;
        esac
        printf '\a'
      fi
      CHANGED=1
    fi
  done

  # 経過時間の更新（10秒ごとに再描画）
  NOW=$(date +%s)
  LAST_REFRESH=${LAST_REFRESH:-$NOW}
  if [ $((NOW - LAST_REFRESH)) -ge 10 ]; then
    CHANGED=1
    LAST_REFRESH=$NOW
  fi

  if [ "$CHANGED" -eq 1 ]; then
    redraw
  fi

  sleep 3
done

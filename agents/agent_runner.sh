#!/bin/bash
#
# agent_runner.sh - エージェントラッパースクリプト
#
# task.md を監視し、変更検知で claude -p (ヘッドレスモード) を実行する。
#
# Usage: agent_runner.sh <agent_number>
#

AGENT_NUM="$1"
if [ -z "$AGENT_NUM" ] || ! [[ "$AGENT_NUM" =~ ^[1-4]$ ]]; then
  echo "Usage: $0 <1|2|3|4>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
QUEUE_DIR="${SCRIPT_DIR}/queue/agent${AGENT_NUM}"
TASK_FILE="${QUEUE_DIR}/task.md"
SYSTEM_PROMPT_FILE="${SCRIPT_DIR}/agent${AGENT_NUM}.md"

cd "$PROJECT_DIR"

case "$AGENT_NUM" in
  1) NAME="クラリネット"; ROLE="整合性" ;;
  2) NAME="オーボエ";     ROLE="校閲" ;;
  3) NAME="ファゴット";   ROLE="ビルド" ;;
  4) NAME="フルート";     ROLE="Google Form" ;;
esac

trap 'echo ""; echo "[$(date "+%H:%M:%S")] Agent${AGENT_NUM} ${NAME} 停止"; exit 0' INT TERM

echo "========================================"
echo " Agent${AGENT_NUM} ${NAME}(${ROLE}) Runner"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo " Polling: 3s"
echo "========================================"

# 起動時の挨拶
unset CLAUDECODE
claude -p "挨拶して" \
  --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
  --dangerously-skip-permissions \
  2>&1

echo ""
echo "[$(date '+%H:%M:%S')] 待機中..."

# 起動時点の mtime を記録（OS判定: macOS は -f %m, Linux は -c %Y）
if stat -f %m "$TASK_FILE" >/dev/null 2>&1; then
  STAT_CMD="stat -f %m"
else
  STAT_CMD="stat -c %Y"
fi
LAST_MTIME=$($STAT_CMD "$TASK_FILE" 2>/dev/null || echo 0)

while true; do
  NEW_MTIME=$($STAT_CMD "$TASK_FILE" 2>/dev/null || echo 0)

  if [ "$NEW_MTIME" != "$LAST_MTIME" ]; then
    LAST_MTIME="$NEW_MTIME"

    STATUS=$(grep '^- status:' "$TASK_FILE" 2>/dev/null | head -1 | sed 's/^- status: *//')

    if [ "$STATUS" = "pending" ] || [ "$STATUS" = "approved" ]; then
      TASK_CONTENT=$(cat "$TASK_FILE")

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "[$(date '+%H:%M:%S')] 新タスク検知 (status: ${STATUS})"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""

      unset CLAUDECODE
      claude -p "以下のタスクを実行してください。

${TASK_CONTENT}" \
        --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
        --dangerously-skip-permissions \
        2>&1

      EXIT_CODE=$?

      echo ""
      if [ $EXIT_CODE -eq 0 ]; then
        echo "[$(date '+%H:%M:%S')] 完了 (exit: 0)"
      else
        echo "[$(date '+%H:%M:%S')] エラー (exit: ${EXIT_CODE})"
      fi
      echo ""
      echo "[$(date '+%H:%M:%S')] 待機中..."
    fi
  fi

  sleep 3
done

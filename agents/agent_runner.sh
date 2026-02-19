#!/bin/bash
#
# agent_runner.sh - エージェントラッパースクリプト
#
# task.md を監視し、変更検知で claude -p (ヘッドレスモード) を実行する。
# tmux send-keys "check" を使わないため、Claude の入力欄にテキストが出ない。
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
  3) NAME="ファゴット";   ROLE="コンパイル・表記統一" ;;
  4) NAME="フルート";     ROLE="外部システム連携" ;;
esac

# git worktree ディレクトリ
WORKTREE_DIR="${PROJECT_DIR}/.worktrees/agent${AGENT_NUM}"

# Ctrl+C で停止
trap 'echo ""; echo "[$(date "+%H:%M:%S")] Agent${AGENT_NUM} ${NAME} 停止"; exit 0' INT TERM

echo "========================================"
echo " Agent${AGENT_NUM} ${NAME}(${ROLE}) Runner"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo " Polling: 1s"
if [ "$AGENT_NUM" = "4" ]; then
  echo " Permission: git commands only"
else
  echo " Permission: full (skip-permissions)"
fi
echo "========================================"
echo ""

# 起動時点の mtime を記録（挨拶前に記録して、挨拶中のタスク書き込みを見逃さない）
if stat -f %m "$TASK_FILE" >/dev/null 2>&1; then
  STAT_CMD="stat -f %m"
else
  STAT_CMD="stat -c %Y"
fi
LAST_MTIME=$($STAT_CMD "$TASK_FILE" 2>/dev/null || echo 0)

# 起動時の挨拶
unset CLAUDECODE
if [ "$AGENT_NUM" = "4" ]; then
  claude -p "挨拶して" \
    --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
    --allowedTools 'Bash(git *)' 'Bash(git)' 'Read' 'Write' 'Glob' 'Grep' \
    2>&1
else
  claude -p "挨拶して" \
    --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
    --dangerously-skip-permissions \
    2>&1
fi

echo ""
echo "[$(date '+%H:%M:%S')] 待機中..."

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

      # worktree ディレクトリで実行（ユーザーの main ブランチに影響しない）
      unset CLAUDECODE
      cd "$WORKTREE_DIR"
      if [ "$AGENT_NUM" = "4" ]; then
        claude -p "以下のタスクを実行してください。

【作業ディレクトリ】${WORKTREE_DIR}
【プロジェクトルート（main ブランチ）】${PROJECT_DIR}

${TASK_CONTENT}" \
          --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
          --allowedTools 'Bash(git *)' 'Bash(git)' 'Read' 'Write' 'Glob' 'Grep' \
          --verbose \
          --output-format stream-json \
          2>&1
      else
        claude -p "以下のタスクを実行してください。

【作業ディレクトリ】${WORKTREE_DIR}
【プロジェクトルート（main ブランチ）】${PROJECT_DIR}

${TASK_CONTENT}" \
          --system-prompt "$(cat "$SYSTEM_PROMPT_FILE")" \
          --dangerously-skip-permissions \
          --verbose \
          --output-format stream-json \
          2>&1
      fi | while IFS= read -r line; do
        case "$line" in
          *'"tool_use"'*)
            tool=$(printf '%s' "$line" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
            case "$tool" in
              Read|Edit|Write)
                arg=$(printf '%s' "$line" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's|.*/||')
                echo "  [$tool] $arg" ;;
              Bash)
                arg=$(printf '%s' "$line" | sed 's/.*"command":"//;s/".*//' | head -c 80)
                echo "  [$tool] $arg" ;;
              Grep|Glob)
                arg=$(printf '%s' "$line" | grep -o '"pattern":"[^"]*"' | head -1 | cut -d'"' -f4)
                echo "  [$tool] $arg" ;;
              *)
                echo "  [$tool]" ;;
            esac
            ;;
          *'"tool_result"'*'"stdout"'*)
            raw=$(printf '%s' "$line" | sed 's/.*"stdout":"//;s/","stderr".*//')
            if [ -n "$raw" ]; then
              total=$(($(printf '%s' "$raw" | grep -o '\\n' | wc -l) + 1))
              first=$(printf '%b' "$raw" | head -3)
              while IFS= read -r oline; do
                echo "    $oline"
              done <<< "$first"
              if [ "$total" -gt 3 ]; then
                echo "    … +$((total - 3)) lines"
              fi
            fi
            ;;
          *'"subtype":"success"'*)
            echo "  --- 完了 ---"
            ;;
          *'"subtype":"error"'*)
            echo "  --- エラー ---"
            ;;
        esac
      done
      EXIT_CODE=${PIPESTATUS[0]}
      cd "$PROJECT_DIR"

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

  sleep 1
done

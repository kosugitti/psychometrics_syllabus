#!/bin/bash
#
# マルチエージェントシステム停止（4エージェント対応）
#
# 1. キューをクリア
# 2. バンマスに /exit を送信（graceful shutdown）
# 3. tmux セッションを削除（ランナー・ウォッチャーは自動停止）
#

SESSION="mywork"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PANE_IDS_FILE="${SCRIPT_DIR}/queue/.pane_ids"

echo "マルチエージェントシステムを停止します"

# キューをクリア
for N in 1 2 3 4; do
  cat > "${SCRIPT_DIR}/queue/agent${N}/task.md" << 'EOF'
# Task
- status: none
EOF
  cat > "${SCRIPT_DIR}/queue/agent${N}/report.md" << 'EOF'
# Report
- status: idle
- summary: 待機中
EOF
done
echo "キューをクリアしました"

# ── worktree クリーンアップ ──
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
for N in 1 2 3 4; do
  WORKTREE="${PROJECT_DIR}/.worktrees/agent${N}"
  if [ -d "$WORKTREE" ]; then
    cd "$WORKTREE"
    git checkout -- . 2>/dev/null
    git clean -fd 2>/dev/null
    git checkout "agent${N}/standby" 2>/dev/null
    cd "$PROJECT_DIR"
  fi
done
echo "worktree をクリーンアップしました"

# バンマスに /exit を送信
if [ -f "$PANE_IDS_FILE" ]; then
  source "$PANE_IDS_FILE"
  if [ -n "$PANE_BM" ]; then
    echo "バンマスを終了中..."
    tmux send-keys -t "$PANE_BM" "/exit" C-m 2>/dev/null
    sleep 3
  fi
fi

# tmux セッション削除
echo "tmux セッションを削除中..."
tmux kill-session -t "$SESSION" 2>/dev/null

echo "停止完了！"

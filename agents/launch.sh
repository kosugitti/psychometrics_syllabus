#!/bin/bash
#
# マルチエージェントシステム一括起動（4エージェント版）
#
# tmux 1ウィンドウ・2行構成:
#   上段: バンマス(左80%) + ダッシュボード(右20%)
#   下段: Agent1 + Agent2 + Agent3 + Agent4 (各25%) -- agent_runner.sh で起動
#

SESSION="mywork"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "マルチエージェントシステムを起動します"
echo "  プロジェクト: $PROJECT_DIR"

# ── キューディレクトリ初期化 ──
mkdir -p agents/queue/agent{1,2,3,4}
for N in 1 2 3 4; do
  [ -f "agents/queue/agent${N}/task.md" ] || printf '# Task\n- status: none\n' > "agents/queue/agent${N}/task.md"
  [ -f "agents/queue/agent${N}/report.md" ] || printf '# Report\n- status: idle\n- summary: 待機中\n' > "agents/queue/agent${N}/report.md"
done

# ── 既存セッション削除 ──
tmux kill-session -t "$SESSION" 2>/dev/null

# ── セッション作成（1ウィンドウ構成） ──
tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR" -n "main"
tmux setw -g aggressive-resize on

# ── レイアウト構築 ──
#
# 目標:
# ┌────────────────────────────┬──────┐
# │ バンマス (80%)              │Watch │
# │                             │(20%) │
# ├───────┬───────┬───────┬────┴──────┤
# │Agent1 │Agent2 │Agent3 │ Agent4    │
# │ (25%) │ (25%) │ (25%) │ (25%)     │
# └───────┴───────┴───────┴───────────┘

# 初期ペイン = バンマス
PANE_BM=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

# 上下分割 (60:40)
tmux split-window -v -t "$PANE_BM" -p 40 -c "$PROJECT_DIR"
PANE_AGENT1=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

# 上段を左右分割 (バンマス80%:ダッシュボード20%)
tmux split-window -h -t "$PANE_BM" -p 20 -c "$PROJECT_DIR"
PANE_WATCHER=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

# 下段を4分割 (25:25:25:25)
tmux split-window -h -t "$PANE_AGENT1" -p 75 -c "$PROJECT_DIR"
PANE_AGENT2=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

tmux split-window -h -t "$PANE_AGENT2" -p 66 -c "$PROJECT_DIR"
PANE_AGENT3=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

tmux split-window -h -t "$PANE_AGENT3" -p 50 -c "$PROJECT_DIR"
PANE_AGENT4=$(tmux display-message -t "$SESSION":0 -p '#{pane_id}')

echo "  ペイン: BM=$PANE_BM Watch=$PANE_WATCHER A1=$PANE_AGENT1 A2=$PANE_AGENT2 A3=$PANE_AGENT3 A4=$PANE_AGENT4"

# ペインIDをファイルに保存
cat > agents/queue/.pane_ids <<EOF
PANE_BM=$PANE_BM
PANE_WATCHER=$PANE_WATCHER
PANE_AGENT1=$PANE_AGENT1
PANE_AGENT2=$PANE_AGENT2
PANE_AGENT3=$PANE_AGENT3
PANE_AGENT4=$PANE_AGENT4
EOF

sleep 1

# ── エージェント起動 (agent_runner.sh) ──
echo "エージェントランナー4体を起動中..."
tmux send-keys -t "$PANE_AGENT1" "bash agents/agent_runner.sh 1" C-m
tmux send-keys -t "$PANE_AGENT2" "bash agents/agent_runner.sh 2" C-m
tmux send-keys -t "$PANE_AGENT3" "bash agents/agent_runner.sh 3" C-m
tmux send-keys -t "$PANE_AGENT4" "bash agents/agent_runner.sh 4" C-m

# ── ウォッチャー起動 ──
tmux send-keys -t "$PANE_WATCHER" "bash agents/watcher.sh" C-m

# ── バンマス起動 ──
tmux send-keys -t "$PANE_BM" "unset CLAUDECODE; claude --dangerously-skip-permissions --system-prompt \"\$(cat agents/bandmaster.md)\" \"挨拶してください\"" C-m

# バンマスにフォーカス
tmux select-pane -t "$PANE_BM"

echo ""
echo "起動完了！"
echo ""
echo "tmux レイアウト:"
echo "  ┌────────────────────────────┬──────┐"
echo "  │ バンマス (80%)              │Watch │"
echo "  │                             │(20%) │"
echo "  ├───────┬───────┬───────┬────┴──────┤"
echo "  │Agent1 │Agent2 │Agent3 │ Agent4    │"
echo "  │ Cl    │ Ob    │ Fg    │ Fl        │"
echo "  └───────┴───────┴───────┴───────────┘"
echo ""

# ── ターミナルに接続 ──
# iTerm2 が使えれば iTerm2 で、なければ直接アタッチ
if [[ "$OSTYPE" == "darwin"* ]] && osascript -e 'tell application "System Events" to count processes whose name is "iTerm2"' 2>/dev/null | grep -q '[1-9]'; then
  osascript <<EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "tmux attach-session -t ${SESSION}"
    end tell
end tell
EOF
  echo "iTerm2 に接続しました"
elif [ -z "$TMUX" ]; then
  echo "tmux attach-session -t ${SESSION} でアタッチしてください"
  tmux attach-session -t "$SESSION"
fi

echo ""
echo "操作方法:"
echo "  バンマス(左上)に指示を入力"
echo "  ダッシュボード(右上)で状態確認"
echo "  下段でエージェントの作業を監視"
echo ""
echo "停止: bash agents/stop.sh"

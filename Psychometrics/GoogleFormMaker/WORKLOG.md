# Google Forms MCP サーバー セットアップ作業ログ

## プロジェクト概要

Claude CLIから直接Googleフォームを作成できるようにするため、Google Forms用のMCPサーバーをセットアップする。

### 目的
- 講義の課題問題（択一式）をClaude CLIから直接Googleフォームとして作成
- コピペ作業の削減

### 採用予定のMCPサーバー
- [google-forms-mcp](https://github.com/matteoantoci/google-forms-mcp) または
- [Google Workspace MCP Server](https://github.com/taylorwilsdon/google_workspace_mcp)

---

## セットアップ手順（予定）

### Step 1: Google Cloud Console でプロジェクト作成
- [ ] Google Cloud Console にアクセス
- [ ] 新規プロジェクト作成
- [ ] Google Forms API を有効化

### Step 2: OAuth 2.0 認証情報の取得
- [ ] OAuth同意画面の設定
- [ ] OAuth 2.0 クライアントIDの作成
- [ ] Client ID, Client Secret の取得
- [ ] Refresh Token の取得

### Step 3: MCPサーバーのインストール
- [ ] リポジトリのクローン
- [ ] 依存関係のインストール
- [ ] 環境変数の設定

### Step 4: Claude Code への登録
- [ ] `claude mcp add` コマンドで登録
- [ ] 動作確認

---

## 作業ログ

### 2024-12-03
- プロジェクト開始
- GoogleFormMaker フォルダ作成
- 作業ログ.md 作成
- Google Cloud Console でプロジェクト作成
- Google Forms API 有効化
- OAuth同意画面設定
- OAuth 2.0 クライアントID作成（ウェブアプリケーション）
- get_token.py でRefresh Token取得
- google-forms-mcp リポジトリをクローン
- npm install, npm run build 実行
- .env ファイル作成・設定
- Claude Code に MCP サーバー登録完了

---

## 参考リンク
- https://github.com/matteoantoci/google-forms-mcp
- https://github.com/taylorwilsdon/google_workspace_mcp
- https://console.cloud.google.com/

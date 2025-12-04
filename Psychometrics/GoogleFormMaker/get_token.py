#!/usr/bin/env python3
"""
Google OAuth Refresh Token 取得スクリプト

使い方:
1. CLIENT_ID と CLIENT_SECRET を書き換える
2. python get_token.py を実行
3. 表示されたURLをブラウザで開く
4. 認証後、リダイレクトされたURLをコピーしてターミナルに貼り付け
"""

import urllib.parse
import http.server
import webbrowser
import json
import urllib.request

# ============================================
# ここを書き換えてください
# ============================================
CLIENT_ID = "461428421350-q4kdqolriv245nb48b5ct97l1d9qcun2.apps.googleusercontent.com"
CLIENT_SECRET = "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"
# ============================================

REDIRECT_URI = "http://localhost:8080"
SCOPES = [
    "https://www.googleapis.com/auth/forms.body",
    "https://www.googleapis.com/auth/forms.responses.readonly"
]

def get_authorization_url():
    params = {
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "response_type": "code",
        "scope": " ".join(SCOPES),
        "access_type": "offline",
        "prompt": "consent"
    }
    return "https://accounts.google.com/o/oauth2/v2/auth?" + urllib.parse.urlencode(params)

def exchange_code_for_tokens(code):
    data = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "code": code,
        "grant_type": "authorization_code",
        "redirect_uri": REDIRECT_URI
    }).encode()

    req = urllib.request.Request(
        "https://oauth2.googleapis.com/token",
        data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )

    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())

class OAuthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        if "code" in params:
            code = params["code"][0]
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write("認証成功！このウィンドウを閉じてターミナルを確認してください。".encode())

            print("\n" + "="*50)
            print("認証コードを取得しました。トークンを取得中...")
            print("="*50)

            try:
                tokens = exchange_code_for_tokens(code)
                print("\n*** 成功！以下の情報を保存してください ***\n")
                print(f"REFRESH_TOKEN: {tokens.get('refresh_token', 'N/A')}")
                print(f"\nACCESS_TOKEN: {tokens.get('access_token', 'N/A')[:50]}...")
                print("\n" + "="*50)
            except Exception as e:
                print(f"エラー: {e}")

            # サーバーを停止
            raise KeyboardInterrupt
        else:
            self.send_response(400)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # ログを抑制

def main():
    if CLIENT_ID == "ここにClient IDを貼り付け":
        print("エラー: CLIENT_ID と CLIENT_SECRET を設定してください")
        return

    auth_url = get_authorization_url()
    print("\n以下のURLをブラウザで開いてください:\n")
    print(auth_url)
    print("\n認証待機中... (Ctrl+Cで中断)")

    # ブラウザを自動で開く
    webbrowser.open(auth_url)

    # ローカルサーバーを起動して認証コードを受け取る
    server = http.server.HTTPServer(("localhost", 8080), OAuthHandler)
    try:
        server.handle_request()
    except KeyboardInterrupt:
        pass
    server.server_close()

if __name__ == "__main__":
    main()

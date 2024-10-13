from openai import OpenAI
import os

# APIキーをファイルから読み込む関数
def load_api_key(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read().strip()  # 改行文字を除去してAPIキーを取得

# APIキーの読み込み
api_key_file = "/Users/napier3/Library/CloudStorage/Dropbox/OpenAI_api_key.txt"  # APIキーが保存されているファイル
api_key = load_api_key(api_key_file)

# OpenAIクライアントの初期化
client = OpenAI(api_key=api_key)

# GPT APIを使って文章を校正する関数
def proofread_text(text):
    response = client.chat.completions.create(
        model="gpt-4",  # モデル名を指定
        messages=[
            {"role": "system", "content": "You are an assistant who proofreads text."},
            {"role": "user", "content": f"以下の文章を省略することなく，適切な句読点を打ち，誤字脱字、誤変換があれば修正してください。\n\n{text}"}
        ],
        temperature=0.7,
        max_tokens=1500  # トークンの制限に注意
    )

    # ChatGPTからの応答テキストを取得
    return response.choices[0].message.content

# テキストを適切な長さに分割する関数（文字数で分割）
def split_text(text, max_length=1500):
    # 指定した長さに分割
    chunks = [text[i:i+max_length] for i in range(0, len(text), max_length)]
    return chunks

# テキストファイルを読み込んで校正し、別名で保存する関数
def process_text_file(input_file, output_file):
    # テキストファイルを読み込む
    with open(input_file, 'r', encoding='utf-8') as file:
        text = file.read()

    # テキストを分割（文字数で）
    text_chunks = split_text(text, max_length=1500)

    # 校正されたテキストを保存するリスト
    proofread_texts = []

    # 各チャンクを校正
    for i, chunk in enumerate(text_chunks):
        print(f"Processing chunk {i+1}/{len(text_chunks)}")
        proofread_text_result = proofread_text(chunk)
        print(proofread_text_result)
        proofread_texts.append(proofread_text_result)

    # 校正されたすべてのテキストを結合
    final_text = "\n".join(proofread_texts)

    # 校正された文章を別名ファイルに保存
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write(final_text)

    print(f"校正されたテキストが{output_file}に保存されました。")

# 使用例
input_file = "/Users/napier3/Library/CloudStorage/Dropbox/Git/whisper/20241011.txt"  # 読み込み元のテキストファイル
output_file = "20241011_proofread.txt"  # 出力先のファイル名

# 校正処理の実行
process_text_file(input_file, output_file)
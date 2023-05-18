import os
from PIL import Image

def convert_image_dpi(root_folder):
    # フォルダ内のすべてのファイルとサブフォルダをチェック
    for foldername, subfolders, filenames in os.walk(root_folder):
        for filename in filenames:
            # ファイルが画像形式かどうかをチェック
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.tiff', '.bmp', '.gif')):
                file_path = os.path.join(foldername, filename)
                try:
                    # 画像を開いてDPIを取得
                    img = Image.open(file_path)
                    dpi = img.info.get('dpi', (72, 72))[0]  # 画像にDPI情報がない場合、デフォルトで72とする
                    if dpi <= 300:
                        # 元のファイルをバックアップ
                        backup_path = os.path.splitext(file_path)[0] + "_LowerDPI300" + os.path.splitext(file_path)[1]
                        os.rename(file_path, backup_path)
                        # DPIを300に設定して元のファイル名で保存
                        img.save(file_path, dpi=(300, 300))
                        print(file_path,"を上書き保存しました。")
                except IOError:
                    print(f"Cannot open, backup or save image file {file_path}")

def main():
    root_folder = "course_materials2/"  # ここに変換したいフォルダのパスを入力してください。
    convert_image_dpi(root_folder)

if __name__ == "__main__":
    main()

import os
import pandas as pd
import re
from pathlib import Path
import logging
from datetime import datetime
import shutil

# ファイル名パターンのための正規表現
TEX_PATTERN = re.compile(r'^sp\d{2}_\w+\.tex$')
EXCLUDE_FILE = "SocialPsychology_SP.tex"

def should_process_file(filename):
    """処理対象のファイルかどうかを判定"""
    if filename == EXCLUDE_FILE:
        return False
    return bool(TEX_PATTERN.match(filename.lower()))

def setup_logging(log_dir):
    """ロギングの設定"""
    os.makedirs(log_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = os.path.join(log_dir, f'tex_formatting_{timestamp}.log')
    
    logger = logging.getLogger('tex_formatter')
    logger.setLevel(logging.INFO)
    
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.INFO)
    
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)
    
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    return logger

def load_reference_list(csv_path, logger):
    """リファレンスリストを読み込み、検索用の辞書を作成"""
    logger.info(f"リファレンスリスト '{csv_path}' の読み込みを開始")
    df = pd.read_csv(csv_path)
    ref_dict = {}
    for _, row in df.iterrows():
        ref_dict[row['key']] = {
            'type': row['type'],
            'yomi': row['yomi']
        }
    logger.info(f"リファレンスリストから {len(ref_dict)} 件のエントリを読み込みました")
    return ref_dict

def create_index_label(text, key, ref_info):
    """インデックスラベルを作成"""
    idx_type = 'nameidx' if ref_info['type'] == 'name' else 'termidx'
    return f"{text}\\index[{idx_type}]{{{ref_info['yomi']}@{key}}}"

def process_text(text, ref_dict, logger, filename):
    """テキストを処理"""
    logger.info(f"ファイル '{filename}' の処理を開始")
    
    # 括弧の変換を記録
    original_len = len(text)
    text_tmp = text.replace('（', '(').replace('）', ')')
    brackets_count = original_len - len(text_tmp)
    if brackets_count > 0:
        logger.info(f"  - 全角括弧を {brackets_count // 2} 箇所変換しました")
    text = text_tmp
    
    # 句読点の変換を記録
    comma_count = text.count('、')
    text = text.replace('、', '，')
    if comma_count > 0:
        logger.info(f"  - 読点「、」を {comma_count} 箇所変換しました")
    
    # リファレンスの処理を記録
    ref_counts = {}
    
    # テキストを単語単位で分割して処理
    words = []
    current_pos = 0
    
    while current_pos < len(text):
        found_match = False
        # 最長一致から検索
        for key in sorted(ref_dict.keys(), key=len, reverse=True):
            if text.startswith(key, current_pos):
                # キーと一致する部分を見つけた場合
                if key not in ref_counts:
                    ref_counts[key] = 0
                ref_counts[key] += 1
                
                # インデックスラベルを作成
                new_text = create_index_label(key, key, ref_dict[key])
                words.append(new_text)
                
                current_pos += len(key)
                found_match = True
                break
        
        if not found_match:
            # マッチしない場合は1文字進める
            words.append(text[current_pos])
            current_pos += 1
    
    # 処理結果をログに記録
    for key, count in ref_counts.items():
        logger.info(f"  - '{key}' を {count} 箇所インデックス化しました")
    
    if not ref_counts:
        logger.info("  - インデックス化された参照はありませんでした")
    
    return ''.join(words)

def setup_output_directory(current_dir, logger):
    """出力ディレクトリの設定"""
    # 現在のディレクトリの親ディレクトリを取得
    parent_dir = os.path.dirname(current_dir)
    
    # tex_formatted ディレクトリのパスを作成（texと同じ階層に）
    output_dir = os.path.join(parent_dir, 'tex_formatted')
    
    # ディレクトリが存在しない場合は作成
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        logger.info(f"出力ディレクトリを作成しました: {output_dir}")
    else:
        logger.info(f"既存の出力ディレクトリを使用します: {output_dir}")
    
    return output_dir

def process_files(current_dir, ref_dict, logger):
    """TeXファイルを処理"""
    logger.info(f"ディレクトリ '{current_dir}' の処理を開始")
    
    # 出力ディレクトリの設定
    output_dir = setup_output_directory(current_dir, logger)
    
    # .texファイルをフィルタリング
    tex_files = []
    excluded_files = []
    skipped_files = []
    
    for file_path in Path(current_dir).glob('*.tex'):
        if file_path.name == EXCLUDE_FILE:
            excluded_files.append(file_path.name)
        elif should_process_file(file_path.name):
            tex_files.append(file_path)
        else:
            skipped_files.append(file_path.name)
    
    # ファイル処理の概要を記録
    logger.info(f"TeXファイルの検出結果:")
    logger.info(f"  - 処理対象: {len(tex_files)}個")
    if excluded_files:
        logger.info(f"  - 除外ファイル: {', '.join(excluded_files)}")
    if skipped_files:
        logger.info(f"  - パターン不一致: {', '.join(skipped_files)}")
    
    # 対象ファイルを処理
    if not tex_files:
        logger.warning("処理対象のTeXファイルが見つかりませんでした")
        return
    
    for file_path in tex_files:
        logger.info(f"\nファイル '{file_path.name}' の処理を開始")
        
        try:
            # 入力ファイルを読み込み
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # テキストを処理
            processed_content = process_text(content, ref_dict, logger, file_path.name)
            
            # 処理済みファイルを保存
            output_path = os.path.join(output_dir, file_path.name)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(processed_content)
            
            logger.info(f"ファイル '{file_path.name}' の処理が完了しました")
            logger.info(f"保存先: '{output_path}'")
            
        except Exception as e:
            logger.error(f"ファイル '{file_path.name}' の処理中にエラーが発生しました: {str(e)}")

def main():
    # 設定
    current_dir = os.getcwd()  # 現在のディレクトリを取得
    log_dir = os.path.join(current_dir, "logs")
    reference_path = os.path.join(current_dir, "referencelist.csv")
    
    # ロギングの設定
    logger = setup_logging(log_dir)
    logger.info("TeXファイルフォーマットプログラムを開始します")
    
    try:
        # リファレンスリストを読み込み
        ref_dict = load_reference_list(reference_path, logger)
        
        # ファイルを処理
        process_files(current_dir, ref_dict, logger)
        
        logger.info("\n全ての処理が完了しました")
        
    except Exception as e:
        logger.error(f"プログラムの実行中にエラーが発生しました: {str(e)}")

if __name__ == "__main__":
    main()

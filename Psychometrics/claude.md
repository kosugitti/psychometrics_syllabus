# Psychometrics プロジェクト

## プロジェクト概要

心理統計法のテキストとシラバスを管理するプロジェクト。

- `contents_basic/`: テキスト本文 (ch01〜ch28)
- `syllabus_basic/`: シラバス (b01〜b30)
- テキストのch番号とシラバスのb番号が対応する（例: ch05 ↔ b05）

## 解決すべき課題

### 1. シラバスの項立てとテキストの章立ての一致

シラバスの `\begin{description}` 内の `\item[...]`（コマ主題細目）と、テキストの `\section{}`（章立て）が一対一対応していない章がある。

#### 不一致の章リスト

なし（全章対応済み）

#### 対応が取れている章（参考）

- **完全一致**: ch04, ch05, ch08, ch13, ch14, ch18, ch23, ch24, ch25, ch28
- **概ね対応**: ch01-03, ch06-07, ch09-12, ch16-17, ch19-22, ch26-27

#### 対応不要の章

- b15, b30: 試験回（テキストなし）
- b29: ベイジアンモデリング（テキスト未作成）

## ファイル構成

```
Psychometrics/
├── contents_basic/     # テキスト本文
│   ├── ch01_introduction.tex
│   ├── ...
│   └── ch28_bayesian_with_jasp.tex
├── syllabus_basic/     # シラバス
│   ├── b01_Introduction.tex
│   ├── ...
│   └── b30_final_exam.tex
└── claude.md           # このファイル
```

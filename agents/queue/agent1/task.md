# Task
- status: pending
- timestamp: 2026-02-15 16:35:00
- type: ファイル名・参照修正

## Instructions
先ほどの報告【B】のファイル名・参照の問題3件をすべて修正してください。

### 修正内容

#### B-1: シラバスのファイル名タイポ修正
- `Psychometrics/syllabus_basic/b10_Porbability.tex` → `b10_Probability.tex` にリネーム
- `syllabus_basic.tex` 内の `\include` 参照も合わせて修正

#### B-2: BasicBook3.texの第30回参照修正
- `Psychometrics/contents_basic/BasicBook3.tex` 56行目付近
- `\include{m30_SecondSemester}` → `\include{ch30_SecondSemester}` に修正

#### B-3: 大文字・小文字の統一 + タイポ修正
- `BasicBook3.tex` 内の `\include{ch10_Probability}` → `\include{ch10_probability}` に修正
- `ch23_probabilitic_model` のタイポ修正:
  - ファイル名を `ch23_probabilistic_model.tex` にリネーム
  - `BasicBook3.tex` 内の `\include` 参照も `ch23_probabilistic_model` に修正
  - シラバス側 `b23_Probabilitic_model.tex` も `b23_probabilistic_model.tex` にリネーム
  - `syllabus_basic.tex` 内の `\include` 参照も合わせて修正

### 注意
- 修正前後の差分を report.md に報告すること
- ファイルリネームは `git mv` を使うこと

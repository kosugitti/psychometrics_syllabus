# 心理統計教育教材

専修大学人間科学部心理学科では、「心理学データ解析基礎」を1年次の必修科目とし、「心理学データ解析応用」を2年次の選択科目としています。
このページではこれらの授業に準拠した，授業の進行方針文書と，それに対応した心理学の統計学習に関する教材を提供しています。

## シラバスの設計方針

### 基礎編

「統計学」よりも「心理統計学」の視点を重視し、その実践的な使い方や、心理学におけるその役割と前提条件を理解できるように心掛けています。

また、公認心理師の資格取得に対応した内容であり、どの部分がどの要素につながるか理解できるようにしています。

1年間を通じて、以下の5つのテーマに焦点を当てています。

- **推測統計を用いた母集団の理解** 統計学や心理統計学では、単にサンプルから得られたデータを分析するだけでなく、それを用いて母集団全体を理解することが目的です。
- **確率を使った推論** 母集団を理解するための方法として、代表値に基づくモーメント法、確率分布を使用した最尤法、そしてベイズ法があります。
- **要因設計と線形モデル** 心理学では、要因設計により実験条件をコントロールし、平均値の違いを基に分析（平均因果効果）を行うことが多い。この過程は全体として線形モデルによって表現可能です。
- **モデル比較と意思決定** 母集団の推定だけでなく、それを基にした「結論」や「意思決定」を行うためには、モデル比較やNHST（Null Hypothesis Statistical Testing）などの方法が必要です。
- **Rを用いた実践的な学習** 統計ソフトRを使い、理論的な理解だけでなく、自分自身で計算できるスキルも身につけるべきです。

### 応用編

「データ解析基礎」では記述統計と推測統計を学びました。また基礎実験の授業で実際に統計法を使ったレポートも書いていると思います。しかし使い始めると，基礎でわかっていなかったことに気づき始めるのではないでしょうか。この授業は「基礎で学んだ理論」と「基礎実験で行う実践」の間をつなぐ知識を補填します。そのための数学的・実践的技術として，線形代数とプログラミングを中心におきます。


データ解析応用1(前期)では，次の3点に焦点化しています。

- **尺度化の理解** 心理学のアンケートや分析が「心を測定する」ものとしてどのように機能するのか、その原理とモデルを理解し活用できるようにする。
- **多変量解析の理解** 調査研究などから得られた多くの変量を分析することで何が分かるのか、またそれをどう解釈するかを理解する。
- **数学的一貫性の理解** 多変量解析の背後にある数学の原理、特に線形代数を理解することで、多変量解析のメカニズムを統合的に理解する。

データ解析応用2(後期)では，次の3点に焦点化しています。

- **データ生成メカニズムの理解** データを受動的に分析するのではなく、データ生成のメカニズムを理解し、それに基づいて分析を行う能力を養う。
- **シミュレーションによる統計モデルの実践的理解** 統計ソフトRとを用いた数値シミュレーションによって，統計モデルの理解を深める。
- **確率的プログラミング言語Stanによるベイジアンモデリング** 確率型プログラミング言語Stanを用いたベイズ推論と，それに基づくモデリングの技法を知る。


## シラバスと教材の更新とバージョンについて

これらの資料は定期的に更新されます。各ページの左上にあるバージョン情報、または最初のページにある最終更新日時をチェックしてください。
バージョン情報は[セマンティックバージョニング 2.0](https://semver.org/lang/ja/)に従っており、ピリオドで区切られた数字はそれぞれメジャー、マイナー、パッチバージョンを表します。
誤字脱字の修正はパッチバージョン、段落や章の追加・変更、全体の構成変更はマイナーリビジョン、そして大きな方針転換などはメジャーリビジョンとして表されます。

{% include_relative Syllabus_versions1.md %}
{% include_relative Syllabus_versions2a.md %}
{% include_relative Syllabus_versions2b.md %}
{% include_relative Book_versions1.md %}
{% include_relative Book_versions2.md %}

### シラバス

- [心理学データ解析基礎](syllabus_basic.pdf)**2025年度,Ver3にアップデートしました！**
- [心理学データ解析応用 1](syllabus2a.pdf) 
- [心理学データ解析応用 2](syllabus2b.pdf) 

### テキスト

このテキストは授業内容に基づいています。パソコンやタブレットでご覧いただくことをお勧めします。
なお，データ解析基礎は通年で1冊，データ解析応用は前期・後期で分けてまとめています。また，データ解析応用2(後期)は，市販されているテキストとして「数値シミュレーションで読み解く統計の仕組み」(技術評論社)も利用します。 

- [心理学データ解析基礎 授業資料3](BasicBook3.pdf)**2025年度,Ver3にアップデート中！**
- [心理学データ解析基礎 授業資料](Dkiso1_book.pdf)**2024年度までのバージョンです**
- [心理学データ解析応用1 授業資料](Dkiso2_book1.pdf)
- [心理学データ解析応用2 授業資料](Dkiso2_book2.pdf)
- [心理学データ解析応用2 市販テキスト；数値シミュレーションで読み解く統計の仕組み(Amazon)](https://amzn.to/4b4GMlA)
- [心理学データ解析応用 旧バージョン授業資料](Dkiso2_book_ver1.pdf)


### Kindle Direct Publishing

教材を全て印刷するのは手間がかかると思われる方のために、Amazonでペーパーバック版を提供しています。

- [心理学データ解析基礎: R と JASP で学ぶ楽しい心理統計の世界](https://amzn.to/3tuDKn0)


## 授業で用いるデータやRのコード

### サンプルデータ

- [野球選手のデータ 10 年度分](codes/SampleData/BaseballDecade.csv)
- [家賃のデータ](codes/SampleData/yachin.csv)
- [項目反応理論用のデータ](codes/SampleData/IRTsample.csv)
- [体重推移のデータ](codes/SampleData/Weight.csv)
- [M-1 グランプリの評定データ](codes/SampleData/M1score2023.csv)

### 心理学データ解析基礎

- [二群の平均値差](codes/Dkiso1/20_example.R)
- [R による分散分析のコード](codes/Dkiso1/Chapter22ANOVA.R)
- [R による分散分析のコード(Rmd ファイルバージョン)](codes/Dkiso1/Chapter22ANOVA.Rmd)
- [分散分析課題用データセット 1](codes/SampleData/chapter22exe1.csv)
- [分散分析課題用データセット 2](codes/SampleData/chapter22exe2.csv)
- [分散分析課題用データセット 3](codes/SampleData/chapter22exe3.csv)

### 心理学データ解析応用

- [事前準備；Rstan の確認用コード](codes/Dkiso2/00_Appendix1_rstan.R)
- [事前準備；cmdstanr の確認用コード](codes/Dkiso2/00_Appendix1_cmdstanr.R)
- [第 01 回；プログラミングの基礎](codes/Dkiso2/01_BasicProgramming.R)
- [第 02 回；プログラミングの基礎](codes/Dkiso2/02_randomVariables.R)
- [第 03 回；stan の基礎(rstan)](codes/Dkiso2/03_exampleRstan.R)
- [第 03 回；stan の基礎(cmdstan)](codes/Dkiso2/03_exampleCmdstan.R)
- [第 04 回；平均値の差の検定(rstan)](codes/Dkiso2/04_exampleRstan.R)
- [第 04 回；平均値の差の検定(cmdstan)](codes/Dkiso2/04_exampleCmdstan.R)
- [第 05 回；生成量を使って(rstan)](codes/Dkiso2/05_exampleRstan.R)
- [第 05 回；生成量を使って(cmdstan)](codes/Dkiso2/05_exampleCmdstan.R)
- [第 06 回；多群の平均値の比較(rstan)](codes/Dkiso2/06_AnovaExampleRstan.R)
- [第 06 回；多群の平均値の比較(cmdstan)](codes/Dkiso2/06_AnovaExampleCmdstan.R)
- [第 07 回；Within モデルの平均値の比較(rstan)](codes/Dkiso2/07_WithinExampleRstan.R)
- [第 07 回；Within モデルの平均値の比較(cmdstan)](codes/Dkiso2/07_WithinExampleCmdstan.R)
- [第 08 回；カテゴリカルモデルの分析(rstan)](codes/Dkiso2/08_categoricalRstan.R)
- [第 08 回；カテゴリカルモデルの分析(cmdstan)](codes/Dkiso2/08_categoricalCmdstan.R)
- [第 09 回；一般化線形モデル(rstan)](codes/Dkiso2/09_GLM_Rstan.R)
- [第 09 回；一般化線形モデル(cmdstan)](codes/Dkiso2/09_GLM_Cmdstan.R)
- [第 10 回；一般化線形混合モデル・階層線形モデル(rstan)](codes/Dkiso2/10_GLMM_Rstan.R)
- [第 10 回；一般化線形混合モデル・階層線形モデル(cmdstan)](codes/Dkiso2/10_GLMM_Cmdstan.R)
- [第 11 回；混合分布モデル(rstan)](codes/Dkiso2/11_Mixture_Rstan.R)
- [第 11 回；混合分布モデル(cmdstan)](codes/Dkiso2/11_Mixture_Cmdstan.R)
- [第 12 回；IRT モデル(rstan)](codes/Dkiso2/12_IRT_Rstan.R)
- [第 12 回；IRT モデル(cmdstan)](codes/Dkiso2/12_IRT_Cmdstan.R)
- [第 13 回；変化点検出・折線回帰(rstan)](codes/Dkiso2/13_changePoint_Rstan.R)
- [第 13 回；変化点検出・折線回帰(cmdstan)](codes/Dkiso2/13_changePoint_Cmdstan.R)
- [第 14 回；状態空間モデル(rstan)](codes/Dkiso2/14_stateSpace_Rstan.R)
- [第 14 回；状態空間モデル(cmdstan)](codes/Dkiso2/14_stateSpace_Cmdstan.R) 

## そのほかのコンテンツ

### 2022 夏 数学ワークショップ＃１

「深層学習は心理学に革新をもたらすか？オープンサイエンスによる理論的・実践的検証」というプロジェクトの一環で，2022 年夏の数学ワークショップの講師を担当させていただきました。その時の資料をこちらにおいております。(2023/05/10 reOpen!)

- [心理学者のための線形代数](LABC.pdf) 

### 2022 9 月 広島大学集中講義資料

2022 年度広島大学総合科学部で開かれた「行動科学特論」は，心理測定をテーマに講義をまとめました。
授業で用いた資料をアップしております(2023/05/11 update!)。

- [心理教育測定法](Scaling.pdf)

### 2024 秋　東京大学非常勤　授業資料

2024年度秋学期　東京大学文学部で開かれた「社会心理学特殊講義」について，講義録を文字起こしした資料を作っています。

- [社会心理学特殊講義](SocialPsychology_SP.pdf)

## 付録のまとめ

パソコンのファイル概念，キーボード配列など，テキストの付録に含まれる内容だけをまとめたものを作りました。
ここだけでも，どこかの誰かの補助教材になればと思って公開しています。
「ついでにこの辺も教えておいてよ！」ということがあればご連絡ください。暇があれば書き足します。

-[電子計算機えとせとら](common_contents.pdf)


## 旧版アーカイブ

シラバスは常々微修正を行います。過去のバージョンアーカイブは下記の通りです。

- 応用V1, KDP :[心理学データ解析応用 1/心理学データ解析応用 2/ 授業資料](Dkiso2_book_ver1.pdf) 
- 応用V1, PDF :[心理学データ解析応用: R と Stan で学ぶフリーで楽しい心理統計の世界](https://amzn.to/3L8aecK)
- [応用V1サンプルコード(zip)](codes/ArchiveOUYOUver1.zip)


## ライセンス等

[Written by Kosugitti](https://researchmap.jp/kosugitti)

<a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="クリエイティブ・コモンズ・ライセンス" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />この 作品 は <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">クリエイティブ・コモンズ 表示 - 改変禁止 4.0 国際 ライセンス</a>の下に提供されています。

## 連絡先

+ ここでのコンテンツについて，修正等の連絡は，当[GithubレポジトリのIssue](https://github.com/kosugitti/psychometrics_syllabus/issues)からお願いします。みんなで相談したいことがあれば，[Discussions](https://github.com/kosugitti/psychometrics_syllabus/discussions)もご利用ください。
+ 著者の連絡先は kosugitti _at_ gmail.com までお願いします。(_at_ を@に変えてください)。
+ 授業に関する連絡先は，classkosugitti _at_ gmail.com までお願いします。(_at_ を@に変えてください)。


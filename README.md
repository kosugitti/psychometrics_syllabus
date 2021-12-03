# 心理統計教育教材

心理統計教育の授業シラバス（コマシラバス）と授業の教材です。
専修大学人間科学部心理学科では，1 年次に「心理学データ解析基礎」を必修として履修します。2 年次に「心理学データ解析応用」がありますが，こちらは選択科目です。

## 想定している教育環境等

- 通年の授業(30 回)で，前期・後期にそれぞれ授業時間内テストを行うために 1 コマ使います。
- 途中で R/RStudio をつかった実習を含みます。(統計環境は R に限ります)

## シラバスの設計方針

### 基礎編

「統計学」ではなく「心理」統計なので，実践的な使い方や心理学における目的，仮定を明確にすることを心がけました。

また，公認心理師対応科目ですので，ここで身につける内容が資格のどの要素に対応しているかわかるようにしました。

一年を通じて共通するテーマは次の 5 つです。

- **[母数を知るための推測]** 大学での統計，心理統計は標本の記述統計量を検証したいのではなく，母集団を表す数字を求めるための推測統計である。
- **[確率を用いた推論]** 母数を知るための方法は 3 つある。代表値を用いたモーメント法，確率分布をつかった最尤法，ベイズ法である。
- **[要因計画と線形モデル]** 心理学では，要因計画による研究条件をコントロールし，平均値の差をもちいた考察(平均因果効果)をおこなうことが多い。そしてそれらは総じて線形モデルとして表現できる。
- **[モデル比較と意思決定]** モデルによる母数の推定だけではなく，そこから一定の「結論」あるいは「意思決定」を行うための方法として，モデル比較や NHST といった方法がある。
- **[統計環境 R による実践]** 統計環境 R を利用して，理論的な理解だけでなく実際に計算ができることも身につけるべき技術である。

### 応用編

既に基礎を履修済みであることを前提に，より発展的な知識を応用できるようにするために，心理測定・尺度作成の観点，数学的基礎，数理モデリングを題材にしています。
数学的話題に振り回されることなく，心理学的応用を目指すもの(統計のユーザ)として必要な知識を習得し，データ解析を統合的・俯瞰的に眺めることができるようになることが目標です。

一年を通じて共通するテーマは次の 5 つです。

- **尺度化とは何か** 心理学で行われるアンケート調査やその後の分析はどういう原理があって「心を測定した」といえるのか。その原理やモデルを理解して利用できるようになる。
- **多変量解析から何がわかるのか** 調査研究などで得られた多変量を分析することで何がわかるのか。あるいは何をしてわかったというのか。
- **数学的共通性** 多変量解析の背景にあるのは線形代数という数学であり，線形代数の基礎を学ぶことで多変量解析のメカニズムを統合的に理解できる。
- **データ生成メカニズム** データから情報を取り出す受け身的な分析ではなく，データに数字を与えたり，データが生まれてくるメカニズムをリバースエンジニアリングすることで，さらに積極的にデータ解析に立ち向かおう。
- **統計環境 R と確率的プログラミング言語 Stan による実践** 統計環境 R と確率的プログラミング言語 Stan に習熟することで実際に計算し，確認しながら分析を進めることができる。

## シラバスと授業教材

いずれも随時更新していきます。各ページのヘッダ左にあるバージョン情報か，最初のページにある最終コンパイル日時をみておいてください。
バージョン情報は[セマンティックバージョニング 2.0](https://semver.org/lang/ja/)に準拠しており，ピリオドで区切られた数字がメジャー.マイナー.パッチに該当します。
誤字脱字の修正レベルはパッチ，段落や章立て，構成の変更がマイナーリビジョン，方針の転換などがメジャーリビジョンになります。

{% include_relative Syllabus_versions1.md %}
{% include_relative Syllabus_versions2.md %}
{% include_relative Book_versions1.md %}
{% include_relative Book_versions2.md %}

### シラバス

- [心理学データ解析基礎 1(心理学統計法)/心理学データ解析 2/心理学データ解析 1AB](syllabus.pdf)
- [心理学データ解析応用 1/心理学データ解析応用 2/心理学データ解析 2AB](syllabus2.pdf)

### 授業教材

- [心理学データ解析基礎 1(心理学統計法)/心理学データ解析 1A 授業資料](Dkiso1_book.pdf)
- [心理学データ解析応用 1/心理学データ解析応用 2/心理学データ解析 2AB 授業資料](Dkiso2_book.pdf)

## 授業の R コード

### 心理学データ解析基礎 2

- [二群の平均値差](codes/Dkiso1/20_example.R)
- [R による分散分析のコード](codes/Dkiso1/Chapter22ANOVA.R)
- [R による分散分析のコード(Rmd ファイルバージョン)](codes/Dkiso1/Chapter22ANOVA.Rmd)
- [Chapter22 課題ファイル(zipで圧縮してあります)](codes/Dkiso1/chapter22exe.zip)

### 心理学データ解析応用 2

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
- [第 06 回；多群の平均値の比較；応用課題・データセットない人用](codes/Dkiso2/baseball2020.csv)
- [第 07 回；Within モデルの平均値の比較(rstan)](codes/Dkiso2/07_WithinExampleRstan.R)
- [第 07 回；Within モデルの平均値の比較(cmdstan)](codes/Dkiso2/07_WithinExampleCmdstan.R)
- [第 08 回；カテゴリカルモデルの分析(rstan)](codes/Dkiso2/08_categoricalRstan.R)
- [第 08 回；カテゴリカルモデルの分析(cmdstan)](codes/Dkiso2/08_categoricalCmdstan.R)
- [第 09 回；一般化線形モデル(rstan)](codes/Dkiso2/09_GLM_Rstan.R)
- [第 09 回；一般化線形モデル(cmdstan)](codes/Dkiso2/09_GLM_Cmdstan.R)
- [野球選手のデータ](codes/Dkiso2/baseball2020.csv)
- [第 10 回；一般化線形混合モデル・階層線形モデル(rstan)](codes/Dkiso2/10_GLMM_Rstan.R)
- [第 10 回；一般化線形混合モデル・階層線形モデル(cmdstan)](codes/Dkiso2/10_GLMM_Cmdstan.R)
- [野球選手のデータ10年度分](codes/Dkiso2/baseballDecade.csv)
- [第 11 回；混合分布モデル(rstan)](codes/Dkiso2/11_Mixture_Rstan.R)
- [第 11 回；混合分布モデル(cmdstan)](codes/Dkiso2/11_Mixture_Cmdstan.R)
- [項目反応理論用のデータ](codes/Dkiso2/IRTsample.csv)
- [第 12 回；IRTモデル(rstan)](codes/Dkiso2/12_IRT_Rstan.R)
- [第 12 回；IRTモデル(cmdstan)](codes/Dkiso2/12_IRT_Cmdstan.R)


## ライセンス等

[Written by Kosugitti](https://researchmap.jp/kosugitti)

<a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="クリエイティブ・コモンズ・ライセンス" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />この 作品 は <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">クリエイティブ・コモンズ 表示 - 改変禁止 4.0 国際 ライセンス</a>の下に提供されています。

# The syllabus and textbook for undergraduate students in psychological statistics

At the School of Human Sciences, Department of Psychology, Senshu University, "Fundamentals of Psychological Data Analysis" is a required course in the first year and "Applied Psychological Data Analysis" is an elective course in the second year.
On this page, we provide teaching materials related to psychology and statistics that correspond to the progress report document for these classes.

[The Japanese version of this website ](Readme.html)

## The design principles of the syllabus

### Basic Class

The syllabus places emphasis on the perspective of "psychological statistics" rather than "statistics" and strives to ensure that students understand its practical application, as well as its role and prerequisites in the field of psychology.

This syllabus clearly demonstrates how the elements outlined in the standard syllabus for licensed psychologists are incorporated.

Throughout the academic year, the syllabus focuses on the following five themes:

- **Understanding the population using inferential statistics**: The purpose of statistics and psychological statistics is not only to analyze data obtained from samples but also to gain an understanding of the entire population using that data.
- **Inference using probability**: To comprehend the population, various methods are employed, such as the method of moments based on representative values, maximum likelihood estimation utilizing probability distributions, and Bayesian methods.
- **Factorial designs and linear models**: In psychology, factorial designs are frequently used to control experimental conditions and conduct analyses (average causal effects) based on differences in means. This process can be effectively represented using linear models as a whole.
- **Model comparison and decision making**: To draw conclusions and make informed decisions based on population estimates, techniques such as model comparison and Null Hypothesis Statistical Testing (NHST) are essential.
- **Practical learning using R**: Students are encouraged to develop not only theoretical understanding but also the ability to perform calculations independently, using the statistical software R.

### Advanced Course

Targeted towards individuals who have already completed the foundational course, this course aims to provide advanced knowledge and understanding, enabling participants to comprehend psychology measurement, scale development, mathematical foundations, and mathematical modeling. The focus is on learning that emphasizes psychological applications without being overwhelmed by mathematical challenges.

Throughout the year, the course centers around the following five themes:

- **Understanding psychological scaling**: Participants will gain an understanding of how psychological questionnaires and analyses function as measures of the mind, and learn the principles and models behind them to effectively utilize them.
- **Understanding multivariate analysis**: Participants will comprehend what can be learned from analyzing numerous variables obtained from research studies and surveys, as well as how to interpret those results.
- **Understanding mathematical coherence**: By grasping the mathematical principles, particularly linear algebra, underlying multivariate analysis, participants will develop a comprehensive understanding of the mechanisms involved.
- **Understanding data generation mechanisms**: Rather than passively analyzing data, participants will cultivate the ability to understand the mechanisms of data generation and perform analyses based on that understanding.
- **Practical learning using R and Stan** : Participants will engage in hands-on calculations using the statistical software R and the probabilistic programming language Stan, enabling them to progress through analyses while verifying their results.

Through this course, participants will acquire advanced knowledge that builds upon the foundational course, allowing them to understand psychology from the perspectives of measurement, scale development, mathematical foundations, and mathematical modeling. The focus is on applying this understanding to psychological applications, while ensuring that participants are not overwhelmed by mathematical challenges.

## Syllabus and Textbook Updates and Versions

These materials are regularly updated. Please check the version information located at the top left corner of each page or the last updated date mentioned on the first page.
The version information follows [Semantic Versioning 2.0 standards](https://semver.org/), where the numbers separated by periods represent major, minor, and patch versions, respectively.
Fixes for typos or errors correspond to patch versions, while the addition or modification of paragraphs or chapters, as well as structural changes to the entire content, indicate minor revisions. Major revisions signify significant policy changes or shifts in direction.

{% include_relative Syllabus_versions1.md %}
{% include_relative Syllabus_versions2.md %}
{% include_relative Book_versions1.md %}
{% include_relative Book_versions2.md %}

### syllabus

- [Basic Course syllabus](syllabus.pdf)
- [Advance Course syllabus](syllabus2.pdf)

### Textbook(PDF)

This text is based on the course content. We recommend viewing it on a computer or tablet.

- [Basic Course textbook](Dkiso1_book.pdf)
- [Advance Course textbook](Dkiso2_book.pdf)

### Kindle Direct Publishing

For those who find it cumbersome to print all the materials, we offer paperback versions on Amazon.
The paperback version of the foundational course is labeled as version 2.0.33, while the advanced course is labeled as version 1.2.55.

- [Basic Course textbook on KDP](https://amzn.to/3tuDKn0)
- [Advance Course textbook on KDP](https://amzn.to/3L8aecK)

## Sample Data and R code

### Sample Data

- [Baseball Player Data for 10 Years](codes/SampleData/BaseballDecade.csv)
- [Yachin Data](codes/SampleData/yachin.csv)
- [Example Data for IRT](codes/SampleData/IRTsample.csv)
- [Author's weight transition data](codes/SampleData/Weight.csv)
- [M-1 GrandPrix Data](codes/SampleData/M1score2022.csv)

### R-code for Basic Course

- [二群の平均値差](codes/Dkiso1/20_example.R)
- [R による分散分析のコード](codes/Dkiso1/Chapter22ANOVA.R)
- [R による分散分析のコード(Rmd ファイルバージョン)](codes/Dkiso1/Chapter22ANOVA.Rmd)
- [分散分析課題用データセット 1](codes/SampleData/chapter22exe1.csv)
- [分散分析課題用データセット 2](codes/SampleData/chapter22exe2.csv)
- [分散分析課題用データセット 3](codes/SampleData/chapter22exe3.csv)

### R-code for Advance Course

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

## Other owrks

### Summer Mathematics Boot Camp 2022

As part of the project titled "Can Deep Learning Revolutionize Psychology? Theoretical and Practical Validation through Open Science," I had the opportunity to serve as a workshop instructor for a mathematics workshop in the summer of 2022. I am sharing the materials from that session here. (Updated on May 10, 2023 reOpen!)

- [Linear Algebra for Psychologists](LABC.pdf)

### September 2022 Hiroshima University Intensive Lecture Materials

As part of the "Special Topics in Behavioral Science" course held at Hiroshima University in the academic year 2022, I have compiled the lectures focusing on psychological measurement.
I have uploaded the materials used in the class (Updated on May 11, 2023!).

- [Psychological Educational Measurement Methods](Scaling.pdf)

## Licenses

[Written by Kosugitti](https://researchmap.jp/kosugitti)

<a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
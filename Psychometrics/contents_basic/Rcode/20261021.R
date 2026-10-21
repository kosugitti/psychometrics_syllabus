# 新しく知ったパッケージを試してみよう
rm(list = ls())

## afex+emmeans
# aov_ez() や aov_4() で，群間・群内・混合を1つの書き方で扱えます。球面性の補正 (GG/HF) と効果量も出ます。
# 下位検定と単純主効果は emmeans (pairs()，joint_tests(by=)) で出します。
pacman::p_load(tidyverse, afex, emmeans, brms)
# anovakun
source("https://riseki.cloudfree.jp/?plugin=attach&refer=ANOVA%E5%90%9B&openfile=anovakun_489.txt")


## 仮想データ
source("ANOVA_dataMaker.R")

dat1 <- make_anova_data("As", levels = c(3))
anovakun(dat1, "As", long = T)
dat2 <- make_anova_data("sA", levels = c(3))
anovakun(dat2, "sA", long = T)
dat3 <- make_anova_data("ABs", levels = c(3, 2))
anovakun(dat3, "ABs", long = T)
dat4 <- make_anova_data("sAB", levels = c(3, 2))
anovakun(dat4, "sAB", long = T)
dat5 <- make_anova_data("AsB", levels = c(3, 2))
anovakun(dat5, "AsB", long = T)


# データ(Aが群間，Bが群内。Aの主効果と交互作用あり) ------------------------------
dat <- make_anova_data("AsB",
  n = 10, levels = c(2, 3), A = TRUE, AB = TRUE,
  match = TRUE, seed = 1
)
anovakun(dat, "AsB", long = T)


# 分散分析 --------------------------------------------------------------------
fit <- afex::aov_ez(
  id = "id", dv = "value", data = dat,
  between = "A", within = "B",
  anova_table = list(es = "pes")
)
fit # 分散分析表(球面性はGreenhouse-Geisserで自動補正)
summary(fit) # Mauchlyの球面性検定やε(GG・HF)の値も見たいとき

# 単純効果(Aの水準ごとにBの効果を検定) ---------------------------------------------
emmeans::joint_tests(fit, by = "A")

# 多重比較(Aの水準ごとにBの水準どうしを比べる) ---------------------------------------
emm <- emmeans::emmeans(fit, ~ B | A)
pairs(emm, adjust = "holm")

# 図(平均と信頼区間) --------------------------------------------------------------
afex::afex_plot(fit, x = "B", trace = "A")

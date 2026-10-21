#
# NHST関係の例題をつくるコード
#

# 準備 ----------------------------------------------------------------------
set.seed(2016)
source("https://riseki.cloudfree.jp/?plugin=attach&refer=ANOVA%E5%90%9B&openfile=anovakun_489.txt")
source("http://aoki2.si.gunma-u.ac.jp/R/src/boheikin.R", encoding = "euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/cor2_test.R", encoding = "euc-jp")

# TeXやmarkdownで出力する用
library(xtable)
library(pander)

# 標準化 ---------------------------------------------------------------------
dat <- c(153, 172, 160, 159, 166)
(dat - mean(dat)) / sd(dat)
# not unbiased sd
(dat - mean(dat)) / sqrt(mean((dat - mean(dat))^2))
# P value
pnorm(1) - pnorm(0)
pnorm(0.5)
pnorm(1.96) - pnorm(-1.96)

# 相関係数の検定 -----------------------------------------------------------------
cor2.test(n = 100, r = 0.25)


# カイ二乗検定(2*2) -------------------------------------------------------------
tbl <- matrix(c(31, 29, 25, 35), nrow = 2, byrow = T)
chisq.test(tbl, correct = F)


# t-test ------------------------------------------------------------------

# サンプルサイズ
n <- 10
# 平均値
mu <- 15
# 効果量
delta <- 0.8
# 標準偏差
sig <- 10

# データ生成
groupA <- round(rnorm(n, mu, sig))
groupB <- round(rnorm(n, mu + (delta * sig), sig))
rbind(groupA, groupB)
t.test(groupA, groupB)
# TeX出力
xtable(cbind(groupA, groupB), digit = 0)


# Paired t ----------------------------------------------------------------
library(MASS)
# サンプルサイズ
n <- 20
# 平均値
mu <- 15
# 効果量
delta <- 0.8
# 標準偏差
sig <- 10
# 対応の強さ
rho <- 0.2

# データ生成
cov <- matrix(c(sig^2, rho * sig * sig, rho * sig * sig, sig^2), nrow = 2)
dat <- mvrnorm(n, mu = c(mu, mu + (delta * sig)), cov)
pre <- round(dat[, 1])
post <- round(dat[, 2])
t.test(pre, post, paired = TRUE)

tbl <- matrix(rbind(pre, post), nrow = 2, byrow = F)
rownames(tbl) <- c("pre", "post")
colnames(tbl) <- rep(paste0("S", 1:n))
pander::pandoc.table(tbl, style = "rmarkdown", caption = "授業の効果", split.tables = 100)

# 分散分析 --------------------------------------------------------------------


# As Design -------------------
# サンプルサイズ
n <- 5
# 平均値
mu <- 15
# 効果量
delta <- 0.8
# 標準偏差
sig <- 10
x1 <- round(rnorm(n, mu - (delta * sig), sig))
x2 <- round(rnorm(n, mu, sig))
x3 <- round(rnorm(n, mu + (delta * sig), sig))
dat <- data.frame(id = 1:(3 * n), 袋 = c(rep("A", n), rep("B", n), rep("C", n)), 長さ = c(x1, x2, x3))
anovakun(dat[, -1], "As", 3)
pandoc.table(dat, style = "rmarkdown", caption = "お菓子の長さ")


# sA Design -------------------
# サンプルサイズ
n <- 15
# 平均値
mu <- 50
# 効果量
delta <- 0.8
# 標準偏差
sig <- 10
# 平均ベクトル
mu_vec <- c(mu - (delta * sig), mu, mu + (delta * sig))
# 標準偏差ベクトル
sig <- rep(sig, 3)
# 関係の強さ
cor <- 0.3
cov <- sig %*% t(sig) * cor
diag(cov) <- sig^2
# データ形成
dat <- round(mvrnorm(n, mu_vec, cov))
anovakun(dat, "sA", 3, peta = T)
rownames(dat) <- 1:n
colnames(dat) <- c("前", "中", "後")
pandoc.table(dat, style = "rmarkdown", caption = "成績の変化")

# ABs design  -------------------

# 1セルあたりの被験者数
n <- 10
# 平均
mu <- 50
# 効果量
deltaA <- 0.8
deltaB <- 0
deltaAB <- 0.1
# 標準偏差
sig <- 10
factorA <- c(rep("A", n * 2), rep("B", n * 2))
factorB <- rep(c(rep("X", n), rep("Y", n)), 2)

# データ整形
A1B1 <- mu + deltaA * sig + deltaB * sig + deltaAB * sig + rnorm(n, 0, sig)
A1B2 <- mu + deltaA * sig - deltaB * sig - deltaAB * sig + rnorm(n, 0, sig)
A2B1 <- mu - deltaA * sig + deltaB * sig - deltaAB * sig + rnorm(n, 0, sig)
A2B2 <- mu - deltaA * sig - deltaB * sig + deltaAB * sig + rnorm(n, 0, sig)
score <- round(c(A1B1, A1B2, A2B1, A2B2))

gunkan <- data.frame(factorA, factorB, score)
anovakun(gunkan, "ABs", 2, 2)

## TeX 出力
xtable(gunkan, digit = 0)

# AsB design  -------------------
# 1セルあたりの被験者数
n <- 10
# 平均
mu <- 50
# 効果量
deltaA <- 0.8
deltaB <- 0.2
deltaAB <- 0.9
# 標準偏差
sig <- 10
# 平均ベクトル
mu_vec <- rep(mu, 2)
sd_vec <- rep(sig, 2)
cor <- 0.5
cov <- sd_vec %*% t(sd_vec) * cor
diag(cov) <- sd_vec^2

mu_vec[1] <- mu_vec[1] + deltaB * sig
mu_vec[2] <- mu_vec[2] - deltaB * sig
dat1 <- mvrnorm(n, mu_vec, cov) + deltaA * sig
dat1[1:n] <- dat1[1:n] + deltaAB * sig
dat1[(n + 1):(n * 2)] <- dat1[(n + 1):(n * 2)] - deltaAB * sig
dat2 <- mvrnorm(n, mu_vec, cov) - deltaA * sig
dat2[1:n] <- dat2[1:n] - deltaAB * sig
dat2[(n + 1):(n * 2)] <- dat2[(n + 1):(n * 2)] + deltaAB * sig
dat <- rbind(dat1, dat2)

dat <- round(dat)
colnames(dat) <- c("前", "後")
dat <- data.frame(id = 1:(n * 2), テキスト = c(rep("A1", n), rep("A2", n)), dat)
anovakun(dat[, -1], "AsB", 2, 2)

pandoc.table(dat, style = "rmarkdown", caption = "テキストと成績の変化")


# 回帰分析
n <- 20
x1 <- round(rnorm(n, 50, 10))
y <- round(0.8 * x1 + rnorm(n, 0, 10))
dat <- data.frame(国語 = y, 算数 = x1)
summary(lm(国語 ~ 算数, data = dat))

pandoc.table(dat, style = "rmarkdown", caption = "国語と算数の成績")

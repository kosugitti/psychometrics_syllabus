rm(list = ls())
## サンプルデータを生成するためのコード
library(tidyverse)
library(ltm)
library(irtoys)
library(psych)
set.seed(20220605)

# IRT関数の設定
threePL <- function(a, b, c, theta) {
  prob <- c + ((1 - c) / (1 + exp(-1.7 * a * (theta - b))))
}

# 項目母数の真値を設定
M <- 10 # 項目数
a_true <- rnorm(M, 1, 0.2) # 識別力パラメータ
b_true <- runif(M, -3, 3) # 困難度パラメータ
c_true <- runif(M, 0, 0.2) # あて推量母数

# データの生成
N <- 500 # サンプルサイズ
X <- rnorm(N, 0, 1) |> transform()
tmp <- matrix(nrow = N, ncol = M)
for (i in 1:N) {
  for (j in 1:M) {
    prob <- threePL(a_true[j], b_true[j], c_true[j], X$X_data[i])
    tmp[i, j] <- rbinom(1, 1, prob)
  }
}

sample <- as.data.frame(tmp)

write_csv(sample, file = "IRTsample.csv")
sample %>%
  head() %>%
  knitr::kable(format = "latex", caption = "IRTで使うサンプルデータ(一部)")


# chapter11 ---------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(ltm)
dat <- read_csv("IRTsample.csv", locale = locale(encoding = "UTF-8"))
ltm::descript(dat)
#### Point Biserial correlationとpolyserial相関係数を比較したくなった
# dat %>% rowwise() %>% mutate(total=sum(c_across(V1:V10))) %>% unnest() %>%
#     dplyr::select(V1,total) %>%
#     dplyr::mutate(V1 = as.factor(V1)) %>%
#     polycor::hetcor()


chisq.test(dat$V2, dat$V10)
xtabs(~ dat$V2 + dat$V10)

result.1pl <- rasch(dat)
print(result.1pl)
png("../images/chapter11/Rplot11_01.png", width = 1200, height = 600)
par(mfcol = c(1, 3))
plot(result.1pl, type = "ICC")
plot(result.1pl, type = "IIC")
plot(result.1pl, type = "IIC", items = 0)
dev.off()

result.2pl <- ltm(dat ~ z1)
print(result.2pl)
png("../images/chapter11/Rplot11_02.png", width = 1200, height = 600)
par(mfcol = c(1, 3))
plot(result.2pl, type = "ICC")
plot(result.2pl, type = "IIC")
plot(result.2pl, type = "IIC", items = 0)
dev.off()


result.3pl <- tpm(dat)
print(result.3pl)
png("../images/chapter11/Rplot11_03.png", width = 1200, height = 600)
par(mfcol = c(1, 3))
plot(result.3pl, type = "ICC")
plot(result.3pl, type = "IIC")
plot(result.3pl, type = "IIC", items = 0)
dev.off()


# GRM ---------------------------------------------------------------------

library(psych)
dat <- bfi %>%
  dplyr::select(-gender, -education, -age) %>%
  dplyr::select(starts_with("N"))
result.grm <- grm(dat)
result.grm
plot(result.grm, type = "ICC", items = 1)
plot(result.grm, type = "ICC", items = 4)
plot(result.grm, type = "IIC", items = 1)
plot(result.grm, type = "ICC", items = 4)
plot(result.grm, type = "IIC", items = 4)
plot(result.grm, type = "IIC", items = 0)

png("../images/chapter11/Rplot11_04.png", width = 1200, height = 600)
par(mfcol = c(1, 2))
plot(result.grm, type = "ICC", items = 1)
plot(result.grm, type = "ICC", items = 4)
dev.off()


irtoys::est(dat, model = "2PL", engine = "ltm")

ltm::rasch(sample)
irtoys::est(dat, model = "1PL", engine = "ltm")

tpm(sample)
irtoys::est(dat, model = "3PL", engine = "ltm")



# fa.poly -----------------------------------------------------------------

dat <- bfi %>% dplyr::select(-gender, -education, -age)
result.fa <- fa.poly(dat, nfactors = 5, rotate = "geominQ")
print(result.fa, sort = T, cut = 0.3)

fa(dat, nfactors = 5, rotate = "geominQ") %>% print(sort = T, cut = 0.3)

library(mirt)
result.mirt <- mirt(dat, 5)
print(result.mirt)
result.mirt %>% summary(rotate = "geominQ")

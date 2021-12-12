# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 5. Alternatives for t-test2. Cmdstanr Version

rm(list = ls())
library(tidyverse)
library(cmdstanr)
library(bayesplot)
# データなど -------------------------------------------------------------------

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)

# Modeling ----------------------------------------------------------------

modelC <- cmdstanr::cmdstan_model("ttest05.stan")
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)

sampling2 <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)

## 結果
sampling2

## 可視化

## 事後分布と事後予測分布
sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  pivot_longer(-.draw) %>%
  dplyr::filter(str_detect(name, pattern = "pred1") | str_detect(name, pattern = "mu1")) %>%
  dplyr::mutate(name2 = if_else(name == "mu1", "mu1", "Xpred1")) %>%
  ggplot(aes(x = value, group = name2)) +
  geom_density(binwidth = 1) +
  facet_wrap(~name2) +
  xlim(-10, 150)

### 事後予測分布
pred <- sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  pivot_longer(-.draw) %>%
  dplyr::filter(str_detect(name, pattern = "Xpred1")) %>%
  pivot_wider(names_from = name, values_from = value, id_cols = .draw) %>%
  dplyr::select(-.draw) %>%
  as.matrix()

bayesplot::ppc_hist(y = groupA, yrep = pred[sample(nrow(pred), 15), ])


# 優越率と閾上率 -----------------------------------------------------------------

modelC <- cmdstanr::cmdstan_model("ttest06.stan")
groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8, C = 3)
sampling2 <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling2

# パラメータリカバリ ---------------------------------------------------------------

mu1 <- 50
diff <- 10
mu2 <- mu1 + diff
sig1 <- 5
sig2 <- 8

set.seed(12345)
N <- 10
X1 <- rnorm(N, mu1, sig1)
X2 <- rnorm(N, mu2, sig2)

## t検定(モーメント法による推定と判定)
t.test(X1, X2)
## ベイズ推定(MCMCによるベイズ推定と差の分布)
dataSet <- list(X1 = X1, X2 = X2, N1 = N, N2 = N)

modelC <- cmdstanr::cmdstan_model("ttest03.stan")
sampling2 <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling2
### うまくいかない例
mu1 <- 50
diff <- 18
mu2 <- mu1 + diff
sig1 <- 10
sig2 <- 15

set.seed(12345)
N <- 3
X1 <- rnorm(N, mu1, sig1)
X2 <- rnorm(N, mu2, sig2)

## t検定(モーメント法による推定と判定)
t.test(X1, X2)
## ベイズ推定(MCMCによるベイズ推定と差の分布)
dataSet <- list(X1 = X1, X2 = X2, N1 = N, N2 = N, C = 3)
modelC <- cmdstanr::cmdstan_model("ttest03.stan")
sampling2 <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling2

# 課題 ----------------------------------------------------------------------
potatoA <- c(8.4, 11.3, 8.1, 11.2, 5.8, 6.3, 7.1, 10.9, 7.1, 6.5, 5.0, 3.0, 7.2, 6.5, 6.4, 6.4, 9.3, 8.3)
potatoB <- c(6.7, 7.2, 4.2, 11.0, 7.5, 8.9, 7.0, 8.0, 7.2, 4.2, 6.0, 9.0, 8.6, 9.0, 5.0)
dataSet <- list(X1 = potatoA, X2 = potatoB, N1 = length(potatoA), N2 = length(potatoB))

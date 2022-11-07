# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 4. Alternatives for t-test. Cmdstanr Version

rm(list = ls())
library(tidyverse)
library(cmdstanr)
library(bayesplot)
## MAP関数
map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}
# データなど -------------------------------------------------------------------

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)

## t検定

t.test(groupA, groupB, var.equal = TRUE)


# Modeling ----------------------------------------------------------------

modelC <- cmdstanr::cmdstan_model("ttest01.stan")
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
sampling2$draws() %>%
    mcmc_areas(
        pars = c("mu1", "mu2"),
        prob = 0.5, # 50% intervals
        prob_outer = 0.95, # 99%
        point_est = "mean"
    )

# Welchの補正 ----------------------------------------------------------------

t.test(groupA, groupB, var.equal = FALSE)


# 微妙な差のデータ ----------------------------------------------------------------


groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(30, 45, 60, 40, 60, 50, 40, 30)

## t検定

t.test(groupA, groupB, var.equal = FALSE)


## 同じモデルでこのデータで再推定
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)

sampling2 <- modelC$sample(
    data = dataSet,
    chains = 4,
    iter_sampling = 5000,
    iter_warmup = 1000,
    parallel_chains = 4
)

## サンプリングから計算

sampling2$draws() %>% 
    posterior::as_draws_df() %>%
    as_tibble() %>% dplyr::select(-lp__,-.chain,-.iteration) %>% 
    mutate(diff = mu1 - mu2) %>% 
    mutate(FLG = if_else(diff>1,1,0)) %>% 
    summary()

# Generated quantities ----------------------------------------------------

modelC <- cmdstanr::cmdstan_model("ttest03.stan")

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(30, 45, 60, 40, 60, 50, 40, 30)

## 生成量を計算するモデルを実行
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)

sampling2 <- modelC$sample(
    data = dataSet,
    chains = 4,
    iter_sampling = 5000,
    iter_warmup = 1000,
    parallel_chains = 4
)

sampling2


# 課題 ----------------------------------------------------------------------
potatoA <- c(8.4,11.3,8.1,11.2,5.8,6.3,7.1,10.9,7.1,6.5,5.0,3.0,7.2,6.5,6.4,6.4,9.3,8.3)
potatoB <- c(6.7,7.2,4.2,11.0,7.5,8.9,7.0,8.0,7.2,4.2,6.0,9.0,8.6,9.0,5.0)


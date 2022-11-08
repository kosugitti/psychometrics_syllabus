# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 3. Seven scientist Cmdstanr Version

# 準備 ----------------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(bayesplot)

# データ ---------------------------------------------------------------------

x <- c(-27.020, 3.570, 8.191, 9.898, 9.603, 9.945, 10.056)

# stanのコンパイル
## cmdstanの場合
library(cmdstanr)
model <- cmdstanr::cmdstan_model("cmdstan/sevenScientist.stan")
fit <- model$sample(
  data = list(Y = x),
)


# トレースプロット ----------------------------------------------------------------

fit$draws() %>% bayesplot::mcmc_trace()

# Stanのオプション指定 ------------------------------------------------------------

fit <- model$sample(
  data = list(Y = x),
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 4000
)


# MCMCサンプルをデータフレームにする -----------------------------------------------------

fit$draws() %>%
  posterior::as_draws_df() %>%
  tibble::as_tibble() %>%
  dplyr::select(-lp__, -.draw, -.chain, -.iteration) %>%
  tibble::rowid_to_column("iter") %>%
  tidyr::pivot_longer(-iter) -> MCMCsample

# MAP関数を作る ----------------------------------------------------------------

map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}


# 要約統計量を表示 ----------------------------------------------------------------

MCMCsample %>%
  dplyr::group_by(name) %>%
  dplyr::summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    U95 = quantile(value, prob = 0.975),
    L95 = quantile(value, prob = 0.025)
  )

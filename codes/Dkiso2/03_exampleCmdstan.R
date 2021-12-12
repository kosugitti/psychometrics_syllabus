# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 3. Seven scientist Cmdstanr Version

rm(list = ls())
library(tidyverse)
library(bayesplot)
# データ
x <- c(-27.020, 3.570, 8.191, 9.898, 9.603, 9.945, 10.056)

# stanのコンパイル

## cmdstanの場合
library(cmdstanr)
model <- cmdstan_model("sevenScientist.stan")
fit1cmdstan <- model$sample(
  data = list(Y = x),
)
fit1cmdstan
sample_cmdstan <- fit1cmdstan$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble()


# MCMCの結果の確認
g1 <- fit1cmdstan$draws("mu") %>% bayesplot::mcmc_trace()
plot(g1)

# Stanのオプション指定
model <- cmdstan_model("sevenScientist.stan")
fit1cmdstan <- model$sample(
  data = list(Y = x),
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 4000
)


## 結果の解釈
map_estimation <- function(z) {
    density(z)$x[which.max(density(z)$y)]
}

sample_cmdstan %>% 
    dplyr::select(-lp__,-.chain,-.iteration) %>% 
    pivot_longer(-.draw) %>% 
    group_by(name) %>% 
    summarise(
        EAP = mean(value),
        MED = median(value),
        MAP = map_estimation(value),
        U95 = quantile(value,prob=0.975),
        L95 = quantile(value,prob=0.025)
    )

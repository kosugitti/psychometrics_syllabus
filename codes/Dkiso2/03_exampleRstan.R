# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 3. Seven scientist Rstan Version

rm(list = ls())
library(tidyverse)
library(bayesplot)
# データ
x <- c(-27.020, 3.570, 8.191, 9.898, 9.603, 9.945, 10.056)

# stanのコンパイル
## rstanの場合
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
model <- stan_model("sevenScientist.stan")
fit1rstan <- sampling(model, data = list(Y = x))
sample_rstan <- fit1rstan %>%
  rstan::extract() %>%
  as.data.frame() %>%
  as_tibble()

# MCMCの結果の確認
## rstanの場合
traceplot(fit1rstan)

# Stanのオプション指定
model <- stan_model("sevenScientist.stan")
fit1rstan <- sampling(model,
  data = list(Y = x),
  chains = 4, iter = 5000, warmup = 1000
)

## 結果の解釈
map_estimation <- function(z) {
    density(z)$x[which.max(density(z)$y)]
}


sample_rstan %>% 
    rowid_to_column("iter") %>%
    dplyr::select(-lp__) %>% 
    pivot_longer(-iter) %>% 
    group_by(name) %>% 
    summarise(
        EAP = mean(value),
        MED = median(value),
        MAP = map_estimation(value),
        U95 = quantile(value,prob=0.975),
        L95 = quantile(value,prob=0.025)
    )


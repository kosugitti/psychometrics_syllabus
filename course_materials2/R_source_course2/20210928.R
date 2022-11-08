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
## rstanの場合
traceplot(fit1rstan, pars = "mu")
## cmdstanrの場合
g1 <- fit1cmdstan$draws("mu") %>% bayesplot::mcmc_trace()
plot(g1)
# ggsave(g1,filename = "../images/chapter18/Rplot18_01.png", dpi = 600, width = 8, height = 4)


# Stanのオプション指定
model <- stan_model("sevenScientist.stan")
fit1rstan <- sampling(model,
  data = list(Y = x),
  chains = 4, iter = 5000, warmup = 1000
)

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


sample_rstan %>%
  rowid_to_column("iter") %>%
  dplyr::select(-lp__) %>%
  pivot_longer(-iter) %>%
  group_by(name) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    U95 = quantile(value, prob = 0.975),
    L95 = quantile(value, prob = 0.025)
  )

sample_cmdstan %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  pivot_longer(-.draw) %>%
  group_by(name) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    U95 = quantile(value, prob = 0.975),
    L95 = quantile(value, prob = 0.025)
  ) %>%
  knitr::kable(format = "latex", digits = 3)

rm(list = ls())
library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# rstanの場合
model <- rstan::stan_model("categorical1.stan")
fit <- sampling(model,
  data = list(K = 3, X = c(51, 45, 27))
)


fit

# Kappa係数
model2 <- rstan::stan_model("kappa.stan")
dataSet <- list(Y=c(55,16,14,35))
fit2 <- sampling(model2, data = dataSet)
fit2

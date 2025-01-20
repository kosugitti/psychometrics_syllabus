rm(list = ls())
library(tidyverse)
library(bayesplot)
library(gridExtra)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(cmdstanr)
# cmdstanr::set_cmdstan_path("/home/rstudio/.cmdstanr/cmdstan-2.26.1")
cmdstanr::set_cmdstan_path("/Users/Napier/.cmdstanr/cmdstan-2.28.0")

# コンパイルなど
modelC <- cmdstanr::cmdstan_model("BetweenAnova.stan")
Example <- matrix(c(6, 6, 5, 5, 7, 4, 7, 6, 4, 3, 4, 6), ncol = 4, byrow = T)
dataSet <- list(Lv = 3, N = 4, X = Example)

sampling <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)

sampling

model <- rstan::stan_model("BetweenAnova.stan")
sampling <- rstan::sampling(model, data = dataSet)
sampling

# リバース・リバースエンジニアリング -------------------------------------------------------

N <- 100
Lv <- 5
gm <- 50
sig <- 3

raw_effect <- runif(Lv - 1, -10, 10)
effect <- c(raw_effect, 0 - sum(raw_effect))
mu <- gm + effect

X <- rnorm(N * Lv, mu, sig)
dat <- data.frame(
  Idx = rep(1:Lv, N * Lv),
  value = X
)

modelC <- cmdstanr::cmdstan_model("BetweenAnova2.stan")
dataSet <- list(Lv = Lv, L = NROW(dat), idx = dat$Idx, X = dat$value)
sampling <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)

sampling

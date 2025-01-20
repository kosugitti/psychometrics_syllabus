
rm(list = ls())
library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(bayesplot)
library(MASS)
library(cmdstanr)
library(bayesplot)

## MAP関数
map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}
## MCMCサンプルをデータフレームにする関数
MCMCtoDFrs <- function(fit) {
  fit %>%
    rstan::extract() %>%
    as.data.frame() %>%
    tibble::as_tibble() %>%
    tibble::rowid_to_column("iter") %>%
    dplyr::select(-lp__) %>%
    tidyr::pivot_longer(-iter) -> MCMCsample
  return(MCMCsample)
}

## MCMCサンプルをデータフレームにする関数
MCMCtoDFcs <- function(fit) {
  fit$draws() %>%
    posterior::as_draws_df() %>%
    tibble::as_tibble() %>%
    dplyr::select(-lp__, -.draw, -.chain, -.iteration) %>%
    tibble::rowid_to_column("iter") %>%
    tidyr::pivot_longer(-iter) -> MCMCsample
  return(MCMCsample)
}
## MCMCデータフレームを要約する関数
MCMCsummary <- function(MCMCsample) {
  MCMCsample %>%
    dplyr::group_by(name) %>%
    dplyr::summarise(
      EAP = mean(value),
      MED = median(value),
      MAP = map_estimation(value),
      U95 = quantile(value, prob = 0.975),
      L95 = quantile(value, prob = 0.025)
    )
}

# データなど -------------------------------------------------------------------

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)

# Modeling ----------------------------------------------------------------
modelR <- rstan::stan_model("rstan/ttest01.stan")

fitR <- rstan::sampling(modelR,
  data = dataSet,
  chains = 4,
  iter = 6000,
  warmup = 1000
)


modelC <- cmdstanr::cmdstan_model("cmdstan/ttest01.stan")
fitC <- modelC$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 5000
)



### cmdstanの出力をstanfitオブジェクトにする
fitR2 <- fitC$output_files() |> rstan::read_stan_csv()

fitC$draws(c("mu1", "mu2")) %>%
  posterior::as_draws_df() %>%
  bayestestR::describe_posterior()


fitR %>% bayestestR::describe_posterior()
fitC$draws() %>% bayestestR::describe_posterior()
fitR %>% bayestestR::hdi()
fitR %>% bayestestR::map_estimate()
fitR %>%
  MCMCtoDFrs() %>%
  MCMCsummary()
?map_estimate()

fitC %>%
  MCMCtoDFcs() %>%
  MCMCsummary()

rm(list = ls())
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(cmdstanr)
cmdstanr::set_cmdstan_path("/home/rstudio/.cmdstanr/cmdstan-2.26.1")

# データなど -------------------------------------------------------------------

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)

## t検定

t.test(groupA, groupB, var.equal = TRUE)


# Modeling ----------------------------------------------------------------

modelR <- rstan::stan_model("ttest01.stan")
modelC <- cmdstanr::cmdstan_model("ttest01.stan")

dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)

sampling1 <- sampling(modelR,
  data = dataSet,
  chains = 4,
  iter = 5000,
  warmup = 1000
)
sampling2 <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling2
sampling1

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


sampling2$draws() %>%
  mcmc_areas(
    pars = c("mu1", "mu2"),
    prob = 0.8, # 80% intervals
    prob_outer = 0.99, # 99%
    point_est = "mean"
  ) -> g


sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  mutate(diff = mu1 - mu2) %>%
  ggplot(aes(x = diff)) +
  geom_density() +
  geom_vline(xintercept = 0, color = "red") +
  geom_vline(xintercept = 5, lty = 2) +
  geom_vline(xintercept = -5, lty = 2)

sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  mutate(diff = mu1 - mu2) %>%
  mutate(FLG = if_else(abs(diff) < 5, 1, 2)) %>%
  ggplot(aes(x = diff, fill = as.factor(FLG))) +
  geom_histogram(binwidth = 0.1)


## ROPE

sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  mutate(diff = mu1 - mu2) %>%
  mutate(FLG = if_else(abs(diff) > 5, 1, 0)) %>%
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


modelR <- rstan::stan_model("ttest03.stan")
sampling1 <- sampling(modelR,
  data = dataSet,
  chains = 4,
  iter = 5000,
  warmup = 1000
)
sampling1


# 課題 ----------------------------------------------------------------------
potatoA <- c(8.4, 11.3, 8.1, 11.2, 5.8, 6.3, 7.1, 10.9, 7.1, 6.5, 5.0, 3.0, 7.2, 6.5, 6.4, 6.4, 9.3, 8.3)
potatoB <- c(6.7, 7.2, 4.2, 11.0, 7.5, 8.9, 7.0, 8.0, 7.2, 4.2, 6.0, 9.0, 8.6, 9.0, 5.0)

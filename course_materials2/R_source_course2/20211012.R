rm(list = ls())
library(tidyverse)
library(bayesplot)
library(gridExtra)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(cmdstanr)
cmdstanr::set_cmdstan_path("/home/rstudio/.cmdstanr/cmdstan-2.28.0")
# cmdstanr::set_cmdstan_path("/Users/Napier/.cmdstanr/cmdstan-2.28.0")
# データなど -------------------------------------------------------------------

groupA <- c(30, 50, 70, 90, 60, 50, 70, 60)
groupB <- c(20, 40, 60, 40, 40, 50, 40, 30)



# Modeling ----------------------------------------------------------------

modelR <- rstan::stan_model("ttest05.stan")
modelC <- cmdstanr::cmdstan_model("ttest05.stan")

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

g1 <- sampling2$draws() %>%
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

plot(g1)

g2 <- groupA %>%
  as.data.frame() %>%
  ggplot(aes(x = .)) +
  geom_histogram(binwidth = 6)

ggsave(g1, filename = "../images/chapter20/Rplot20_01.png", dpi = 600, width = 8, height = 4)

pred <- sampling2$draws() %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  dplyr::select(-lp__, -.chain, -.iteration) %>%
  pivot_longer(-.draw) %>%
  dplyr::filter(str_detect(name, pattern = "Xpred1")) %>%
  pivot_wider(names_from = name, values_from = value, id_cols = .draw) %>%
  dplyr::select(-.draw) %>%
  as.matrix()

bayesplot::ppc_hist(y = groupA, yrep = pred[sample(nrow(pred), 15), ]) %>%
  ggsave(filename = "../images/chapter20/Rplot20_02.png", dpi = 600, width = 8, height = 4)


# 優越率・閾上率 ----------------------------------------------------------------

modelC <- cmdstanr::cmdstan_model("ttest06.stan")
dataSet <- list(X1 = groupA, X2 = groupB, N1 = 8, N2 = 8)




# 課題 ----------------------------------------------------------------------
potatoA <- c(8.4, 11.3, 8.1, 11.2, 5.8, 6.3, 7.1, 10.9, 7.1, 6.5, 5.0, 3.0, 7.2, 6.5, 6.4, 6.4, 9.3, 8.3)
potatoB <- c(6.7, 7.2, 4.2, 11.0, 7.5, 8.9, 7.0, 8.0, 7.2, 4.2, 6.0, 9.0, 8.6, 9.0, 5.0)

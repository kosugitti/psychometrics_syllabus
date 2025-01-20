rm(list = ls())
source("utilities.R")
library(tidyverse)
library(bayestestR)

model1 <- cmdstan_model("modelComp.stan")
N <- 9
head <- 6
tail <- N - head
dataSet <- list(N = N, Y = c(rep(1, head), rep(0, tail)), omega = c(0.25, 0.75), kappa = c(12, 12))
fit1 <- model1$sample(data = dataSet, iter_sampling = 100000)
fit1$summary()
fit1$draws(c("theta1", "theta2")) %>%
  posterior::as_draws_df() %>%
  describe_posterior()
fit1$draws("m") %>%
  posterior::as_draws_df() %>%
  as_tibble() %>%
  mutate(m = as.factor(m)) %>%
  summary()
#  ggplot(aes(x=m))+geom_bar(stat="count")

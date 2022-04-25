rm(list = ls())
library(tidyverse)
library(bayesplot)
library(cmdstanr)

wrongModel <-cmdstan_model("wrong.stan")
fit <- wrongModel$sample()
g <- fit$draws("a") %>% bayesplot::mcmc_trace()
ggsave(g,filename = "../images/chapter18/Rplot18_02.png", dpi = 600, width = 8, height = 4)

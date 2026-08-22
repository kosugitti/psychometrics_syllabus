rm(list = ls())
pacman::p_load(tidyverse, brms, cmdstanr, bayesplot, posterior, ragg)

options(brms.backend = "cmdstanr")
SEED <- 12345
# データの準備 -----
dat <- readr::read_csv("BaseballDecade.csv") %>%
  dplyr::filter(Year == "2020年度") %>%
  dplyr::filter(!is.na(weight)) %>%
  dplyr::mutate(group = ifelse(position == "投手", "投手", "野手")) %>%
  dplyr::select(group, weight)

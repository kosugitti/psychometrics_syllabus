rm(list = ls())
library(tidyverse)
library(cmdstanr)
source("utilities.R")
set_cmdstan_path("/Users/Napier/.cmdstanr/cmdstan-2.28.2")
dat <- read_csv("baseballDecade.csv")
dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  mutate(salary.log = log(salary)) %>%
  ggplot(aes(x = team, y = salary.log)) +
  geom_violin()

g <- dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  ggplot(aes(x = salary.log, y = ..density..)) +
  geom_histogram(position = "identity", alpha = 0.8, binwidth = 0.35) +
  geom_density(aes(color = team), show.legend = F)
ggsave(g, filename = "../images/chapter26/Rplot26_01.png", dpi = 600, width = 16, height = 9)
g



# hclust ------------------------------------------------------------------

library(dendextend)
g <- dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  dplyr::select(salary.log) %>%
  dist() %>%
  hclust(method = "ward.D2") %>%
  as.dendrogram() %>%
  set("branches_k_color", k = 2) %>%
  as.ggdend()

g <- ggplot() +
  geom_segment(
    data = g$segments,
    aes(x = x, y = y, xend = xend, yend = yend, col = col), lwd = 1
  ) +
  theme(legend.position = "none")
ggsave(g, filename = "../images/chapter26/Rplot26_02.png", dpi = 600, width = 16, height = 9)
g

dat.tmp <- dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  dplyr::select(salary.log, Name) %>%
  rowid_to_column("ID")

dataSet <- list(K = 2, L = NROW(dat.tmp), Y = dat.tmp$salary.log)
model <- cmdstanr::cmdstan_model("latent.stan")
fit <- model$sample(data = dataSet, chains = 4, parallel_chains = 4)
fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
fit.df <- fit.stanfit %>% MCMC_result()

fit.df %>%
  dplyr::select(Varname, MAP) %>%
  dplyr::filter(str_detect(Varname, pattern = c("mu|sigma")))

dat.tmp %>%
  ggplot(aes(x = salary.log)) +
  geom_density() +
  stat_function(fun = dnorm, args = list(mean = 7.59, sd = 0.656), color = 2) +
  stat_function(fun = dnorm, args = list(mean = 10.0, sd = 0.920), color = 3)

g <- fit.df %>%
  dplyr::select(Varname, MAP, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = c("pred_class"))) %>%
  mutate(Class = round(EAP) %>% factor(labels=c("一般","超一流"))) %>%
  mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  left_join(dat.tmp, by = "ID") %>%
  print() %>%
  ggplot(aes(x = exp(salary.log), fill = Class)) +
  geom_histogram(binwidth = 700)
ggsave(g, filename = "../images/chapter26/Rplot26_06.png", dpi = 600, width = 16, height = 9)
g


# zero-inflated poisson ---------------------------------------------------

g <- dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  ggplot(aes(x = Save)) +
  geom_histogram()
ggsave(g, filename = "../images/chapter26/Rplot26_03.png", dpi = 600, width = 16, height = 9)
g

data.frame(Seed = 0:20) %>% # 種子数を0から20と仮定する
  mutate(
    Lambda1 = dpois(Seed, lambda = 1.5), # それぞれのλのポワソン分布を発生させる
    Lambda2 = dpois(Seed, lambda = 3),
    Lambda4 = dpois(Seed, lambda = 4.5),
    Lambda10 = dpois(Seed, lambda = 10.5)
  ) %>%
  gather(Lambda, Probability, -Seed) -> pois.dat

g <- ggplot(pois.dat, aes(x = Seed, y = Probability)) +
  geom_line(aes(color = Lambda)) +
  geom_point()+theme(legend.position = "none")
ggsave(g, filename = "../images/chapter26/Rplot26_04.png", dpi = 600, width = 16, height = 9)
g


dat.tmp <- dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  dplyr::select(Save)

model <- cmdstan_model("ziPoisson.stan")
dataSet <- list(L = NROW(dat.tmp), Y = dat.tmp$Save)
fit <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4
)

fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
fit.df <- fit.stanfit %>% MCMC_result()

## 事後予測分布的に作ってみる
theta <- 0.61
lambda <- 14.67
N <- Nrow(dat.tmp)
g1 <- data.frame(FLG= rbinom(N,size=1, prob = theta) ) %>% 
  rowwise() %>% 
  mutate(Save = if_else(FLG==1,rpois(1,lambda),rpois(1,0))) %>% 
  ggplot(aes(x=Save))+geom_histogram(binwidth=1)
g2 <- dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  ggplot(aes(x = Save)) +
  geom_histogram(binwidth=1)
library(patchwork)
g <- g2/g1
ggsave(g, filename = "../images/chapter26/Rplot26_05.png", dpi = 600, width = 16, height = 9)
g

dat.tmp <- dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  dplyr::select(Save, salary) %>%
  dplyr::mutate(salary = salary / 1000)

model <- cmdstan_model("ziPoisson2.stan")
dataSet <- list(L = NROW(dat.tmp), Y = dat.tmp$Save, X = dat.tmp$salary)
fit <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4
)

fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
fit.df <- fit.stanfit %>% MCMC_result()

rm(list = ls())
library(tidyverse)
library(MASS)
library(mvtnorm)

mu <- c(0, 0)
rho <- 0.5
sds <- c(1, 1)
SIG <- diag(sds) %*% matrix(c(1, rho, rho, 1), ncol = 2) %*% diag(sds)
X <- mvrnorm(200, mu, SIG) %>%
  transform() %>%
  as_tibble() %>%
  mutate(z = purrr::map2_dbl(X1, X2, .f = ~ dmvnorm(c(.x, .y), mean = mu, sigma = SIG)))

data.grid <- expand.grid(s.1 = seq(-3, 3, length.out = 200), s.2 = seq(-3, 3, length.out = 200))
q.samp <- cbind(data.grid, prob = mvtnorm::dmvnorm(data.grid, mean = mu, sigma = SIG))
g1 <- ggplot(q.samp, aes(x = s.1, y = s.2)) +
  geom_contour(aes(z = prob)) +
  geom_point(data = X, aes(x = X1, y = X2)) +
  xlab("X1") +
  ylab("X2") +
  coord_fixed(xlim = c(-3, 3), ylim = c(-3, 3), ratio = 1)

ggsave(g1, filename = "../images/chapter22/Rplot22_01.png", dpi = 600, width = 8, height = 8)


g2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm)
ggsave(g2, filename = "../images/chapter22/Rplot22_02.png", dpi = 600, width = 8, height = 2)


# 多次元正規分布 -----------------------------------------------------------------
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(cmdstanr)
# cmdstanr::set_cmdstan_path("/home/rstudio/.cmdstanr/cmdstan-2.26.1")
cmdstanr::set_cmdstan_path("/Users/Napier/.cmdstanr/cmdstan-2.28.1")

modelC <- cmdstanr::cmdstan_model("paired_t.stan")

mu <- c(50, 50)
sd1 <- 10
sd2 <- 5
rho <- 0.7
SIG <- matrix(ncol = 2, nrow = 2)
SIG[1, 1] <- sd1 * sd1
SIG[2, 2] <- sd2 * sd2
SIG[1, 2] <- sd1 * sd2 * rho
SIG[2, 1] <- sd1 * sd2 * rho
N <- 100
X <- mvrnorm(N, mu, SIG)

dataSet <- list(N = N, X = X)

sampling <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling

X <- mvrnorm(N, mu, SIG)
tidy_data <- X %>%
  as.data.frame() %>%
  rename(pre = V1, post = V2) %>%
  as_tibble() %>%
  rowid_to_column("ID") %>%
  pivot_longer(-ID) %>%
  mutate(cond = if_else(name == "pre", 1, 2))

dataSet <- list(
  L = NROW(tidy_data),
  N = max(tidy_data$ID),
  IDindex = tidy_data$ID,
  Condition = tidy_data$cond,
  val = tidy_data$value
)
modelC <- cmdstanr::cmdstan_model("paired_t_tidy.stan")
sampling <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling


dat_raw <- data.frame(
  ID = 1:4,
  period1 = c(10, 9, 4, 7),
  period2 = c(5, 4, 2, 3),
  period3 = c(9, 5, 3, 5)
)

tidy_dat <- dat_raw %>%
  pivot_longer(-ID) %>%
  mutate(name = as.factor(name) %>% fct_relevel("period1", "period2")) %>%
  mutate(cond = as.numeric(name))

modelC <- cmdstanr::cmdstan_model("Within.stan")
dataSet <- list(
  L = NROW(tidy_dat),
  N = max(tidy_dat$ID),
  Lv = max(tidy_dat$cond),
  id = tidy_dat$ID,
  cond = tidy_dat$cond,
  val = tidy_dat$value
)
sampling <- modelC$sample(
  data = dataSet,
  chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000,
  parallel_chains = 4
)
sampling

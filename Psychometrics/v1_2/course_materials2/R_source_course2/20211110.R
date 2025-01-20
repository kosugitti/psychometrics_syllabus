rm(list = ls())
library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
library(cmdstanr)
library(posterior)
library(bayesplot)
library(colorBlindness)
color_scheme_set("brightblue")
set_cmdstan_path("/Users/gauss/.cmdstanr/cmdstan-2.28.1")


# LM ----------------------------------------------------------------------


dat <- read_csv("baseball2020.csv")
dataSet <- list(N = NROW(dat), Y = dat$height, X = dat$weight)
g <- dat %>% ggplot(aes(x = weight, y = height)) +
  geom_point() +
  geom_smooth(formula = "y~x", method = "lm", se = FALSE)
ggsave(g, filename = "../images/chapter24/Rplot24_01.png", dpi = 600, width = 8, height = 4)
g

resultlm <- lm(height ~ weight, dat)

lmFit <- data.frame(resultlm$fitted.values, dat$weight)

g + stat_function(fun = dnorm, args = list(mean = lmFit[1, 1], sd = 3), colour = "red") +
  coord_flip()



modelC <- cmdstan_model("LM.stan")
fit <- modelC$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)

## 簡易表示
fit$print(c("beta0", "beta1", "sig"))
## MLと比較
fitML <- lm(height ~ weight, data = dat)
summary(fitML)

fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
#
# modelR <- rstan::stan_model("LM.stan")
# fit.rstan <- sampling(modelR,
#   data = dataSet,
#   iter = 3000, warmup = 1000
# )

predY <- rstan::extract(fit.stanfit)$predY
# 事後予測分布の描画
bayesplot::ppc_dens_overlay(y = dataSet$Y, yrep = predY[1:10, ])
g <- bayesplot::ppc_intervals(
  y = dataSet$Y,
  yrep = predY,
  x = dataSet$X,
  prob = 0.5,
  prob_outer = 0.95
)
ggsave(g, filename = "../images/chapter24/Rplot24_02.png", dpi = 600, width = 8, height = 4)
g


# ロジスティック回帰 ---------------------------------------------------------------

dat2 <- dat %>%
  mutate(Pitcher = if_else(position == "投手", 0, 1)) %>%
  filter(salary > 5000) %>%
  select(Games, Pitcher) %>%
  na.omit()
dat2 %>%
  ggplot(aes(x = Games, y = Pitcher)) +
  geom_point() +
  geom_smooth(
    method = "glm", se = FALSE,
    method.args = list(family = binomial(link = "logit"))
  )

g <- dat2 %>%
  ggplot(aes(x = Games, y = Pitcher)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
ggsave(g, filename = "../images/chapter24/Rplot24_03.png", dpi = 600, width = 8, height = 4)
g

g <- ggplot(data = data.frame(X = c(-10, 10)), aes(x = X)) +
  stat_function(fun = psych::logistic) +
  geom_hline(yintercept = 0, lty = 2) +
  geom_hline(yintercept = 1, lty = 2)

ggsave(g, filename = "../images/chapter24/Rplot24_04.png", dpi = 600, width = 8, height = 4)
g

model2 <- cmdstanr::cmdstan_model("logistic.stan")
dataSet <- list(N = NROW(dat2), Y = dat2$Pitcher, X = dat2$Games)

fit.logistic <- model2$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)

## 簡易表示
fit.logistic$print(c("beta0", "beta1"))

logit_model <- rstan::stan_model("logistic.stan")
rstan.fit <- rstan::sampling(logit_model,
  data = dataSet,
  iter = 2500,
  warmup = 500
)

print(rstan.fit, pars = c("beta0", "beta1"))

## プロットを考える
### 関数準備
plotFunc <- function(x, b0, b1) {
  tmp <- b0 + b1 * x
  ret <- 1 / (1 + exp(-tmp))
  return(ret)
}
map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}

result <- rstan.fit %>%
  rstan::extract() %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter) %>%
  group_by(name) %>%
  summarise(
    EAP = mean(value),
    MAP = map_estimation(value),
    L50 = quantile(value, probs = 0.25),
    U50 = quantile(value, probs = 0.75),
    L95 = quantile(value, probs = 0.025),
    U95 = quantile(value, probs = 0.975)
  ) %>%
  filter(str_detect(name, pattern = "beta"))

g <- dat2 %>%
  ggplot(aes(x = Games, y = Pitcher)) +
  geom_point() +
  stat_function(
    fun = plotFunc,
    args = list(b0 = result[1, ]$MAP, b1 = result[2, ]$MAP),
    color = palette()[4], lwd = 1.5
  ) +
  stat_function(
    fun = plotFunc,
    args = list(b0 = result[1, ]$U50, b1 = result[2, ]$U50),
    color = palette()[4], lty = 2, alpha = 0.7
  ) +
  stat_function(
    fun = plotFunc,
    args = list(b0 = result[1, ]$L50, b1 = result[2, ]$L50),
    color = palette()[4], lty = 2, alpha = 0.7
  ) +
  stat_function(
    fun = plotFunc,
    args = list(b0 = result[1, ]$U95, b1 = result[2, ]$U95),
    color = palette()[4], lty = 2, alpha = 0.5
  ) +
  stat_function(
    fun = plotFunc,
    args = list(b0 = result[1, ]$L95, b1 = result[2, ]$L95), color = palette()[4], lty = 2, alpha = 0.5
  )

ggsave(g, filename = "../images/chapter24/Rplot24_05.png", dpi = 600, width = 8, height = 4)
g




# 課題 ----------------------------------------------------------------------

dat3 <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(AtBats, Hit, salary) %>%
  na.omit() %>%
  dplyr::mutate(salary.z = (salary - mean(salary)) / sd(salary)) %>%
  dplyr::select(-salary)

dataSet <- list(N = NROW(dat3), AB = dat3$AtBats, Hit = dat3$Hit, X = dat3$salary.z)
model <- cmdstan_model("binomial.stan")

fit <- model$sample(
  data = dataSet
)
# library(brms)
# fit.brm <- brm(Y ~ X, data = dataSet, family = "bernoulli")
# brms::conditional_effects(fit.brm)

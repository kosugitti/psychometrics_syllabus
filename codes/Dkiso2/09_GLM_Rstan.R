rm(list = ls())
library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# LM ----------------------------------------------------------------------

dat <- read_csv("baseball2020.csv")
dataSet <- list(N = NROW(dat), Y = dat$height, X = dat$weight)
dat %>% ggplot(aes(x = weight, y = height)) +
  geom_point() +
  geom_smooth(formula = "y~x", method = "lm", se = FALSE)

model <- rstan::stan_model("LM.stan")
fit.stanfit <- sampling(model,
  data = dataSet,
  iter = 3000,
  warmup = 2000
)


## 簡易表示
print(fit.stanfit, pars = c("beta0", "beta1", "sig"))
## MLと比較
fitML <- lm(height ~ weight, data = dat)
summary(fitML)

predY <- rstan::extract(fit.stanfit)$predY
# 事後予測分布の描画
bayesplot::ppc_dens_overlay(y = dataSet$Y, yrep = predY[1:10, ])
bayesplot::ppc_intervals(
  y = dataSet$Y,
  yrep = predY,
  x = dataSet$X,
  prob = 0.5,
  prob_outer = 0.95
)

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

model2 <- rstan::stan_model("logistic.stan")
dataSet <- list(N = NROW(dat2), Y = dat2$Pitcher, X = dat2$Games)

fit.logistic <- sampling(model2,
  data = dataSet,
  chains = 4,
  warmup = 1000,
  iter = 3000
)

## 簡易表示
print(fit.logistic, pars = c("beta0", "beta1"))

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

result <- fit.logistic %>%
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

dat2 %>%
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



# 課題 ----------------------------------------------------------------------

dat3 <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(AtBats, Hit, salary) %>%
  na.omit() %>%
  dplyr::mutate(salary.z = (salary - mean(salary)) / sd(salary)) %>%
  dplyr::select(-salary)

dataSet <- list(N = NROW(dat3), AB = dat3$AtBats, Hit = dat3$Hit, X = dat3$salary.z)

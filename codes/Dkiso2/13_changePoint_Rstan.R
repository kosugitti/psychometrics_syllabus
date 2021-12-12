# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 13. Change Point models Rstan version.


rm(list = ls())
library(tidyverse)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
# map推定値 ------------------------------------------------------------------

map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}

# data plot ---------------------------------------------------------------

dat <- read_csv("weight.csv")
g <- dat %>%
  mutate(date = as.Date(date)) %>%
  # dplyr::filter(date > "2019/01/01") %>%
  # dplyr::filter(date < "2022/01/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point() +
  scale_x_date(date_breaks = "6 month")
g


# 二種類混ぜる ------------------------------------------------------------------

dat1 <- dat %>%
  dplyr::filter(date > "2019/01/01") %>%
  dplyr::filter(date < "2021/01/01")

g <- dat1 %>%
  mutate(date = as.Date(date)) %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point() +
  scale_x_date(date_breaks = "2 month")
g


model <- rstan::stan_model("changePoint1.stan")
dataSet <- list(L = NROW(dat1), W = dat1$weight)
fit <- sampling(model,
  data = dataSet,
  chains = 4,
  seed = 12345
)

## 結果の加工
fit.df <- fit %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter, names_to = "Varname") %>%
  group_by(Varname) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    SD = sd(value),
    L95 = quantile(value, probs = 0.025),
    L50 = quantile(value, probs = 0.25),
    U50 = quantile(value, probs = 0.75),
    U95 = quantile(value, probs = 0.975)
  ) %>%
  print()

## 時系列チェック
timeCheck <- fit.df %>%
  dplyr::filter(str_detect(Varname, pattern = "theta")) %>%
  mutate(time = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(time) %>%
  dplyr::select(time, MAP) %>%
  dplyr::mutate(FLG = if_else(MAP > .5, 1, 0))
## プロット
g <- dat1 %>%
  bind_cols(timeCheck) %>%
  mutate(date = as.Date(date)) %>%
  ggplot(aes(x = date, y = weight, color = as.factor(FLG))) +
  geom_point() +
  scale_x_date(date_breaks = "2 month") +
  geom_hline(yintercept = 81.2, color = 1) +
  geom_hline(yintercept = 83.1, color = 2) +
  theme(legend.position = "none")
g


# 変化点検出 -------------------------------------------------------------------
## データプロット
g <- dat %>%
  mutate(date = as.Date(date)) %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point() +
  scale_x_date(date_breaks = "2 month")
g

## データ選別
dat2 <- dat %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01")

model2 <- rstan::stan_model("changePoint2.stan")
dataSet <- list(L = NROW(dat2), W = dat2$weight)
fit2 <- sampling(model2,
  data = dataSet,
  chains = 4,
  seed = 12345
)

## 結果の加工
fit2.df <- fit2 %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter, names_to = "Varname") %>%
  group_by(Varname) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    SD = sd(value),
    L95 = quantile(value, probs = 0.025),
    L50 = quantile(value, probs = 0.25),
    U50 = quantile(value, probs = 0.75),
    U95 = quantile(value, probs = 0.975)
  ) %>%
  print()

## 変化点検出
Est <- fit2.df %>%
  dplyr::select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(lp = 1, mu1 = 2, mu2 = 3, sigma = 4, tau = 5)
## いつでしょう
dat2[145, ]
## プロット
g <- dat %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01") %>%
  rowid_to_column("Date") %>%
  ggplot(aes(x = Date, y = weight)) +
  geom_point() +
  geom_segment(x = 1, xend = Est$tau, y = Est$mu2, yend = Est$mu2, color = 2) +
  geom_segment(x = Est$tau, xend = dataSet$L, y = Est$mu1, yend = Est$mu1, color = 2) +
  geom_vline(xintercept = Est$tau, color = 3, lwd = 2)
g

# 折線回帰 --------------------------------------------------------------------
## データプロット
g <- dat %>%
  mutate(date = as.Date(date)) %>%
  dplyr::filter(date > "2016/01/01") %>%
  dplyr::filter(date < "2016/12/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point() +
  scale_x_date(date_breaks = "2 month")
g
## データ選別
dat3 <- dat %>%
  dplyr::filter(date > "2016/01/01") %>%
  dplyr::filter(date < "2016/12/10") %>%
  rowid_to_column("cDate")


model3 <- rstan::stan_model("changePoint3.stan")
dataSet <- list(L = NROW(dat3), X = dat3$cDate, W = dat3$weight)
fit3 <- rstan::sampling(
  model3,
  data = dataSet,
  chains = 4,
  seed = 8931
)

## 結果の加工
fit3.df <- fit3 %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter, names_to = "Varname") %>%
  group_by(Varname) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    SD = sd(value),
    L95 = quantile(value, probs = 0.025),
    L50 = quantile(value, probs = 0.25),
    U50 = quantile(value, probs = 0.75),
    U95 = quantile(value, probs = 0.975)
  ) %>%
  print()



## 変化点はいつ？
Est2 <- fit3.df %>%
  select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(beta0a = 1, beta0b = 2)

## プロット
g <- ggplot() +
  geom_point(data = dat3, aes(x = cDate, y = weight)) +
  stat_function(fun = function(x) Est2$beta0a + Est2$beta1a * x, aes(color = palette()[2]), lty = 2, lwd = 2) +
  stat_function(fun = function(x) Est2$beta0b + Est2$beta1b * x, aes(color = palette()[2]), lty = 2, lwd = 2) +
  geom_vline(xintercept = Est2$tau, color = 3, lwd = 2)
g



# 俺線ひっつけモデル ---------------------------------------------------------------


model3b <- rstan::stan_model("changePoint3b.stan")
dataSet <- list(L = NROW(dat3), X = dat3$cDate, W = dat3$weight)
fit3b <- sampling(
  model3b,
  data = dataSet,
  chains = 4,
)

fit3b.df <- fit3b %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter, names_to = "Varname") %>%
  group_by(Varname) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    SD = sd(value),
    L95 = quantile(value, probs = 0.025),
    L50 = quantile(value, probs = 0.25),
    U50 = quantile(value, probs = 0.75),
    U95 = quantile(value, probs = 0.975)
  ) %>%
  print()



## 折れたのはいつ？
Est2b <- fit3b.df %>%
  select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(beta0a = 1, beta0b = 2)
## プロット
g <- ggplot() +
  geom_point(data = dat3, aes(x = cDate, y = weight)) +
  stat_function(
    xlim = c(1, Est2b$tau),
    fun = function(x) Est2b$beta0a + Est2b$beta1a * x, aes(color = palette()[2]), lty = 2, lwd = 2
  ) +
  stat_function(
    xlim = c(Est2b$tau, NROW(dat3)),
    fun = function(x) Est2b$beta0b + Est2b$beta1b * x, aes(color = palette()[2]), lty = 2, lwd = 2
  ) +
  geom_vline(xintercept = Est2b$tau, color = 3, lwd = 2) +
  theme(legend.position = "none")
g

# 課題 ----------------------------------------------------------------------

dat3.kadai <- dat %>%
  dplyr::filter(date > "2015/01/01") %>%
  dplyr::filter(date < "2015/12/10") %>%
  rowid_to_column("cDate")
g <- dat3.kadai %>%
  mutate(date = as.Date(date)) %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point() +
  scale_x_date(date_labels = "%m/%d")
g

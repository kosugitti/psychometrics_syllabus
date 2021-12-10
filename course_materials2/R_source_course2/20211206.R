rm(list = ls())
source("utilities.R")
dat <- read_csv("weight.csv")
g <- dat %>%
  dplyr::filter(date > "2021/05/01") %>%
  dplyr::filter(date < "2021/10/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point()

ggsave(g, filename = "../images/chapter28/Rplot28_01.png", dpi = 600, width = 8, height = 4)

# 二種類混ぜる ------------------------------------------------------------------

dat1 <- dat %>%
  dplyr::filter(date > "2019/01/01") %>%
  dplyr::filter(date < "2021/01/01")

model <- cmdstanr::cmdstan_model("changePoint1.stan")
dataSet <- list(L = NROW(dat1), W = dat1$weight)
fit <- model$sample(data = dataSet, chains = 4, parallel_chains = 4, seed = 12345)
fit
fit.df <- fit$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()

timeCheck <- fit.df %>%
  dplyr::filter(str_detect(Varname, pattern = "theta")) %>%
  mutate(time = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(time) %>%
  dplyr::select(time, MAP) %>%
  dplyr::mutate(FLG = if_else(MAP > .5, 1, 0))

g <- dat1 %>%
  bind_cols(timeCheck) %>%
  ggplot(aes(x = date, y = weight, color = as.factor(FLG))) +
  geom_point() +
  geom_hline(yintercept = 81.2, color = 1) +
  geom_hline(yintercept = 83.1, color = 2)
ggsave(g, filename = "../images/chapter28/Rplot28_02.png", dpi = 600, width = 8, height = 4)

# 変化点検出 -------------------------------------------------------------------

g <- dat %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point()
ggsave(g, filename = "../images/chapter28/Rplot28_03.png", dpi = 600, width = 8, height = 4)

dat2 <- dat %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01")

model2 <- cmdstanr::cmdstan_model("changePoint2.stan")
dataSet <- list(L = NROW(dat2), W = dat2$weight)
fit2 <- model2$sample(data = dataSet, chains = 4, parallel_chains = 4, seed = 12345)
fit2.df <- fit2$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()

Est <- fit2.df %>%
  dplyr::select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(lp = 1, mu1 = 2, mu2 = 3, sigma = 4, tau = 5)
## 怪我したのが5/11，手術が5/17
dat2[145, ]
g <- dat %>%
  dplyr::filter(date > "2021/01/01") %>%
  dplyr::filter(date < "2021/11/01") %>%
  rowid_to_column("Date") %>%
  ggplot(aes(x = Date, y = weight)) +
  geom_point() +
  geom_segment(x = 1, xend = Est$tau, y = Est$mu2, yend = Est$mu2, color = 2) +
  geom_segment(x = Est$tau, xend = dataSet$L, y = Est$mu1, yend = Est$mu1, color = 2) +
  geom_vline(xintercept = Est$tau, color = 3, lwd = 2)

ggsave(g, filename = "../images/chapter28/Rplot28_04.png", dpi = 600, width = 8, height = 4)

# 折線回帰 --------------------------------------------------------------------

dat %>%
  # dplyr::filter(date > "2021/01/01") %>%
  # dplyr::filter(date < "2021/11/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point()

dat3 <- dat %>%
  dplyr::filter(date > "2016/01/01") %>%
  dplyr::filter(date < "2016/12/10") %>%
  rowid_to_column("cDate")


g <- dat3 %>% ggplot(aes(x = as.Date(date), y = weight)) +
  geom_point() +
  scale_x_date(date_labels = "%m/%d")
ggsave(g, filename = "../images/chapter28/Rplot28_05.png", dpi = 600, width = 8, height = 4)


model3 <- cmdstanr::cmdstan_model("changePoint3.stan")
dataSet <- list(L = NROW(dat3), X = dat3$cDate, W = dat3$weight)
fit3 <- model3$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  seed = 8931
)
fit3.df <- fit3$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()




## 変化点はいつ？
Est2 <- fit3.df %>%
  select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(beta0a = 1, beta0b = 2)


g <- ggplot() +
  geom_point(data = dat3, aes(x = cDate, y = weight)) +
  stat_function(fun = function(x) Est2$beta0a + Est2$beta1a * x, aes(color = palette()[2]), lty = 2, lwd = 2) +
  stat_function(fun = function(x) Est2$beta0b + Est2$beta1b * x, aes(color = palette()[2]), lty = 2, lwd = 2) +
  geom_vline(xintercept = Est2$tau, color = 3, lwd = 2)

ggsave(g, filename = "../images/chapter28/Rplot28_06.png", dpi = 600, width = 8, height = 4)


# 俺線ひっつけモデル ---------------------------------------------------------------


model3b <- cmdstanr::cmdstan_model("changePoint3b.stan")
dataSet <- list(L = NROW(dat3), X = dat3$cDate, W = dat3$weight)
fit3b <- model3b$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  seed = 8931
)

fit3b.df <- fit3b$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()

## 折れたのはいつ？
Est2b <- fit3b.df %>%
  select(Varname, MAP) %>%
  pivot_wider(names_from = Varname, values_from = MAP) %>%
  rename(beta0a = 1, beta0b = 2)

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
  geom_vline(xintercept = Est2b$tau, color = 3, lwd = 2)

ggsave(g, filename = "../images/chapter28/Rplot28_07.png", dpi = 600, width = 8, height = 4)

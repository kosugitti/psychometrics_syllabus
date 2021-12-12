# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 12. IRT models Cmdstan version.

rm(list = ls())
library(tidyverse)
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

dat <- read_csv("IRTsample.csv")

# Plotting functions ------------------------------------------------------

oneParameters <- function(x, b) {
  1 / (1 + exp(-1.7 * (x - b)))
}


twoParameters <- function(x, a, b) {
  1 / (1 + exp(-1.7 * a * (x - b)))
}

threeParameters <- function(x, a = 1, b = 0, c = 0) {
  c + (1 - c) / (1 + exp(-1.7 * a * (x - b)))
}


# 理論的プロット -----------------------------------------------------------------

p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta")
g1 <- p +
  stat_function(fun = oneParameters, args = list(b = 1), color = palette()[2]) +
  stat_function(fun = oneParameters, args = list(b = -1), color = palette()[3]) +
  stat_function(fun = oneParameters, args = list(b = 2), color = palette()[4]) + ylab("pass") +
  ggtitle("1PL model.困難度母数はそれぞれ1，-1，2")
g2 <- p + stat_function(fun = twoParameters, args = list(a = 1, b = 1), color = palette()[2]) +
  stat_function(fun = twoParameters, args = list(a = 0.8, b = -1), color = palette()[3]) +
  stat_function(fun = twoParameters, args = list(a = 2, b = 2), color = palette()[4]) + ylab("pass") +
  ggtitle("2PL model.識別力母数はそれぞれ1，0.8，1.2")
g3 <- p + stat_function(fun = threeParameters, args = list(a = 1, b = 1, c = 0), color = palette()[2]) +
  stat_function(fun = threeParameters, args = list(a = 0.8, b = -1, c = 0.2), color = palette()[3]) +
  stat_function(fun = threeParameters, args = list(a = 1.2, b = 2, c = 0.3), color = palette()[4]) + ylab("pass") +
  ggtitle("3PL model.当て推量母数はそれぞれ0,0.2,0.3")

plot(g1)
plot(g2)
plot(g3)


# Stanによる推定 ---------------------------------------------------------------

map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}

model_1pl <- cmdstan_model("oneParameter.stan")
model_2pl <- cmdstan_model("twoParameters.stan")
model_3pl <- cmdstan_model("threeParameters.stan")

dataSet <- list(N = NROW(dat), M = NCOL(dat), resp = as.matrix(dat))
fit1 <- model_1pl$sample(data = dataSet, chains = 4, parallel_chains = 4)
fit2 <- model_2pl$sample(data = dataSet, chains = 4, parallel_chains = 4)
fit3 <- model_3pl$sample(data = dataSet, chains = 4, parallel_chains = 4)

fit1.stanfit <- fit1$output_files() %>% rstan::read_stan_csv()
fit2.stanfit <- fit2$output_files() %>% rstan::read_stan_csv()
fit3.stanfit <- fit3$output_files() %>% rstan::read_stan_csv()


fit1.df <- fit1.stanfit %>% 
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

fit2.df <- fit2.stanfit %>%
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

fit3.df <- fit3.stanfit %>%
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

tbl1 <- fit1.df %>%
  dplyr::select(Varname, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = "[a-b]\\[\\d+\\]")) %>%
  dplyr::filter(!str_detect(Varname, pattern = "theta")) %>%
  dplyr::mutate(Parameters = str_extract(Varname, pattern = "[ab]")) %>%
  dplyr::mutate(Qid = str_extract(Varname, "\\d+") %>% as.numeric()) %>%
  dplyr::select(-Varname) %>%
  pivot_wider(id_cols = Qid, names_from = Parameters, values_from = EAP) %>%
  rename(one_b = b)

tbl2 <- fit2.df %>%
  dplyr::select(Varname, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = "[a-b]\\[\\d+\\]")) %>%
  dplyr::filter(!str_detect(Varname, pattern = "theta")) %>%
  dplyr::mutate(Parameters = str_extract(Varname, pattern = "[ab]")) %>%
  dplyr::mutate(Qid = str_extract(Varname, "\\d+") %>% as.numeric()) %>%
  dplyr::select(-Varname) %>%
  pivot_wider(id_cols = Qid, names_from = Parameters, values_from = EAP) %>%
  rename(two_b = b, two_a = a)

tbl3 <- fit3.df %>%
  dplyr::select(Varname, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = "[a-c]\\[\\d+\\]")) %>%
  dplyr::filter(!str_detect(Varname, pattern = "theta")) %>%
  dplyr::mutate(Parameters = str_extract(Varname, pattern = "[abc]")) %>%
  dplyr::mutate(Qid = str_extract(Varname, "\\d+") %>% as.numeric()) %>%
  dplyr::select(-Varname) %>%
  pivot_wider(id_cols = Qid, names_from = Parameters, values_from = EAP) %>%
  rename(three_a = a, three_b = b, three_c = c)

tbl1 %>%
  left_join(tbl2, by = "Qid") %>%
  left_join(tbl3, by = "Qid") %>%
  arrange(Qid) %>%
  print()

# 推定値プロット -----------------------------------------------------------------

g1 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("1PL model")
for (i in 1:10) {
  g1 <- g1 +
    stat_function(fun = oneParameters, args = list(b = tbl1$one_b[i]), color = palette()[i])
}
plot(g1)

g2 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("2PL model")
for (i in 1:10) {
  g2 <- g2 +
    stat_function(fun = twoParameters, args = list(a = tbl2$two_a[i], b = tbl2$two_b[i]), color = palette()[i])
}
plot(g2)

g3 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("3PL model")
for (i in 1:10) {
  g3 <- g3 +
    stat_function(fun = threeParameters, args = list(a = tbl3$three_a[i], b = tbl3$three_b[i], c = tbl3$three_c[i]), color = palette()[i])
}
plot(g3)

# Tidy Data ---------------------------------------------------------------

dat.tmp <- dat %>%
  rowid_to_column("Pid") %>%
  pivot_longer(-Pid) %>%
  mutate(Qid = str_extract(name, pattern = "\\d+") %>% as.numeric()) %>%
  dplyr::select(Pid, Qid, value)

# わざと欠損値を与える
dat.tmp$value[1] <- NA
dat.tmp$value[11:13] <- NA
# 確認
dat.tmp %>% head(20)

dataSet <- list(
  L = NROW(dat.tmp), N = max(dat.tmp$Pid), M = max(dat.tmp$Qid),
  Pid = dat.tmp$Pid, Qid = dat.tmp$Qid,
  resp = dat.tmp$value
)

model_2pl_ver2 <- cmdstan_model("twoParameters2.stan")
fit2.2 <- model_2pl_ver2$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4
)

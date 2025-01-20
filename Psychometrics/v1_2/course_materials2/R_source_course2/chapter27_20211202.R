source("utilities.R")
dat <- read_csv("IRTsample.csv")
model_1pl <- cmdstan_model("oneParameter.stan")
model_2pl <- cmdstan_model("twoParameters.stan")
model_3pl <- cmdstan_model("threeParameters.stan")

dataSet <- list(N = NROW(dat), M = NCOL(dat), resp = as.matrix(dat))
fit1 <- model_1pl$sample(data = dataSet, chains = 4, parallel_chains = 4)
fit2 <- model_2pl$sample(data = dataSet, chains = 4, parallel_chains = 4)
fit3 <- model_3pl$sample(data = dataSet, chains = 4, parallel_chains = 4)

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


fit1.df <- fit1$output_files() %>% rstan::read_stan_csv()
fit2.df <- fit2$output_files() %>% rstan::read_stan_csv()
fit3.df <- fit3$output_files() %>% rstan::read_stan_csv()
fit2.2.df <- fit2.2$output_files() %>% rstan::read_stan_csv()

fit1.result <- fit1.df %>% MCMC_result()
fit2.result <- fit2.df %>% MCMC_result()
fit3.result <- fit3.df %>% MCMC_result()
fit2.2result <- fit2.2.df %>% MCMC_result()


tbl1 <- fit1.result %>%
  dplyr::select(Varname, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = "[a-b]\\[\\d+\\]")) %>%
  dplyr::filter(!str_detect(Varname, pattern = "theta")) %>%
  dplyr::mutate(Parameters = str_extract(Varname, pattern = "[ab]")) %>%
  dplyr::mutate(Qid = str_extract(Varname, "\\d+") %>% as.numeric()) %>%
  dplyr::select(-Varname) %>%
  pivot_wider(id_cols = Qid, names_from = Parameters, values_from = EAP) %>%
  rename(one_b = b)
tbl2 <- fit2.result %>%
  dplyr::select(Varname, EAP) %>%
  dplyr::filter(str_detect(Varname, pattern = "[a-b]\\[\\d+\\]")) %>%
  dplyr::filter(!str_detect(Varname, pattern = "theta")) %>%
  dplyr::mutate(Parameters = str_extract(Varname, pattern = "[ab]")) %>%
  dplyr::mutate(Qid = str_extract(Varname, "\\d+") %>% as.numeric()) %>%
  dplyr::select(-Varname) %>%
  pivot_wider(id_cols = Qid, names_from = Parameters, values_from = EAP) %>%
  rename(two_b = b, two_a = a)
tbl3 <- fit3.result %>%
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
  knitr::kable(format = "latex", caption = "それぞれのパラメータ推定値", digits = 3)


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
  stat_function(fun = twoParameters, args = list(a = 1.2, b = 2), color = palette()[4]) + ylab("pass") +
  ggtitle("2PL model.識別力母数はそれぞれ1，0.8，1.2")
g3 <- p + stat_function(fun = threeParameters, args = list(a = 1, b = 1, c = 0), color = palette()[2]) +
  stat_function(fun = threeParameters, args = list(a = 0.8, b = -1, c = 0.2), color = palette()[3]) +
  stat_function(fun = threeParameters, args = list(a = 1.2, b = 2, c = 0.3), color = palette()[4]) + ylab("pass") +
  ggtitle("3PL model.当て推量母数はそれぞれ0,0.2,0.3")

g <- g1 / g2 / g3
ggsave(g, filename = "../images/chapter27/Rplot27_01.png", dpi = 600, width = 16, height = 16)
g

# 推定値プロット -----------------------------------------------------------------

g1 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("1PL model")
for (i in 1:10) {
  g1 <- g1 +
    stat_function(fun = oneParameters, args = list(b = tbl1$one_b[i]), color = palette()[i])
}

g2 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("2PL model")
for (i in 1:10) {
  g2 <- g2 +
    stat_function(fun = twoParameters, args = list(a = tbl2$two_a[i], b = tbl2$two_b[i]), color = palette()[i])
}

g3 <- p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  xlab("theta") +
  ggtitle("3PL model")
for (i in 1:10) {
  g3 <- g3 +
    stat_function(fun = threeParameters, args = list(a = tbl3$three_a[i], b = tbl3$three_b[i], c = tbl3$three_c[i]), color = palette()[i])
}
g <- g1 / g2 / g3
ggsave(g, filename = "../images/chapter27/Rplot27_02.png", dpi = 600, width = 16, height = 16)
g

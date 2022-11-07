# 心理学データ解析応用/伴走サイトコード -----------------------------------------------------
#  Programmed by kosugitti 
#  Licence ; Creative Commons BY-SA license (CC BY-SA) version 4.0
## Lesson 11. Mixture model Cmdstan version.

rm(list = ls())
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")
## MAP関数
map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}

# データの読み込み ----------------------------------------------------------------

dat <- read_csv("baseballDecade.csv")

## 分布の可視化
dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  ggplot(aes(x = salary.log, y = ..density..)) +
  geom_histogram(position = "identity", alpha = 0.8, binwidth = 0.35) +
  geom_density(aes(color = team), show.legend = F)

## 混合分布によるモデリング

dat.tmp <- dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  dplyr::select(salary.log, Name) %>%
  rowid_to_column("ID")

dataSet <- list(K = 2, L = NROW(dat.tmp), Y = dat.tmp$salary.log)
model <- cmdstanr::cmdstan_model("latent.stan")
## サンプリングの際に，Rhatがうまくいかないことがあれば，違うseed値でやり直してみてください。
fit <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  seed = 12345
)


fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
print(fit.stanfit, pars = c("mu", "sigma"))

## 所属クラスと描画
fit.stanfit %>%
  rstan::extract() %>%
  as.data.frame() %>%
  as_tibble() %>%
  rowid_to_column("iter") %>%
  group_by(iter) %>%
  pivot_longer(-iter, names_to = "Varname") %>%
  group_by(Varname) %>%
  summarise(EAP = mean(value)) %>%
  dplyr::filter(str_detect(Varname, pattern = c("pred_class"))) %>%
  mutate(Class = round(EAP)) %>%
  mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  left_join(dat.tmp, by = "ID") %>%
  print() %>%
  ggplot(aes(x = exp(salary.log), fill = as.factor(Class))) +
  geom_histogram(binwidth = 1000)


# ゼロ過剰ポアソン ----------------------------------------------------------------

## データの素描
dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  ggplot(aes(x = Save)) +
  geom_histogram()

## ゼロ過剰ポアソン分布をあてはめたモデリング
dat.tmp <- dat %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(Games > 50) %>%
  dplyr::select(Save)

model <- cmdstan_model("ziPoisson.stan")
dataSet <- list(L = NROW(dat.tmp), Y = dat.tmp$Save)
fit <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  seed = 12345
)

fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
fit.stanfit

## 事後予測分布的に作ってみる
theta <- 0.61
lambda <- 14.67
N <- NROW(dat.tmp)
data.frame(FLG = rbinom(N, size = 1, prob = theta)) %>%
  rowwise() %>%
  mutate(Save = if_else(FLG == 1, rpois(1, lambda), rpois(1, 0))) %>%
  ggplot(aes(x = Save)) +
  geom_histogram(binwidth = 1)




# 課題 ----------------------------------------------------------------------

## 課題1　混合分布モデル

### Tigersのところを色々変えて，混合分布が適用できそうなチームを探そう
dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "Tigers") %>%
  mutate(salary.log = log(salary)) %>%
  ggplot(aes(x = salary.log, y = ..density..)) +
  geom_histogram(position = "identity", alpha = 0.8, binwidth = 0.35) +
  geom_density(aes(color = team), show.legend = F)

## チームが見つかったら，データを作って分析しよう。

dat.tmp <- dat %>%
  filter(position != "投手") %>%
  filter(Games > 50) %>%
  filter(team == "XXXX") %>%
  mutate(salary.log = log(salary)) %>%
  dplyr::select(salary.log, Name) %>%
  rowid_to_column("ID")

## 課題2　ゼロ過剰ポアソン回帰

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
  parallel_chains = 4,
  seed = 12345
)

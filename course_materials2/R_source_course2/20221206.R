# 準備 ----------------------------------------------------------------------

rm(list = ls())
library(pacman)
pacman::p_load(
  tidyverse,
  posterior,
  bayesplot,
  RColorBrewer,
  ggthemes,
  patchwork,
  cmdstanr,
  bayestestR
)
color_scheme_set("brightblue")
## MAP関数
map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}

## MCMCサンプルをデータフレームにする関数
MCMCtoDF <- function(fit) {
  fit$draws() %>%
    posterior::as_draws_df() %>%
    tibble::as_tibble() %>%
    dplyr::select(-lp__, -.draw, -.chain, -.iteration) %>%
    tibble::rowid_to_column("iter") %>%
    tidyr::pivot_longer(-iter) -> MCMCsample
  return(MCMCsample)
}

## MCMCデータフレームを要約する関数
MCMCsummary <- function(MCMCsample) {
  MCMCsample %>%
    dplyr::group_by(name) %>%
    dplyr::summarise(
      EAP = mean(value),
      MED = median(value),
      MAP = map_estimation(value),
      SD = sd(value),
      L95 = quantile(value, prob = 0.025),
      U95 = quantile(value, prob = 0.975),
      Rhat = posterior::rhat_basic(value)
    ) %>%
    mutate(across(where(is.numeric), ~ num(., digits = 3)))
}


pois_reg <- function(b0, b1, x, m) {
  exp(b0 + b1 * x + m)
}

# データの読み込み ----------------------------------------------------------------

baseball <- read_csv("baseballDecade.csv")

dat <- baseball %>%
  filter(position == "投手") %>%
  filter(team == "Swallows") %>%
  group_by(Name) %>%
  nest() %>%
  mutate(
    n = purrr::map_dbl(data, ~ NROW(.)),
    FLG = purrr::map_lgl(data, ~ anyNA(.$Win))
  ) %>%
  filter(n > 7) %>%
  filter(!FLG) %>%
  unnest(data) %>%
  select(Year, Name, salary, Win)

dat.tmp <- dat %>%
  mutate(salary = salary / 1000) %>%
  mutate(ID = as.factor(Name)) %>%
  mutate(ID = as.numeric(ID))

dat$Name %>%
  table() %>%
  length()

dat %>%
  #  dplyr::filter(Year == "2020年度") %>%
  mutate(salary = salary / 1000) %>%
  mutate(ID = as.factor(Name)) %>%
  mutate(ID = as.numeric(ID)) %>%
  ggplot(aes(x = salary, y = Win, color = Name)) +
  geom_point() +
  #  theme(legend.position = "none") +
  labs(title = "年俸と勝ち星の関係") +
  ylim(0, 15) -> g1

g1

dat %>%
  group_by(Name) %>%
  summarise(
    meanS = mean(salary),
    meanW = mean(Win)
  ) %>%
  arrange(meanS)

tbl1 <- dat %>%
  #  dplyr::filter(Year == "2020年度") %>%
  mutate(salary = salary / 1000) %>%
  dplyr::select(Name, Year, salary) %>%
  pivot_wider(id_cols = Name, names_from = Year, values_from = c(salary)) %>%
  ggpubr::ggtexttable() %>%
  ggpubr::tab_add_title(text = "年俸の推移(単位;千万円)")

tbl2 <- dat %>%
  dplyr::select(Name, Year, Win) %>%
  pivot_wider(id_cols = Name, names_from = Year, values_from = c(Win)) %>%
  ggpubr::ggtexttable() %>%
  ggpubr::tab_add_title(text = "勝ち星の推移")


g <- g1 + tbl1 + tbl2 +
  patchwork::plot_layout(nrow = 3)
g

ggsave(g, filename = "../images/25_HLM/Rplot25_01.png", dpi = 600, width = 12, height = 8)
# GLMM --------------------------------------------------------------------

### ポアソン分布で個体差を入れて
### データの加工
dat.tmp <- dat %>%
  dplyr::mutate(salary = salary / 1000) %>%
  dplyr::mutate(ID = as.factor(Name)) %>%
  dplyr::mutate(ID = as.numeric(ID))

dataSet <- list(
  L = NROW(dat.tmp),
  N = max(dat.tmp$ID),
  X = dat.tmp$salary,
  Y = dat.tmp$Win,
  index = dat.tmp$ID
)

### コンパイルと推定
model <- cmdstanr::cmdstan_model("cmdstan/glmm_poisson.stan")

fit.MCMC <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 5000
)

### 結果の出力
fit.MCMC %>%
  MCMCtoDF() %>%
  MCMCsummary() %>%
  print() -> fit.MCMC_ind




### 個体差いれないポアソン分布
model_pois_plain <- cmdstan_model("cmdstan/glm_poisson.stan")
dataSet <- list(
  L = NROW(dat.tmp),
  X = dat.tmp$salary,
  Y = dat.tmp$Win,
  idIndex = dat.tmp$ID
)
fit <- model_pois_plain$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 3000
)

fit.stanfitG <- fit$output_files() %>% rstan::read_stan_csv()

fit.MCMC_g <- fit.stanfitG %>%
  as.data.frame() %>%
  as_tibble() %>%
  dplyr::select(beta0, beta1) %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter) %>%
  group_by(name) %>%
  summarise(
    EAP = mean(value),
    MED = median(value),
    MAP = map_estimation(value),
    sd = sd(value)
  )


g <- dat.tmp %>%
  ggplot(aes(x = salary, y = Win, color = Name)) +
  ylim(0, 15) +
  geom_point() +
  stat_function(
    fun = pois_reg,
    args = list(
      b0 = fit.MCMC_g[1, ]$MAP,
      b1 = fit.MCMC_g[2, ]$MAP,
      m = 0
    ),
    color = palette()[2],
    lty = 2, lwd = 2
  ) +
  theme(legend.position = "none")
g

muIND <- fit.MCMC_ind %>%
  filter(str_detect(name, "mu")) %>%
  mutate(ID = str_extract(name, pattern = "[0-9]+") %>% as.numeric()) %>%
  dplyr::select(ID, MAP, name) %>%
  print() %>%
  dplyr::mutate(name = as.factor(name)) %>%
  mutate(MAPabs = abs(MAP)) %>%
  print() %>%
  arrange(MAPabs)


for (i in 1:5) {
  g <- g +
    stat_function(
      fun = pois_reg,
      args = list(
        b0 = fit.MCMC_ind %>% filter(name == "beta0") %>% dplyr::select(MAP) %>% as.numeric(),
        b1 = fit.MCMC_ind %>% filter(name == "beta1") %>% dplyr::select(MAP) %>% as.numeric(),
        m = muIND %>% filter(ID == i) %>% dplyr::select(MAP) %>% as.numeric()
      )
    )
}

g
ggsave(g, filename = "../images/25_HLM/Rplot25_02.png", dpi = 600, width = 8, height = 4)

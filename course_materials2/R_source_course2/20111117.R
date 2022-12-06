rm(list = ls())
source("utilities.R")
library(gridExtra)
library(ggpubr) # テーブルをggplotオブジェクトに
library(patchwork) # ggplotオブジェクトを並べる
baseball <- read_csv("baseballDecade.csv")

dat <- baseball %>%
  filter(position == "投手") %>%
  filter(salary > 5000) %>%
  group_by(Name) %>%
  print() %>%
  nest() %>%
  print() %>%
  mutate(
    n = purrr::map_dbl(data, ~ NROW(.)),
    FLG = purrr::map_lgl(data, ~ anyNA(.$Win))
  ) %>%
  print() %>%
  filter(n == 10) %>%
  print() %>%
  filter(!FLG) %>%
  print() %>%
  unnest(data) %>%
  select(Year, Name, salary, Win)

# データ素描 -------------------------------------------------------------------

dat %>%
  ggplot(aes(x = Year, y = salary, group = Name, color = Name)) +
  geom_point() +
  geom_line()
dat %>%
  ggplot(aes(x = Year, y = Win, group = Name, color = Name)) +
  geom_point() +
  geom_line()
dat %>%
  ggplot(aes(x = salary, y = Win, color = Name)) +
  geom_point() +
  facet_wrap(~Name, scales = "free")

dat %>%
  #  dplyr::filter(Year == "2020年度") %>%
  mutate(salary = salary / 1000) %>%
  mutate(ID = as.factor(Name)) %>%
  mutate(ID = as.numeric(ID)) %>%
  ggplot(aes(x = salary, y = Win, color = Name)) +
  geom_point() +
  scale_colour_colorblind() +
  labs(title="年俸と勝ち星の関係")+
  ylim(0, 15) +
  xlim(0, 35) -> g1


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
  ggpubr::tab_add_title(text='勝ち星の推移')


g <- g1 + tbl1 + tbl2 +
  patchwork::plot_layout(nrow = 3)
g
ggsave(g, filename = "../images/25_HLM/Rplot25_01.png", dpi = 600, width = 12, height = 8)
# GLMM --------------------------------------------------------------------

### ポアソン分布で個体差を入れて
#### リンク関数はlog,逆リンクはexp
model_pois <- cmdstanr::cmdstan_model("cmdstan/glmm_poisson.stan")

dat.tmp <- dat %>%
  mutate(salary = salary / 1000) %>%
  mutate(ID = as.factor(Name)) %>%
  mutate(ID = as.numeric(ID))

dataSet <- list(
  L = NROW(dat.tmp),
  N = max(dat.tmp$ID),
  X = dat.tmp$salary,
  Y = dat.tmp$Win,
  index = dat.tmp$ID
)

model_pois <- cmdstanr::cmdstan_model("cmdstan/glmm_poisson.stan")
fit <- model_pois$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 3000
)

fit$summary()
fit$draws() %>%
  mcmc_areas(
    #    pars = c("beta0", "beta1", "mu[1]", "mu[2]", "mu[3]", "mu[4]", "mu[5]"),
    pars = "beta0",
    prob = 0.5, # 50% intervals
    prob_outer = 0.95, # 99%
    point_est = "mean"
  )

pois_reg <- function(b0, b1, x, m) {
  exp(b0 + b1 * x)
}

fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()

fit.MCMC <- fit.stanfit %>%
  as.data.frame() %>%
  as_tibble() %>%
  dplyr::select(beta0, beta1, "mu[1]", "mu[2]", "mu[3]", "mu[4]", "mu[5]") %>%
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
  scale_colour_colorblind() +
  geom_point() 
  ylim(0, 15) +
  xlim(0, 35) +
  stat_function(fun = pois_reg, args = list(b0 = -0.144, b1 = 0.0621, m = -0.960), lty = 2) +
  stat_function(fun = pois_reg, args = list(b0 = -0.144, b1 = 0.0621, m = -0.091), lty = 2) +
  stat_function(fun = pois_reg, args = list(b0 = -0.144, b1 = 0.0621, m = 1.720), lty = 2) +
  stat_function(fun = pois_reg, args = list(b0 = -0.144, b1 = 0.0621, m = 0.153), lty = 2) +
  stat_function(fun = pois_reg, args = list(b0 = -0.144, b1 = 0.0621, m = -0.680), lty = 2)



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

estb0 <- fit.MCMC[1,]$EAP
estb1 <- fit.MCMC[2,]$EAP
estm1 <- fit.MCMC[3,]$EAP
estm2 <- fit.MCMC[4,]$EAP
estm3 <- fit.MCMC[5,]$EAP
estm4 <- fit.MCMC[6,]$EAP
estm5 <- fit.MCMC[7,]$EAP
estGb0 <- fit.MCMC_g[1,]$EAP
estGb1 <- fit.MCMC_g[2,]$EAP

g <- dat.tmp %>%
  ggplot(aes(x = salary, y = Win, color=Name)) +
  scale_colour_colorblind() +
  geom_point() +
  ylim(0, 15) +
  xlim(0, 35) +
  stat_function(fun = pois_reg, args = list(b0 = estb0, b1 = estb1, m = estm1), lty = 2,color=1) +
  stat_function(fun = pois_reg, args = list(b0 = estb0, b1 = estb1, m = estm2), lty = 2,color=2) +
  stat_function(fun = pois_reg, args = list(b0 = estb0, b1 = estb1, m = estm3), lty = 2,color=3) +
  stat_function(fun = pois_reg, args = list(b0 = estb0, b1 = estb1, m = estm4), lty = 2,color=4) +
  stat_function(fun = pois_reg, args = list(b0 = estb0, b1 = estb1, m = estm5), lty = 2,color=5) +
  stat_function(fun = pois_reg, args = list(b0 = estGb0, b1 = estGb1, m = 0), color = palette()[2], lty = 2, lwd = 2)

g
ggsave(g, filename = "../images/25_HLM/Rplot25_02.png", dpi = 600, width = 8, height = 4)

# 二項分布の例で ----------------------------------------------------------

dat <- baseball %>%
  dplyr::filter(position != "投手") %>%
  dplyr::filter(Year == "2020年度") %>%
  filter(salary > 5000) %>%
  filter(AtBats > 50) %>%
  filter(AtBats < 400) %>%
  select(Year, Name, salary, AtBats, Hit, Games, HR)

model_binom <- cmdstanr::cmdstan_model("glmm_binomial2.stan")
dat.tmp <- dat %>%
  mutate(salary = salary / 1000) %>%
  mutate(ID = as.factor(Name)) %>%
  mutate(ID = as.numeric(ID))

dataSet <- list(
  L = NROW(dat.tmp), X = dat.tmp$salary,
  Y = dat.tmp$Hit, N = dat.tmp$AtBats
)
fit <- model_binom$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
)

fit


# 階層データの解説 ----------------------------------------------------------------

### 複数の異なる群
N <- 100
X1 <- rnorm(N, 10, 15)
X2 <- rnorm(N, 40, 15)
X3 <- rnorm(N, 70, 15)
Y1 <- X1 * -0.3 + rnorm(N, 0, 10) + 10
Y2 <- X2 * -0.3 + rnorm(N, 0, 10) + 50
Y3 <- X3 * -0.3 + rnorm(N, 0, 10) + 80
dat <- data.frame(rbind(cbind(X1, Y1), cbind(X2, Y2), cbind(X3, Y3)))
cor(dat[, 1:2])
dat$group <- factor(rep(1:3, each = N), labels = c("Group A", "Group B", "Group C"))
g1 <- ggplot(dat, aes(x = X1, y = Y1)) +
  geom_point() +
  geom_smooth(method = "lm", se = F, formula = "y~x")
scale_colour_colorblind()
g1

g2 <- ggplot(dat, aes(x = X1, y = Y1, shape = group, color = group)) +
  geom_point() +
  geom_smooth(method = "lm", se = F, formula = "y~x") +
  xlab("") +
  ylab("")
g2

g <- gridExtra::grid.arrange(g1, g2, ncol = 2)
ggsave(g, filename = "../images/chapter25/Rplot25_03.png", dpi = 600, width = 8, height = 4)
g
# 階層線形モデル -----------------------------------------------------------------

## バッターはホームラン打つと儲かる
batter <- baseball %>%
  dplyr::filter(Year == "2020年度") %>%
  dplyr::filter(position != "投手") %>%
  dplyr::filter(Games > 50) %>%
  mutate(salary = salary / 1000) %>%
  dplyr::select(Name, team, salary, HR)

batter %>% ggplot(aes(y = HR, x = salary)) +
  geom_point() +
  xlim(0, 50) +
  ylim(0, 50) +
  geom_smooth(method = "lm", formula = "y~x", se = F) +
  facet_wrap(~team)


## ピッチャーはかつと儲かる
pitcher <- baseball %>%
  dplyr::filter(Year == "2020年度") %>%
  dplyr::filter(position == "投手") %>%
  dplyr::filter(salary > 1000) %>%
  mutate(salary = salary / 1000) %>%
  dplyr::select(Name, team, salary, Win)

pitcher %>%
  ggplot(aes(y = Win, x = salary)) +
  geom_point() +
  geom_smooth(method = "lm", formula = "y~x", se = F) +
  facet_wrap(~team)

modelH <- cmdstan_model("cmdstan/hlm_poisson.stan")
dat.tmp <- batter %>%
  mutate(
    NameID = as.factor(Name),
    teamID = as.factor(team)
  ) %>%
  mutate(
    NameID = as.numeric(NameID),
    teamID = as.numeric(teamID)
  )
dataSet <- list(
  L = NROW(dat.tmp),
  G = max(dat.tmp$teamID),
  Gindex = dat.tmp$teamID,
  X = dat.tmp$salary,
  Y = dat.tmp$HR
)
fit_glmm <- modelH$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000
)

fit_glmm %>%
  MCMCtoDF() %>%
  dplyr::filter(str_detect(name, pattern = "tau|gamma")) %>%
  MCMCsummary()


fit.stanfit <- fit_glmm$output_files() %>% rstan::read_stan_csv()
fit.stanfit %>%
  MCMC_result() %>%
  dplyr::filter(str_detect(Varname, pattern = "tau|gamma"))

coeffs <- fit.stanfit %>%
  MCMC_result() %>%
  dplyr::filter(str_detect(Varname, pattern = "beta")) %>%
  dplyr::select(Varname, MAP, U50, L50) %>%
  dplyr::mutate(
    coef = str_sub(Varname, 1, 5),
    G = str_extract(Varname, pattern = "\\[.*?\\]")
  ) %>%
  dplyr::mutate(
    teamID = str_extract(G, pattern = "[0-9]+") %>% as.double()
  ) %>%
  dplyr::select(-Varname) %>%
  tidyr::pivot_wider(names_from = coef, values_from = c(MAP, U50, L50))

plot.tmp <- dat.tmp %>%
  dplyr::select(team, teamID) %>%
  distinct() %>%
  dplyr::right_join(coeffs, by = "teamID") %>%
  dplyr::select(-G)

batter %>%
  ggplot(aes(x = salary, y = HR, color = team)) +
  geom_point() +
  xlim(0, 50) +
  ylim(0, 50) +
  stat_function(fun = pois_reg, args = list(b0 = 1.45, b1 = 0.0459, m = 0), lty = 1) +
  stat_function(fun = pois_reg, args = list(b0 = 1.37, b1 = 0.0395, m = 0), lty = 2) +
  stat_function(fun = pois_reg, args = list(b0 = 1.68, b1 = 0.0675, m = 0), lty = 2)

plot.data.set <- batter %>%
  group_nest(team) %>%
  right_join(plot.tmp)

g <- plot.data.set %>%
  unnest(data) %>%
  ggplot(aes(x = salary, y = HR, group = team, color = team)) +
  geom_point() +
  geom_smooth(
    method = "glm", formula = "y~x", se = F,
    method.args = list(family = poisson(link = "log"))
  )
ggsave(g, filename = "../images/chapter25/Rplot25_04.png", dpi = 600, width = 8, height = 4)
g


plot.list <- list()
for (g in 1:12) {
  plot.list[[g]] <- plot.data.set[g, ] %>%
    unnest(data) %>%
    ggplot(aes(x = salary, y = HR)) +
    geom_point(color = g) +
    stat_function(fun = pois_reg, args = list(
      b0 = plot.data.set[g, ]$MAP_beta0,
      b1 = plot.data.set[g, ]$MAP_beta1, m = 0
    ), color = g, lwd = 1) +
    stat_function(fun = pois_reg, args = list(
      b0 = plot.data.set[g, ]$U50_beta0,
      b1 = plot.data.set[g, ]$U50_beta1, m = 0
    ), color = g, lty = 2) +
    stat_function(fun = pois_reg, args = list(
      b0 = plot.data.set[g, ]$L50_beta0,
      b1 = plot.data.set[g, ]$L50_beta1, m = 0
    ), color = g, lty = 2) +
    ggtitle(plot.data.set[g, ]$team)
}

g <- do.call(grid.arrange, plot.list)
plot(g)
ggsave(g, filename = "../images/chapter25/Rplot25_05.png", dpi = 600, width = 12, height = 12)
g



# ピッチャーのデータ ---------------------------------------------------------------

dat.tmp <- pitcher %>%
  mutate(
    NameID = as.factor(Name),
    teamID = as.factor(team)
  ) %>%
  mutate(
    NameID = as.numeric(NameID),
    teamID = as.numeric(teamID)
  )
dataSet <- list(
  L = NROW(dat.tmp),
  G = max(dat.tmp$teamID),
  Gindex = dat.tmp$teamID,
  X = dat.tmp$salary,
  Y = dat.tmp$Win
)
fit_glmm <- modelH$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4,
  iter_sampling = 5000,
  iter_warmup = 1000
)

fit_glmm

fit.stanfit <- fit_glmm$output_files() %>% rstan::read_stan_csv()
fit.stanfit %>%
  MCMC_result() %>%
  dplyr::filter(str_detect(Varname, pattern = "tau|gamma"))


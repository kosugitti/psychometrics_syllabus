# ch29「ベイズを実践する」用の分析 -----
# brms節・stan節・生成量節で使う結果を一括で作る。
# データはch09/ch24と同じBaseballDecade.csv(2020年度)を使い，
# 最小二乗・最尤ときた回帰をベイズで再現する。

rm(list = ls())
pacman::p_load(tidyverse, brms, cmdstanr, bayesplot, posterior, ragg)

options(brms.backend = "cmdstanr")
SEED <- 12345
OUT <- "../figures/29_bayesian_modeling"
LOG <- "ch29_output.txt"
sink(LOG, split = TRUE)

# データの準備 -----
dat <- readr::read_csv("BaseballDecade.csv", na = "NA",
                       locale = locale(encoding = "utf8"),
                       show_col_types = FALSE) %>%
  dplyr::filter(Year == "2020年度")

batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight, HR, AtBats)

cat("\n===== 1. データの規模 =====\n")
cat("2020年度 全体:", nrow(dat), "行\n")
cat("野手のみ    :", nrow(batter), "行\n")

# 参考: ch24でやった最尤推定(lm) -----
cat("\n===== 2. lm()による最尤推定(ch24の再掲) =====\n")
result.LM <- lm(weight ~ height, data = batter)
print(summary(result.LM))

# brmsによるベイズ回帰 -----
cat("\n===== 3. brmsによるベイズ回帰 =====\n")
fit1 <- brms::brm(weight ~ height, data = batter,
                  seed = SEED, chains = 4, iter = 2000,
                  refresh = 0, silent = 2)
print(summary(fit1))

cat("\n----- 事後分布の要約(bayestestR) -----\n")
print(bayestestR::describe_posterior(fit1))

# make_stancodeで自動生成コードを覗く -----
cat("\n===== 4. make_stancode()の出力 =====\n")
cat(brms::make_stancode(weight ~ height, data = batter))

cat("\n===== 5. make_standata()の中身 =====\n")
sd1 <- brms::make_standata(weight ~ height, data = batter)
print(str(sd1))

# family変更でGLMへ -----
cat("\n===== 6. ポアソン回帰(family=poisson) =====\n")
batter.hr <- batter %>% dplyr::filter(!is.na(HR), !is.na(AtBats), AtBats > 0)
fit2 <- brms::brm(HR ~ height + offset(log(AtBats)), data = batter.hr,
                  family = poisson(), seed = SEED, chains = 4, iter = 2000,
                  refresh = 0, silent = 2)
print(summary(fit2))

# 生成量: 投手と野手の体重差 -----
cat("\n===== 7. 2群の比較(投手 vs 野手) =====\n")
dat2 <- dat %>%
  dplyr::filter(!is.na(weight)) %>%
  dplyr::mutate(gun = ifelse(position == "投手", "投手", "野手")) %>%
  dplyr::select(gun, weight)
print(dat2 %>% group_by(gun) %>% summarise(n = n(), mean = mean(weight), sd = sd(weight)))

fit3 <- brms::brm(weight ~ 0 + gun, data = dat2,
                  seed = SEED, chains = 4, iter = 2000,
                  refresh = 0, silent = 2)
print(summary(fit3))

cat("\n----- 生成量: 差delta，優越率，被覆率 -----\n")
post <- posterior::as_draws_df(fit3)
mu.p <- post$"b_gun投手"
mu.y <- post$"b_gun野手"
sigma <- post$sigma
delta <- mu.p - mu.y
cat("差deltaのEAP:", round(mean(delta), 3), "\n")
cat("差deltaの95%HDI:", round(bayestestR::hdi(delta, ci = 0.95)$CI_low, 3),
    round(bayestestR::hdi(delta, ci = 0.95)$CI_high, 3), "\n")
cat("P(delta > 0):", round(mean(delta > 0), 4), "\n")

# 優越率: 新たに1人ずつ観測したとき投手の方が重い確率
set.seed(SEED)
yrep.p <- rnorm(length(mu.p), mu.p, sigma)
yrep.y <- rnorm(length(mu.y), mu.y, sigma)
cat("優越率 P(投手 > 野手):", round(mean(yrep.p > yrep.y), 4), "\n")

# 被覆率(overlap coefficient): 2つの事後予測分布の重なり
d.p <- density(yrep.p, from = min(c(yrep.p, yrep.y)), to = max(c(yrep.p, yrep.y)), n = 2048)
d.y <- density(yrep.y, from = min(c(yrep.p, yrep.y)), to = max(c(yrep.p, yrep.y)), n = 2048)
ovl <- sum(pmin(d.p$y, d.y$y)) * (d.p$x[2] - d.p$x[1])
cat("被覆率(重なりの面積):", round(ovl, 4), "\n")

# 図の出力 -----
cat("\n===== 8. 図の出力 =====\n")
p1 <- bayesplot::mcmc_areas(fit1, pars = c("b_Intercept", "b_height", "sigma"), prob = 0.95) +
  labs(x = "パラメータの値", y = "")
ggsave(file.path(OUT, "posterior_regression.png"), p1,
       width = 14, height = 8, units = "cm", dpi = 300, device = ragg::agg_png)

p2 <- tibble(delta = delta) %>%
  ggplot(aes(x = delta)) +
  geom_histogram(bins = 60, fill = "gray70", colour = "gray30") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "投手と野手の体重の差(kg)", y = "頻度") +
  theme_bw(base_size = 11)
ggsave(file.path(OUT, "delta_posterior.png"), p2,
       width = 12, height = 8, units = "cm", dpi = 300, device = ragg::agg_png)

p3 <- tibble(w = c(yrep.p, yrep.y),
             gun = rep(c("投手", "野手"), each = length(yrep.p))) %>%
  ggplot(aes(x = w, fill = gun)) +
  geom_density(alpha = 0.4) +
  scale_fill_grey(start = 0.2, end = 0.7) +
  labs(x = "体重(kg)", y = "密度", fill = "") +
  theme_bw(base_size = 11)
ggsave(file.path(OUT, "posterior_predictive.png"), p3,
       width = 12, height = 8, units = "cm", dpi = 300, device = ragg::agg_png)

cat("完了\n")
sink()

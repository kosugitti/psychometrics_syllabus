# 図29_04の描き直し -----
# 切片・傾き・sigmaはスケールが違いすぎるので、パラメータごとに軸を分ける。
rm(list = ls())
pacman::p_load(tidyverse, brms, cmdstanr, posterior, bayestestR, ragg)
options(brms.backend = "cmdstanr")

dat <- readr::read_csv("BaseballDecade.csv", na = "NA",
                       locale = locale(encoding = "utf8"),
                       show_col_types = FALSE) %>%
  dplyr::filter(Year == "2020年度")
batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight)

fit1 <- brms::brm(weight ~ height, data = batter,
                  seed = 12345, chains = 4, iter = 2000,
                  refresh = 0, silent = 2)

post <- posterior::as_draws_df(fit1)

# 各パラメータを縦に並べ、x軸は自由スケールにする
lab <- c(b_Intercept = "切片", b_height = "傾き(身長の係数)", sigma = "誤差の標準偏差")
d <- post %>%
  as_tibble() %>%
  dplyr::select(b_Intercept, b_height, sigma) %>%
  tidyr::pivot_longer(everything(), names_to = "par", values_to = "val") %>%
  dplyr::mutate(par = factor(lab[par], levels = lab))

# 95%HDIを塗り分けるための下ごしらえ
hdis <- d %>%
  group_by(par) %>%
  summarise(lo = bayestestR::hdi(val, ci = 0.95)$CI_low,
            hi = bayestestR::hdi(val, ci = 0.95)$CI_high, .groups = "drop")

dens <- d %>%
  group_by(par) %>%
  group_modify(~{
    dd <- density(.x$val, n = 512)
    tibble(x = dd$x, y = dd$y)
  }) %>%
  left_join(hdis, by = "par") %>%
  mutate(inHDI = x >= lo & x <= hi)

p <- ggplot(dens, aes(x = x, y = y)) +
  geom_area(data = ~dplyr::filter(.x, inHDI), fill = "gray60") +
  geom_line(linewidth = 0.4) +
  facet_wrap(~par, ncol = 1, scales = "free") +
  labs(x = "パラメータの値", y = "密度") +
  theme_bw(base_size = 11) +
  theme(strip.background = element_rect(fill = "gray92"),
        panel.grid.minor = element_blank())

ggsave("../figures/29_bayesian_modeling/posterior_regression.png", p,
       width = 12, height = 12, units = "cm", dpi = 300, device = ragg::agg_png)
cat("完了\n")

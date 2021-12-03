rm(list = ls())
library(pacman)
pacman::p_load(tidyverse, posterior, bayesplot, RColorBrewer, ggthemes, patchwork)
color_scheme_set("brightblue")
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
theme_set(theme(text = element_text(family = "HiraKakuProN-W3")))
update_geom_defaults("text", list(family = "HiraKakuProN-W3"))
library(cmdstanr)

# map推定値 ------------------------------------------------------------------

map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}


library(cmdstanr)
library(tidyverse)
library(posterior)
library(patchwork)
library(bayestestR)

model <- cmdstanr::cmdstan_model("chap26.stan")
data <- list(N = 21, Y = c(rep(1, 3), rep(0, 18)))
fit <- model$sample(data = data, iter_sampling = 500000, parallel_chains = 4, chains = 4)
fit <- fit$draws() %>% as_draws_df()

library(polspline) # this package can be installed from within R
fit.posterior <- logspline(fit$theta)
val_hdi <- bayestestR::hdi(fit$theta, ci = 0.75)
val_eti <- bayestestR::eti(fit$theta, ci = 0.75)
df_eti <- fit %>%
  dplyr::filter(theta >= val_eti$CI_low & theta <= val_eti$CI_high) %>%
  dplyr::mutate(y = dlogspline(theta, fit.posterior))
df_hdi <- fit %>%
  dplyr::filter(theta >= val_hdi$CI_low & theta <= val_hdi$CI_high) %>%
  dplyr::mutate(y = dlogspline(theta, fit.posterior))

# 投影資料用の図版
pointEst <- fit %>%
    summarise(
        EAP = mean(theta),
        MED = median(theta),
        L50 = quantile(theta, prob = 0.25),
        U50 = quantile(theta, prob = 0.75),
        L95 = quantile(theta, prob = 0.025),
        U95 = quantile(theta, prob = 0.975)
    ) %>%
    distinct() %>%
    mutate(MAP = map_estimation(fit$theta)) %>%
    mutate(HDI = hdi(fit$theta))
pointEst

g <- fit %>%
    ggplot(aes(x = theta)) +
    geom_density() +
    geom_vline(xintercept = pointEst$EAP, lty = 2, color = palette()[3],lwd=2)+
    geom_vline(xintercept = pointEst$MAP, lty = 2, color = palette()[4],lwd=2)+
    geom_vline(xintercept = pointEst$MED, lty = 2, color = palette()[2],lwd=2)+
    geom_segment(
        data = pointEst, aes(x = 0.0520, xend = 0.349, y = 0.5, yend = 0.5),
        arrow = arrow(ends = "both", angle = 90, length = unit(.2, "cm")), color = palette()[6],lwd=2
    ) +
    geom_segment(
        data = pointEst, aes(x = 0.0395, xend = 0.327, y = 0.3, yend = 0.3),
        arrow = arrow(ends = "both", angle = 90, length = unit(.2, "cm")), color = palette()[1],lwd=2
    )


g

# ETI
g1 <- ggplot(fit, aes(x = theta)) +
  geom_density() +
  xlim(0, 0.5) +
  xlab("") +
  ggtitle("75% ETI: [0.09, 0.27]") +
  geom_ribbon(data = df_eti, mapping = aes(x = theta, ymax = y, ymin = 0), fill = palette()[2], alpha = 0.3)
# HDI
g2 <- ggplot(fit, aes(x = theta)) +
  geom_density() +
  xlim(0, 0.5) +
  xlab("") +
  ggtitle("75% HDI: [0.07, 0.24]") +
  geom_ribbon(data = df_hdi, mapping = aes(x = theta, ymax = y, ymin = 0), fill = palette()[3], alpha = 0.3)

g <- g1 / g2
plot(g)
ggsave(g, filename = "../images/text26/Rplot26_01.png", dpi = 600, width = 16, height = 9)
g


# 課題
data <- list(N = 21, Y = c(rep(1, 2), rep(0, 19)))
fit <- model$sample(data = data, iter_sampling = 500000, parallel_chains = 4, chains = 4)
fit <- fit$draws() %>% as_draws_df()
pointEst <- fit %>%
  summarise(
    EAP = mean(theta),
    MED = median(theta),
    L50 = quantile(theta, prob = 0.25),
    U50 = quantile(theta, prob = 0.75),
    L95 = quantile(theta, prob = 0.025),
    U95 = quantile(theta, prob = 0.975)
  ) %>%
  distinct() %>%
  mutate(MAP = map_estimation(fit$theta)) %>%
  mutate(HDI = hdi(fit$theta))
pointEst

g <- fit %>%
  ggplot(aes(x = theta)) +
  geom_density() +
  geom_vline(xintercept = pointEst$EAP, lty = 2, color = palette()[3]) + annotate("text",x=pointEst$EAP,y=4,label="A",size=8)+
  geom_vline(xintercept = pointEst$MAP, lty = 2, color = palette()[4]) + annotate("text",x=pointEst$MAP,y=3,label="B",size=8)+
  geom_vline(xintercept = pointEst$MED, lty = 2, color = palette()[2]) + annotate("text",x=pointEst$MED,y=2,label="C",size=8)+
  geom_segment(
    data = pointEst, aes(x = 0.0167, xend = 0.265, y = 0.7, yend = 0.7),
    arrow = arrow(ends = "both", angle = 90, length = unit(.2, "cm")), color = palette()[6]
  ) + annotate("text",x=pointEst$EAP+0.05,y=0.8,label="D", color = palette()[6],size=8)+
  geom_segment(
    data = pointEst, aes(x = 0.0290, xend = 0.291, y = 0.5, yend = 0.5),
    arrow = arrow(ends = "both", angle = 90, length = unit(.2, "cm")), color = palette()[1]
  )+ annotate("text",x=pointEst$EAP+0.1,y=0.6,label="E", color = palette()[1],size=8)

ggsave(g, filename = "../images/text26/kadai.png", dpi = 600, width = 8, height = 6)
g

library(rstan)
library(tidyverse)
library(brms)
library(bayesplot)
set.seed(12345)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
dat <- matrix(c(
  10, 5, 9,
  9, 4, 5,
  4, 2, 3,
  7, 3, 5
), byrow = T, ncol = 3) %>%
  data.frame() %>%
  rownames_to_column() %>%
  rename(ID = rowname) %>% 
  rename(Time1 = X1, Time2 = X2, Time3 = X3)

dat %>% xtable::xtable(type="latex",digit=0,caption="Within Data Example",label="tbl::22_05")%>% print(include.rownames=FALSE)


dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>% 
  dplyr::rename(Session = key)-> dataSet


# # ANOVA Form
# # result.Within <- brm(val ~ 0 + Session + (1 | ID), data = dataSet)
# 
# # Form 2
# result.Within <- brm(val ~ Session + (1 | ID), data = dataSet)
# 
# result.Within
# plot(result.Within)
# marginal_effects(result.Within)

# データは図にする ----------------------------------------------------------------

old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  ggplot(aes(x = key, y = val)) + geom_point() +
  theme(text = element_text(size = 15), legend.position = "bottom") +
  ylab("抑うつ度スコア") + xlab("測定時期")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") +
  theme(text = element_text(size = 15), legend.position = "bottom")
ggsave(filename = "Rplot22_03.png", dpi = 600, width = 6, height = 4)

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  dplyr::filter(ID == 1) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") + ylim(2, 10) +
  theme(text = element_text(size = 15), legend.position = "none")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  dplyr::filter(ID == 2) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point(color = "#7CAE00") +
  geom_line(color = "#7CAE00") +
  ylab("抑うつ度スコア") + xlab("測定時期") + ylim(2, 10) +
  theme(text = element_text(size = 15), legend.position = "bottom")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  dplyr::filter(ID == 2 | ID == 1) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") + ylim(2, 10) +
  geom_hline(yintercept = 8) + geom_hline(yintercept = 6) +
  theme(text = element_text(size = 15), legend.position = "none")


dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  dplyr::filter(ID == 2 | ID == 1) %>%
  dplyr::mutate(val = if_else(ID == 1, val - 1, val + 1)) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") + ylim(2, 10) +
  geom_hline(yintercept = 7) +
  theme(text = element_text(size = 15), legend.position = "none")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") +
  geom_hline(yintercept = 8, alpha = 0.5, color = "#F8766D") +
  geom_hline(yintercept = 6, alpha = 0.5, color = "#7CAE00") +
  geom_hline(yintercept = 3, alpha = 0.5, color = "#00BFC4") + 
  geom_hline(yintercept = 5, alpha = 0.5, color = "#C77CFF") +
  geom_hline(yintercept = 5.5,color="#000000")+
  theme(text = element_text(size = 15), legend.position = "bottom")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  dplyr::mutate(val = if_else(ID == 1, val - 2.5, 
                              if_else(ID==2, val-0.5,
                                      if_else(ID==3,val+2.5,val+0.5)))) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) + geom_point() + geom_line() +
  ylab("抑うつ度スコア") + xlab("測定時期") +
  theme(text = element_text(size = 15), legend.position = "bottom")

dat %>%
  tidyr::gather(key, val, -ID, factor_key = TRUE) %>%
  ggplot(aes(x = key, y = val, group = ID, color = ID)) +
  ylab("抑うつ度スコア") + xlab("測定時期") + ylim(2, 10) +
  geom_hline(yintercept = 8, alpha = 0.5, color = "#F8766D") +
  geom_hline(yintercept = 6, alpha = 0.5, color = "#7CAE00") +
  geom_hline(yintercept = 3, alpha = 0.5, color = "#00BFC4") + 
  geom_hline(yintercept = 5, alpha = 0.5, color = "#C77CFF") +
  theme(text = element_text(size = 15), legend.position = "bottom")

dat %>% pivot_longer(-ID) %>%  xtable::xtable(type="latex",digit=0,caption="効果と個人差，誤差",label="tbl::22_06")%>% print(include.rownames=FALSE)

dat[,-1] %>% anovakun("sA",3)

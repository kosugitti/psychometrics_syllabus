rm(list=ls())
library(tidyverse)
set.seed(20200911)
source("anovakun_485.txt")
N <- 3
mu <- 10
eA <- 0
eB <- 1
INT <- 2
sig <- 1
A11 <- rnorm(N, mu - eA + eB + INT, sig) %>% round()
A12 <- rnorm(N, mu - eA - eB - INT, sig) %>% round()
A21 <- rnorm(N, mu + eA + eB - INT, sig) %>% round()
A22 <- rnorm(N, mu + eA - eB + INT, sig) %>% round()
df_example <- data.frame(
  温度 = rep(c(rep(1, N * 2), rep(2, N * 2))) %>% factor(labels = c("Hot", "Cold")),
  メーカー = rep(rep(1:2, each = N), 2) %>% factor(labels = c("銘柄A", "銘柄B")),
  評価 = c(A11, A12, A21, A22)
) %>% 
  rowid_to_column("通し番号") %>% 
  dplyr::mutate(群での番号 = rep(1:3,4)) %>% 
  dplyr::select(通し番号,群での番号,温度,メーカー,評価)

df_example$評価 %>% mean

df_example %>% xtable::xtable(type="latex",digit=0,caption="二要因のデータ例",label="tbl::22_01") %>% 
  print(include.rownames=FALSE)

df_example %>% dplyr::select(-群での番号) %>% anovakun("ABs",2,2,long=T)

aov(評価~温度*メーカー,data=df_example) %>% summary() %>% xtable::xtable(type="latex",digit=3,caption="ANOVA Table",label="tbl::22_04")


df_example %>% ggplot(aes(x = 温度, y = 評価, color = メーカー, fill = メーカー)) +
  stat_summary(fun = mean, geom = "bar", position = "dodge") +
#  geom_hline(yintercept = mean(df_example$評価)) + ylim(0, 15) +
  theme(text = element_text(family = "HiraKakuProN-W3"))
ggsave(filename = "Rplot22_01.png", dpi = 600, width = 6, height = 4)



df_example %>% ggplot(aes(x = 温度, y = 評価, fill =温度)) +
  stat_summary(fun = mean, geom = "bar") +
  theme(legend.position = "bottom", text = element_text(family = "HiraKakuProN-W3")) +
  geom_hline(yintercept = mean(df_example$評価)) + ylim(0, 15) -> g1
df_example %>% ggplot(aes(x = メーカー, y = 評価, fill = メーカー)) +
  stat_summary(fun = mean, geom = "bar") +
  theme(legend.position = "bottom", text = element_text(family = "HiraKakuProN-W3")) +
  geom_hline(yintercept = mean(df_example$評価)) + ylim(0, 15) -> g2
gridExtra::grid.arrange(g1, g2, nrow = 1) -> g3

ggsave(g3,filename = "Rplot22_02.png", dpi = 600, width = 8, height = 4)

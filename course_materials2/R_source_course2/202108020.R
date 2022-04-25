rm(list = ls())
library(tidyverse)
library(gridExtra)
library(colorBlindness)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
scale_fill_manual(values = colorBlindness::Blue2Orange10Steps)
set.seed(0820)
## 青木先生のサイトで確認
source("http://aoki2.si.gunma-u.ac.jp/R/src/likert.R", encoding = "euc-jp")

N <- 5000
Y1 <- rnorm(N, 0, 1)
X1 <- cut(Y1, breaks = 7, labels = c(
  "全く当てはまらない", "あまり当てはまらない", "やや当てはまらない", "どちらとも言えない",
  "やや当てはまる", "かなり当てはまる", "全く当てはまる"
), right = FALSE, include.lowest = TRUE) %>% transform()


## 天井
Y2 <- rnorm(N, 2, 1)
X2 <- cut(Y2, breaks = c(-7, -1, -0.7, -0.5, 0, 1, 2, 7), labels = c(
  "全く当てはまらない", "あまり当てはまらない", "やや当てはまらない", "どちらとも言えない",
  "やや当てはまる", "かなり当てはまる", "全く当てはまる"
), right = FALSE, include.lowest = TRUE) %>% transform()

## 床
Y3 <- rnorm(N, -2, 1)
X3 <- cut(Y3, breaks = c(-7, -2, -1, 0, 0.5, 0.7, 1, 7), labels = c(
  "全く当てはまらない", "あまり当てはまらない", "やや当てはまらない", "どちらとも言えない",
  "やや当てはまる", "かなり当てはまる", "全く当てはまる"
), right = FALSE, include.lowest = TRUE) %>% transform()

## 二峰

Y4a <- rnorm(N / 2, 3, 1)
Y4b <- rnorm(N / 2, -3, 1)
Y4 <- c(Y4a, Y4b)
X4 <- cut(Y4, breaks = c(-7, -2.65, -2.14, -1.71, -1.07, 0.17, 2.88, 7), labels = c(
  "全く当てはまらない", "あまり当てはまらない", "やや当てはまらない", "どちらとも言えない",
  "やや当てはまる", "かなり当てはまる", "全く当てはまる"
), right = FALSE, include.lowest = TRUE) %>% transform()

X1$group <- "普通"
X2$group <- "天井"
X3$group <- "床"
X4$group <- "二峰"

bind_rows(X1, X2, X3, X4) %>%
  group_by(group, X_data) %>%
  summarise(n = n()) %>%
  distinct() %>%
  ungroup() %>%
  mutate(group = as.factor(group) %>% fct_relevel("普通", "天井", "床")) %>%
  ggplot(aes(x = X_data, y = n, fill = X_data)) +
  geom_bar(stat = "identity") +
  xlab("") +
  ylab("count") +
  facet_wrap(~group) +
  scale_fill_manual(values = Blue2Orange10Steps[7:1]) +
  theme(legend.position = "none")

X1$X_data %>%
  table() %>%
  likert() %>%
  round()
X2$X_data %>%
  table() %>%
  likert() %>%
  round()
X3$X_data %>%
  table() %>%
  likert() %>%
  round()
X4$X_data %>%
  table() %>%
  likert() %>%
  round()



library(psych)
sampledata <- bfi[, 1:25]
## 通常の因子分析
psych::fa(sampledata, nfactors = 5)
## 相関係数を変えて
psych::fa(sampledata, nfactors = 5, cor = "poly")
## IRT的表現をするなら
result <- psych::irt.fa(sampledata, nfactors = 5)
result$irt
result$fa

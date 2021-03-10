rm(list=ls())
library(tidyverse)
library(gridExtra)
library(colorBlindness)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
scale_fill_manual(values=colorBlindness::Blue2Orange10Steps)
set.seed(12345)
N <- 500
Y <- rnorm(N, 0, 1)
X <- cut(Y, breaks = 7, labels = c(
  "全く当てはまらない", "あまり当てはまらない", "やや当てはまらない", "どちらとも言えない",
  "やや当てはまる", "かなり当てはまる", "全く当てはまる"
), right = FALSE, include.lowest = TRUE)
table(X)
g1 <- X %>%
  as_tibble() %>% 
  group_by(value) %>% 
  summarise(n=n()) %>% 
  ggplot(aes(x = value,y=n,fill=value)) +
  geom_bar(stat="identity")+
  xlab("") +ylab("count")+
  scale_fill_manual(values=Blue2Orange10Steps[7:1])+ theme(legend.position = 'none')
g1

limitRange <- function(fun, min, max) {
  function(x) {
    y <- fun(x)
    y[x < min | x > max] <- NA
    return(y)
  }
}

threshold <- cumsum(table(X) / N) %>% as.vector() %>% qnorm()

g2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) + ylab("probability density")+
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) +
  xlab("") +
  stat_function(
    fun = limitRange(dnorm, -4, threshold[7]),
    geom = "area", fill = Blue2Orange10Steps[1]
  )+
  stat_function(
    fun = limitRange(dnorm, -4, threshold[6]),
    geom = "area", fill = Blue2Orange10Steps[2]
  )+
  stat_function(
    fun = limitRange(dnorm, -4, threshold[5]),
    geom = "area", fill = Blue2Orange10Steps[3]
  )+
  stat_function(
    fun = limitRange(dnorm, -4, threshold[4]),
    geom = "area", fill = Blue2Orange10Steps[4]
  )+
  stat_function(
    fun = limitRange(dnorm, -4, threshold[3]),
    geom = "area", fill = Blue2Orange10Steps[5]
  ) +
  stat_function(
    fun = limitRange(dnorm, -4, threshold[2]),
    geom = "area", fill = Blue2Orange10Steps[6]
  ) +
  stat_function(
      fun = limitRange(dnorm, -4, threshold[1]),
      geom = "area", fill = Blue2Orange10Steps[7]
  ) +
  geom_segment(aes(x=threshold[3],xend=-Inf,y=dnorm(threshold[3]),yend=dnorm(threshold[3])),linetype=3)+
  geom_segment(aes(x=threshold[2]-0.05,xend=-Inf,y=dnorm(threshold[5]),yend=dnorm(threshold[5])),linetype=3)
g2

g <- grid.arrange(g1, g2)


ggsave(g, filename = "../images/chapter02/Rplot02_01.png", dpi = 600, width = 12, height = 8)


rbind(table(X),# 度数
      table(X)/N, # 相対度数
      cumsum(table(X)/N), # 累積相対度数
      qnorm(cumsum(table(X)/N)), # 累積相対度数の確率点
      dnorm(qnorm(cumsum(table(X)/N))) # 累積相対度数の確率密度
      ) %>%  xtable::xtable()

## 青木先生のサイトで確認
source("http://aoki2.si.gunma-u.ac.jp/R/src/likert.R", encoding="euc-jp")
likert(table(X))

cum <- cumsum(table(X)/N) #累積相対頻度
c(0,cum[-7])
(dnorm(qnorm(c(0,cum[-7])))-dnorm(qnorm(cum)))/(table(X)/N) #累積相対頻度の確率密度(五段目)を引き算して，相対頻度(二段目)でわる
c1 <- (0.00-0.07)/0.03
c2 <- (0.07-0.20)/0.09
c3 <- (0.20-0.37)/0.22
c4 <- (0.37-0.38)/0.28
c5 <- (0.38-0.20)/0.25
c6 <- (0.20-0.08)/0.08
c7 <- (0.08-0.00)/0.03
c(c1,c2,c3,c4,c5,c6,c7)/0.8

mean(c1-c2,c2-c3,c3-c4,c4-c5,c5-c6,c6-c7)

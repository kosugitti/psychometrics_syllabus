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



df_example %>% ggplot(aes(x = 温度, y = 評価, fill =温度))+
  stat_summary(fun = mean, geom = "bar") +
  theme(legend.position = "bottom", text = element_text(family = "HiraKakuProN-W3")) +
  scale_fill_manual(values = c("#ff9900", "#339900")) +
  geom_hline(yintercept = mean(df_example$評価)) + ylim(0, 15) -> g1
df_example %>% ggplot(aes(x = メーカー, y = 評価, fill = メーカー)) +
  stat_summary(fun = mean, geom = "bar") +
  theme(legend.position = "bottom", text = element_text(family = "HiraKakuProN-W3")) +
  geom_hline(yintercept = mean(df_example$評価)) + ylim(0, 15) -> g2
gridExtra::grid.arrange(g1, g2, nrow = 1) -> g3

ggsave(g3,filename = "../images/22_anovaOnR/Rplot22_02.png", dpi = 600, width = 8, height = 4)


interaction.plot(
    x.factor=df_example$温度,       # x軸の変数
    trace.factor=df_example$メーカー,     # 線で描き分ける変数
    response=df_example$評価,       # y軸の変数
    fun=mean,                # 平均値を図示するならmeanを指定
    type="b",                # 点と線で表すグラフを指定
    legend=TRUE,             # 凡例あり
#    ylim=c(80, 94),          # y軸の範囲指定
    xlab = "Class",          # x軸タイトル
    ylab = "mean of Score",  # y軸タイトル
    trace.label = "Sex",     # 線で描き分ける変数タイトル（凡例に出る)
    pch=c(19, 21),           # 丸の記号の種類
    cex.lab=1.2              # 軸タイトルの文字サイズ
)

g1 <- df_example %>% 
    ggplot() +
    aes(x = 温度, color = メーカー, group = メーカー, y = 評価) +
    stat_summary(fun = mean, geom = "point",lwd=3) +
    stat_summary(fun = mean, geom = "line",lwd=2) +
    ylim(5,13)
ggsave(g1,filename = "../images/22_anovaOnR/Rplot22_05.png", dpi = 600, width = 8, height = 4)

g1+ geom_segment(aes(x=1,xend=1,y=12,yend=12),lty=2,color=2) +
    geom_segment(aes(x=1,xend=1,y=7,yend=7),lty=2,color=3)+
    geom_segment(aes(x=1,xend=2,y=11,yend=11),lty=2,color=3) + 
    geom_segment(aes(x=1,xend=2,y=9,yend=9),lty=2,color=2)

g1 <- g1 + geom_point(aes(x=1.5,y=(12+9)/2),color="#f8766D",size=4)+
    geom_point(aes(x=1.5,y=(11+7)/2),color="#00BFC4",size=4)+
    geom_segment(aes(x=1.5,xend=1.5,y=(12+9)/2,yend=(11+7)/2),lty=2,color=1)

g2 <- df_example %>% 
    ggplot() +
    aes(x = 温度, color = メーカー, group = メーカー, y = 評価) +
    stat_summary(fun = mean, geom = "point",lwd=3) +
    stat_summary(fun = mean, geom = "line",lwd=2) + 
    stat_summary(fun = mean, geom = "point",lwd=3) + ylim(5,13) +
    geom_segment(aes(x=1,xend=1,y=12,yend=7),lty=2,color=1) + 
    geom_segment(aes(x=2,xend=2,y=11,yend=9),lty=2,color=1) + 
    geom_point(aes(x=1,y=9.5),size=3,color="#ff9900") + 
    geom_point(aes(x=2,y=10),size=3,color="#339900")

gridExtra::grid.arrange(g2, g1, nrow = 1) -> g3


ggsave(g3,filename = "../images/22_anovaOnR/Rplot22_04.png", dpi = 600, width = 8, height = 4)



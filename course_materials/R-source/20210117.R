rm(list=ls())
library(tidyverse)
sample <- read.csv("baseball2020.csv", fileEncoding = "utf-8", header = TRUE)
weight <- read.csv("SimpleWeight.csv") %>% 
    mutate(date = paste0(year,"/",month,"/",day)) %>% 
    mutate(date = lubridate::ymd(date))
old = theme_set(theme_gray(base_family="HiraKakuProN-W3"))
# 散布図
g1 <- ggplot(sample, aes(x = height, y = weight, colour = team, fill = team))+ geom_point()
# ボックスプロット
g2 <- sample %>% select(position,height) %>% na.omit %>% 
    ggplot(aes(x= position,y=height,fill=position))+geom_boxplot()
# バイオリンプロット
g3 <- sample %>% select(position,height) %>% na.omit %>% 
    ggplot(aes(x= position,y=height,fill=position))+geom_violin(alpha=0.7)+geom_jitter(alpha=0.3)
# バープロット
g4 <- sample %>% select(height,position) %>% na.omit %>% 
    group_by(position) %>% 
    summarise(mean = mean(height), sd= sd(height)) %>% 
    ggplot(aes(x=position,y=mean,fill=position))+
    geom_bar(stat="identity",alpha=0.7)+ylim(0,200)+
    geom_errorbar(aes(ymin=mean-sd,ymax=mean+sd),width=.5)
# ヒストグラム
g5 <- sample %>% ggplot(aes(x=height))+geom_histogram(binwidth = 1)

g6 <- ggplot(sample, aes(x = height, y = weight, colour = team, fill = team,shape=position))+ geom_point()+
    xlab("height") + ylab("weight")+ facet_wrap(~team)

# 折れ線グラフ
g7 <- weight %>% ggplot(aes(x=date,y=weight))+geom_point()+geom_line()

gX <- gridExtra::grid.arrange(g1,g2, g3, g4,g5,layout_matrix = rbind(c(1, 2),
                                                               c(3, 4),5))

ggsave(gX,filename = "Rplot03_01.png", dpi = 600, width = 12, height = 12)

ggsave(g6,filename = "Rplot03_02.png", dpi = 600, width = 12, height = 6)

ggsave(g7,filename = "Rplot03_03.png", dpi = 600, width = 12, height = 6)

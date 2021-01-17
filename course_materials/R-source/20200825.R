library(tidyverse)
library(ggplot2)
library(gridExtra)
set.seed(12345)

ggplot(data.frame(x=c(-4, 4)), aes(x=x)) + stat_function(fun = dnorm,color="blue") -> g0

N <- 100
X <- rnorm(N,0,1) %>% transform
X %>% ggplot(aes(x=X_data))+geom_histogram()+geom_vline(xintercept = mean(X$X_data),color='red')+xlim(-4,4) -> g1
N <- 100
X <- rnorm(N,0,1) %>% transform
X %>% ggplot(aes(x=X_data))+geom_histogram()+geom_vline(xintercept = mean(X$X_data),color='red')+xlim(-4,4) -> g2
N <- 100
X <- rnorm(N,0,1) %>% transform
X %>% ggplot(aes(x=X_data))+geom_histogram()+geom_vline(xintercept = mean(X$X_data),color='red') +xlim(-4,4)-> g3

ggplot(data.frame(x=c(-4, 4)), aes(x=x)) + stat_function(fun = dnorm,args = list(mean=0,sd=(1/sqrt(N))),color="blue") -> g4

layout <- rbind(c(1,1,1), c(2,3,4))
gridExtra::grid.arrange(g0,g1,g2,g3, layout_matrix = layout)
g4

x <- rnorm(9,50,10) %>% round(2) %>% print
mean(x)
sd(x)
t.test(x)
# t分布の描画 ------------------------------------------------------------------

ggplot(data.frame(x=c(-4, 4)), aes(x=x)) + 
    stat_function(fun = dt,args = list(df=1), aes(colour = "自由度1")) +
    stat_function(fun = dt,args = list(df=3),aes(colour = "自由度3")) +
    stat_function(fun = dt,args = list(df=7),aes(colour = "自由度7")) +
    stat_function(fun = dt,args = list(df=30),aes(colour = "自由度30")) + 
    stat_function(fun = dnorm, aes(colour = "標準正規分布"),lty=2) +
    scale_colour_manual("自由度など", values = c("red", "blue", "green", "orange","black")) + 
    theme_gray(base_family = "HiraKakuPro-W3")
ggsave(filename = "Rplot17_01.png", dpi = 600, width = 8, height = 4)

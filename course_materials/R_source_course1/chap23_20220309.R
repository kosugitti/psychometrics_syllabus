rm(list=ls())
library(tidyverse)
library(gridExtra)

# 一様分布 --------------------------------------------------------------------


ggplot(data=data.frame(X=c(0,300)),aes(x=X))+xlab("theta")+ylab("Probability")+
    stat_function(fun=dunif,args = list(min=0,max=300))+ylim(0,0.01)


# ３つのデータポイントでの尤度 ----------------------------------------------------------


datset <- c(165,173,182)
g1 <- ggplot(data=data.frame(X=c(100,200)),aes(x=X))+
    stat_function(fun=dnorm,args = list(mean=170,sd=10),color=palette()[2])+
    geom_segment(aes(x = datset[1], xend = datset[1], y = 0, yend = dnorm(datset[1], 170, 10)), lty = 2) +
    geom_segment(aes(x = datset[2], xend = datset[2], y = 0, yend = dnorm(datset[2], 170, 10)), lty = 2) +
    geom_segment(aes(x = datset[3], xend = datset[3], y = 0, yend = dnorm(datset[3], 170, 10)), lty = 2) +
    geom_point(data=data.frame(X=datset,Y=rep(0,3)),aes(x=X,y=Y),size=3,color="blue") + 
    annotate("text", x=162,   y=0.001, label="165cm")+
    annotate("text", x=170,   y=0.001, label="173cm")+
    annotate("text", x=180,   y=0.001, label="182cm")
ggsave(g1,filename = "../images/23_likelihood/Rplot_ml1.png", dpi = 600, width = 12,height = 6)


g2 <- ggplot(data=data.frame(X=c(100,200)),aes(x=X))+
    stat_function(fun=dnorm,args = list(mean=150,sd=10),color=palette()[3])+
    geom_segment(aes(x = datset[1], xend = datset[1], y = 0, yend = dnorm(datset[1], 150, 10)), lty = 2) +
    geom_segment(aes(x = datset[2], xend = datset[2], y = 0, yend = dnorm(datset[2], 150, 10)), lty = 2) +
    geom_segment(aes(x = datset[3], xend = datset[3], y = 0, yend = dnorm(datset[3], 150, 10)), lty = 2) +
    geom_point(data=data.frame(X=datset,Y=rep(0,3)),aes(x=X,y=Y),size=3,color="blue")+
    annotate("text", x=162,   y=0.001, label="165cm")+
    annotate("text", x=170,   y=0.001, label="173cm")+
    annotate("text", x=180,   y=0.001, label="182cm")



g3 <- ggplot(data=data.frame(X=c(100,200)),aes(x=X))+
    stat_function(fun=dnorm,args = list(mean=180,sd=10),color=palette()[4])+
    geom_segment(aes(x = datset[1], xend = datset[1], y = 0, yend = dnorm(datset[1], 180, 10)), lty = 2) +
    geom_segment(aes(x = datset[2], xend = datset[2], y = 0, yend = dnorm(datset[2], 180, 10)), lty = 2) +
    geom_segment(aes(x = datset[3], xend = datset[3], y = 0, yend = dnorm(datset[3], 180, 10)), lty = 2) + 
    geom_point(data=data.frame(X=datset,Y=rep(0,3)),aes(x=X,y=Y),size=3,color="blue")+
    annotate("text", x=162,   y=0.001, label="165cm")+
    annotate("text", x=170,   y=0.001, label="173cm")+
    annotate("text", x=180,   y=0.001, label="182cm")

g1 <- grid.arrange(g2,g3)
ggsave(g1,filename = "../images/23_likelihood/Rplot_ml2.png", dpi = 600, width = 12,height = 6)

# 尤度関数
L_func2 <- function(x){
    tmp = dnorm(c(165,173,182),x,10)
    tmp = prod(tmp)
    return(tmp)
}
# 対数尤度関数
LL_func <- function(x){
    tmp = sum(log(dnorm(c(165,173,182),x,10)))
    return(tmp)
}

options(scipen=100)
dat <- data.frame(X=100:200) %>% 
    rowwise() %>% 
    mutate(L = L_func2(X),LL=LL_func(X)) 

g1 <- dat %>% ggplot(aes(x=X,y=L))+geom_line()+ylab("Likelihood")
g2 <- dat %>% ggplot(aes(x=X,y=LL))+geom_line()+ylab("Log-Likelihood")
g <- grid.arrange(g1,g2,ncol=1)
ggsave(g,filename = "../images/23_likelihood/Rplot_ml3.png", dpi = 600, width = 12,height = 6)






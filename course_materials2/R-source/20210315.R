rm(list=ls())
library(tidyverse)
library(colorBlindness)
old = theme_set(theme_gray(base_family="HiraKakuProN-W3"))
scale_fill_manual(values=colorBlindness::Blue2Orange10Steps)
inv_logit <- function(x){
    1/(1+exp(-1.7*x))
}

twoParameters <- function(x,a,b){
    1/(1+exp(-1.7*a*(x-b)))
}

threeParameters <- function(x,a=1,b=0,c=0){
    c+(1-c)/(1+exp(-1.7*a*(x-b)))
}


p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
g1 <- p + stat_function(fun = dnorm)+ylab("prob")+xlab("theta")
g2 <- p + stat_function(fun = pnorm)+ylab("prob")+xlab("theta")+ 
    stat_function(fun = inv_logit,lty=2,color="#0054FF")
g <- gridExtra::grid.arrange(g1,g2)
ggsave(g, filename = "../images/chapter04/Rplot04_01.png", dpi = 600, width = 12, height = 8)

###
set.seed(20210316)
g <- rnorm(1000,0,1) %>% data.frame %>% 
    mutate(class = cut(.,breaks=5,labels=c("LL","ML","M","LH","HH"))) %>% 
    mutate(prob1 = twoParameters(x=.,a=1,b=0),
           prob2 = twoParameters(x=.,a=1,b=2.5),
           prob3 = twoParameters(x=.,a=1,b=-2.5),
           prob4 = twoParameters(x=.,a=-1,b=0)) %>% 
    rowwise() %>% 
    mutate(pass1 = rbinom(1,1,prob1),
           pass2 = rbinom(1,1,prob2),
           pass3 = rbinom(1,1,prob3),
           pass4 = rbinom(1,1,prob4)) %>% 
    group_by(class) %>% 
    summarise(Good = mean(pass1),
              Difficult = mean(pass2),
              Easy = mean(pass3),
              Bad = mean(pass4)) %>% 
    pivot_longer(-class) %>% 
    distinct() %>% 
    mutate(name = factor(name)) %>%
    mutate(name = fct_relevel(name,"Good","Easy","Difficult","Bad")) %>% 
    ggplot(aes(x=class,y=value,fill=class))+geom_bar(stat='identity') +
    facet_wrap(~name)+
    scale_fill_viridis_d()+xlab("成績段階")+ylab("通過率")+
    theme(legend.position = 'none') 

ggsave(g, filename = "../images/chapter04/Rplot04_02.png", dpi = 600, width = 12, height = 8)
g


p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+ylab("prob")+xlab("theta")+
    stat_function(fun = function(x) threeParameters(x=x,a=1,b=0),lty=2)+
    stat_function(fun = function(x) threeParameters(x=x,a=1,b=-1),color=palette()[2])+
    stat_function(fun = function(x) threeParameters(x=x,a=1,b=1),color=palette()[4])
ggsave(p, filename = "../images/chapter04/Rplot04_03.png", dpi = 600, width = 12, height = 6)

p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+ylab("prob")+xlab("theta")+
    stat_function(fun = function(x) threeParameters(x=x,a=1,b=0),lty=2)+
    stat_function(fun = function(x) threeParameters(x=x,a=0.5,b=0),color=palette()[2])+
    stat_function(fun = function(x) threeParameters(x=x,a=1.5,b=0),color=palette()[4])
ggsave(p, filename = "../images/chapter04/Rplot04_04.png", dpi = 600, width = 12, height = 6)
p



rm(list=ls())
library(tidyverse)
library(colorBlindness)
library(gridExtra)
old = theme_set(theme_bw(base_family="HiraKakuProN-W3"))
scale_fill_manual(values=colorBlindness::Blue2Orange10Steps)
inv_logit <- function(x){
    1/(1+exp(-1.7*x))
}

twoParameters <- function(x,a,b){
    1/(1+exp(-1.7*a*(x-b)))
}

IRCCC_rev <- function(x,a,b){
    1-1/(1+exp(-1.7*a*(x-b)))
}

IRCCC <- function(x,a,b1,b2){
    1/(1+exp(-1.7*a*(x-b1))) - 1/(1+exp(-1.7*a*(x-b2)))
}


threeParameters <- function(x,a=1,b=0,c=0){
    c+(1-c)/(1+exp(-1.7*a*(x-b)))
}

IIC <- function(x,a,b){
    p =  1/(1+exp(-1.7*a*(x-b)))
    q = 1 - p
    ret = a^2 * p * q
    return(ret)
}

TIC <- function(x,a1,a2,a3,b1,b2,b3){
    p1 =  1/(1+exp(-1.7*a1*(x-b1)))
    q1 = 1 - p1
    p2 =  1/(1+exp(-1.7*a2*(x-b2)))
    q2 = 1 - p2
    p3 =  1/(1+exp(-1.7*a3*(x-b3)))
    q3 = 1 - p3
    ret1 = a1^2*p1*q1
    ret2 = a2^2*p2*q2
    ret3 = a3^2*p3*q3
    ret = ret1+ret2+ret3
    return(ret)
}



p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
g1 <- p + stat_function(fun = dnorm)+ylab("prob")+xlab("theta")
g2 <- p + stat_function(fun = pnorm)+ylab("prob")+xlab("theta")+ 
    stat_function(fun = inv_logit,lty=2,color="#0054FF")
g <- gridExtra::grid.arrange(g1,g2)


p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")
g1 <- p + stat_function(fun = twoParameters, args=list(a=1,b=1),color=palette()[2])+
    stat_function(fun = twoParameters, args=list(a=0.8,b=-1),color=palette()[3])+
    stat_function(fun = twoParameters, args=list(a=1.2,b=2),color=palette()[4])+ylab("pass")
g2 <- p + stat_function(fun = IIC, args=list(a=1,b=1),color=palette()[2])+ 
    stat_function(fun = IIC, args=list(a=0.8,b=-1),color=palette()[3])+
    stat_function(fun = IIC, args=list(a=1.2,b=2),color=palette()[4])+ylab("Information")
g <- gridExtra::grid.arrange(g1,g2)
ggsave(g, filename = "../images/chapter05/Rplot05_01.png", dpi = 600, width = 12, height = 6)

p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")
g1 <- p + stat_function(fun = TIC, args=list(a1=1,a2=0.8,a3=1.2,b1=1,b2=-1,b3=2))+ylab("Information")+
    stat_function(fun = IIC, args=list(a=1,b=1),color=palette()[2],lty=2,alpha=0.5)+ 
    stat_function(fun = IIC, args=list(a=0.8,b=-1),color=palette()[3],lty=2,alpha=0.5)+
    stat_function(fun = IIC, args=list(a=1.2,b=2),color=palette()[4],lty=2,alpha=0.5)+ylab("Information")
g1
ggsave(g1, filename = "../images/chapter05/Rplot05_02.png", dpi = 600, width = 12, height = 6)

limitRange <- function(fun, min, max) {
    function(x) {
        y <- fun(x)
        y[x < min | x > max] <- NA
        return(y)
    }
}

p1 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")+ylab("prob.")+
    stat_function(fun = dnorm) + 
    geom_segment(x=1,xend=1,y=0,yend=dnorm(1),lty=2)+
    geom_segment(x=-1,xend=-1,y=0,yend=dnorm(-1),lty=2)+
    stat_function(
        fun = limitRange(dnorm, -4, -1),
        geom = "area", fill = palette()[2],
        alpha=0.5
    )+
    stat_function(
    fun = limitRange(dnorm, -1, 1),
    geom = "area", fill = palette()[3],
    alpha=0.5
    ) +
    stat_function(
        fun = limitRange(dnorm, 1, 4),
        geom = "area", fill = palette()[4],
        alpha=0.5
    )+
    annotate("text",x=-3,y=0.1,label="当てはまらない",size=8,family="HiraKakuProN-W3")+
    annotate("text",x=2.5,y=0.1,label="当てはまる",size=8,family="HiraKakuProN-W3")+
    annotate("text",x=0,y=0.2,label="どちらでもない",size=8,family="HiraKakuProN-W3")
p2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")+ylab("prob.")+
    stat_function(fun=twoParameters, args=list(a=1, b=1),color=palette()[4])+
    stat_function(fun=IRCCC_rev, args=list(a=1, b=-1),color=palette()[2])+
    stat_function(fun=IRCCC,args=list(a=1,b1=-1,b2=1),color=palette()[3])
    
p2
g <- grid.arrange(p1,p2)
ggsave(g, filename = "../images/chapter05/Rplot05_03.png", dpi = 600, width = 12, height = 6)


p1 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")+ylab("prob.")+
    stat_function(fun=twoParameters, args=list(a=1, b=2),color=palette()[6])+
    stat_function(fun=IRCCC_rev, args=list(a=1, b=-2),color=palette()[2])+
    stat_function(fun=IRCCC,args=list(a=1,b1=-2,b2=-1),color=palette()[3])+
    stat_function(fun=IRCCC,args=list(a=1,b1=-1,b2=0.5),color=palette()[4])+
    stat_function(fun=IRCCC,args=list(a=1,b1=0.5,b2=1),color=palette()[5])
p2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))+xlab("theta")+
    stat_function(fun=twoParameters, args=list(a=1, b=2),color=palette()[6])+
    stat_function(fun=IRCCC_rev, args=list(a=1, b=-2),color=palette()[2])+
    stat_function(fun=IRCCC,args=list(a=1,b1=-2,b2=-1),color=palette()[3])+
    stat_function(fun=IRCCC,args=list(a=1,b1=-1,b2=1.3),color=palette()[4])

g <- grid.arrange(p1,p2)
ggsave(g, filename = "../images/chapter05/Rplot05_04.png", dpi = 600, width = 12, height = 6)





rm(list=ls())
library(tidyverse)
library(xtable)
library(stargazer)
set.seed(20200902)

# Within ------------------------------------------------------------------


N <- 10
X <- rnorm(N,20,5) %>% round
Y <- (X + rnorm(N,3,1) + rnorm(N,0,3)) %>% round

A <- matrix(c(X,Y,Y-X),byrow=T,ncol=N)
colnames(A) <- c("pre","post","diff")
xtable::xtable(A,type="latex",digit=0,caption="Pre-Post Design Data",label="tbl19::01")
t.test(Y,X,paired = T,alternative = "greater")

sd(X-Y)
mean(X-Y)

# Between ------------------------------------------------------------------

N <- 5
X <- rnorm(N,20,5) %>% round
Y <- rnorm(N,25,5) %>% round
data.frame(X,Y) %>% rowid_to_column() %>% pivot_longer(-rowid,names_to="condition") %>% 
    dplyr::select(condition,value) %>% 
    dplyr::mutate(condition =factor(condition,labels = c("control","experimental"))) %>% 
    arrange(condition) %>% 
    rowid_to_column("ID") -> A

xtable::xtable(A,type="latex",digit=0,caption="Between Design",label="tbl::19_02") %>% print(include.rownames=FALSE)

X <- A$value[1:5]
Y <- A$value[6:10]
mean(X)
mean(Y)
var(X)
var(Y)
(mean(X)-mean(Y))/sqrt((var(X)+var(Y))/N)
t.test(value~condition,data=A,var.equal=T)

sqrt((var(X)+var(Y))/N)-> bo
(mean(X)-mean(Y))/bo

library(ggplot2)
library(gridExtra)
limitRange <- function(fun,min, max) {
    function(x) {
        y <- fun(x,df=8)
        y[x < min  |  x > max] <- NA
        return(y)
    }
}
# t分布を塗りつぶす
p <- ggplot(data.frame(x=c(-4, 4)), aes(x=x))
p + stat_function(fun = dt,args=list(df=8)) +
    stat_function(fun = limitRange(dt,1.356, 4),
                  geom="area", fill="blue", alpha=0.2) -> g1

p + stat_function(fun = dt,args=list(df=8)) +
    stat_function(fun = limitRange(dt,1.356, 4),
                  geom="area", fill="blue", alpha=0.2)+
    stat_function(fun = limitRange(dt,-4, -1.356),
                  geom="area", fill="blue", alpha=0.2) -> g2



ggsave(grid.arrange(g1,g2),filename = "Rplot19_02.png", dpi = 600, width = 8, height = 4)





# シミュレーションの例 --------------------------------------------------------------
set.seed(12345)
result <- data.frame(x1=as.numeric(),x2=as.numeric(),iter=as.numeric())
for(i in 1:100){
    x1 <- rnorm(10,50,10)
    x2 <- rnorm(10,55,10)
    data.frame(x1,x2) %>% 
        dplyr::mutate(iter=i) -> tmp
    result <- bind_rows(result,tmp)
}
result %>% group_by(iter) %>% nest() %>% 
    mutate(ttest = purrr::map(data,~t.test(.$x1,.$x2,var.equal = T) %>% broom::tidy())) %>% 
    dplyr::select(ttest)  %>% 
    unnest(cols=c(ttest)) %>% 
    dplyr::select(statistic,p.value) %>% 
    dplyr::mutate(FLG = if_else(p.value<0.05,T,F)) %>% print -> tmp
tmp %>% head(10) %>% xtable()

xtable(tmp[1:10,2:4],type="latex",digit=3,caption="t検定を何度もやってみる",label="tbl::19_03") 

sum(tmp$FLG)/NROW(tmp)

set.seed(12345)
result <- data.frame(x1=as.numeric(),x2=as.numeric(),iter=as.numeric())
for(i in 1:100){
    x1 <- rnorm(10,50,10)
    x2 <- rnorm(10,60,10)
    data.frame(x1,x2) %>% 
        dplyr::mutate(iter=i) -> tmp
    result <- bind_rows(result,tmp)
}
result %>% group_by(iter) %>% nest() %>% 
    mutate(ttest = purrr::map(data,~t.test(.$x1,.$x2,var.equal = T) %>% broom::tidy())) %>% 
    dplyr::select(ttest)  %>% 
    unnest(cols=c(ttest)) %>% 
    dplyr::select(statistic,p.value) %>% 
    dplyr::mutate(FLG = if_else(p.value<0.05,T,F)) %>% print -> tmp
tmp %>% head(10) %>% xtable()
xtable(tmp[1:10,2:4],type="latex",digit=3,caption="t検定を何度もやってみる,
       その2",label="tbl::19_04") 


set.seed(12345)
result <- data.frame(x1=as.numeric(),x2=as.numeric(),iter=as.numeric())
for(i in 1:100){
    x1 <- rnorm(10,50,20)
    x2 <- rnorm(10,60,20)
    data.frame(x1,x2) %>% 
        dplyr::mutate(iter=i) -> tmp
    result <- bind_rows(result,tmp)
}
result %>% group_by(iter) %>% nest() %>% 
    mutate(ttest = purrr::map(data,~t.test(.$x1,.$x2,var.equal = T) %>% broom::tidy())) %>% 
    dplyr::select(ttest)  %>% 
    unnest(cols=c(ttest)) %>% 
    dplyr::select(statistic,p.value) %>% 
    dplyr::mutate(FLG = if_else(p.value<0.05,T,F)) %>% print -> tmp
tmp %>% head(10) %>% xtable()
xtable(tmp[1:10,2:4],type="latex",digit=3,caption="t検定を何度もやってみる，その3",label="tbl::19_05") 



ggplot(data.frame(x=c(0, 100)), aes(x=x)) + 
    stat_function(fun = dnorm,args = list(mean=40,sd=5), aes(colour = "平均40，SD5")) +
    stat_function(fun = dnorm,args = list(mean=60,sd=5), aes(colour = "平均60，SD5")) +
    theme(legend.position = 'none')+ guides(colour=FALSE)+xlab("")+ylab("")+
    scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    theme_gray(base_family = "HiraKakuPro-W3") -> g1

ggplot(data.frame(x=c(0, 100)), aes(x=x)) + 
    stat_function(fun = dnorm,args = list(mean=50,sd=30), aes(colour = "平均50，SD30")) +
    stat_function(fun = dnorm,args = list(mean=55,sd=30), aes(colour = "平均55，SD30")) +
    theme(legend.position = 'none')+ guides(colour=FALSE)+xlab("")+ylab("")+
    scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    theme_gray(base_family = "HiraKakuPro-W3") -> g2

ggplot(data.frame(x=c(0, 100)), aes(x=x)) + 
    stat_function(fun = dnorm,args = list(mean=40,sd=30), aes(colour = "平均40，SD5")) +
    stat_function(fun = dnorm,args = list(mean=60,sd=30), aes(colour = "平均60，SD5")) +
    theme(legend.position = 'none')+ guides(colour=FALSE)+xlab("")+ylab("")+
    scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    theme_gray(base_family = "HiraKakuPro-W3") -> g3

ggplot(data.frame(x=c(0, 100)), aes(x=x)) + 
    stat_function(fun = dnorm,args = list(mean=50,sd=5), aes(colour = "平均50，SD30")) +
    stat_function(fun = dnorm,args = list(mean=55,sd=5), aes(colour = "平均55，SD30")) +
    theme(legend.position = 'none')+ guides(colour=FALSE)+xlab("")+ylab("")+
    scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    theme_gray(base_family = "HiraKakuPro-W3") -> g4


g5 <- gridExtra::grid.arrange(g1,g4,ncol=1)
ggsave(g5,filename = "Rplot19_03.png", dpi = 600, width = 4, height = 4)
g5 <- gridExtra::grid.arrange(g1,g3,ncol=1)
ggsave(g5,filename = "Rplot19_04.png", dpi = 600, width = 4, height = 4)





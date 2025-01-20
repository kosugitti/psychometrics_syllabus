rm(list=ls())
set.seed(1029)
library(tidyverse)
source("http://riseki.php.xdomain.jp/index.php?plugin=attach&refer=ANOVA%E5%90%9B&openfile=anovakun_486.txt")
# 6.  とあるスナック菓子を三人のこどもそれぞれに買い与えたが，お菓子の長さに差があると言って喧嘩を始めた。
# 彼らの主張が妥当かどうか検証するために，それぞれの菓子袋から棒状のお菓子10本ずつをサンプリンングし，長さを測定したのが次の表\@ref(tab:anova1)である。
# 三つの菓子袋に含まれるお菓子の長さに差があると言って良いかどうか，統計的に検定しなさい。
# 検定統計量並びに効果量も報告すること。
n <- 4
x1 <- round(rnorm(n,10,3))
x2 <- round(rnorm(n,15,3))
x3 <- round(rnorm(n,12,3))
dat <- data.frame(id=1:(3*n),袋=c(rep("A",n),rep("B",n),rep("C",n)),長さ=c(x1,x2,x3)) %>% 
    mutate(全体平均=mean(長さ)) %>% 
    group_by(袋) %>% 
    mutate(群平均=mean(長さ)) %>% print %>% 
    ungroup() %>% 
    mutate(平均偏差=長さ-mean(長さ)) %>% print %>% 
    mutate(群の効果=群平均-mean(長さ)) %>% print %>% 
    mutate(誤差=長さ-(全体平均+群の効果)) %>% print %>% 
    mutate(平均偏差の二乗= 平均偏差^2,
                  群の効果の二乗=群の効果^2,
                  誤差の二乗=誤差^2)
sums <- c(NA,NA,sapply(dat[,3:11],function(x) round(sum(x),3)))

knitr::kable(rbind(dat,sums),caption="お菓子の長さ",booktabs=T,format="latex",digits=3)

anovakun(dat[,2:3],"As",3)




#ABs
n <- 3
mu <- 50
effectA <- 2
effectB <- 2
effectAB <- 2
err <- 1

a1b1 <- round(rnorm(n,mu + effectA + effectB + effectAB,err))
a1b2 <- round(rnorm(n,mu + effectA - effectB - effectAB,err))
a2b1 <- round(rnorm(n,mu - effectA + effectB - effectAB,err))
a2b2 <- round(rnorm(n,mu - effectA - effectB + effectAB,err))

dat2 <- data.frame(id=1:(n*4),factor1=c(rep("A1",n*2),rep("A2",n*2)),
                  factor2=c(rep("B1",n),rep("B2",n),rep("B1",n),rep("B2",n)),
                  val=c(a1b1,a1b2,a2b1,a2b2)) %>% 
    mutate(GM = mean(val)) %>% print %>% 
    mutate(diff = val-GM) %>% 
    group_by(factor1) %>% mutate(factor1_mean = mean(val)) %>% print %>% 
    ungroup %>% 
    group_by(factor2) %>% mutate(factor2_mean = mean(val)) %>% print %>% 
    ungroup %>% 
    mutate(effect1 = factor1_mean-GM,
           effect2 = factor2_mean-GM) %>% print %>% 
    group_by(factor1,factor2) %>% mutate(subgroup_mean = mean(val)) %>% print %>% 
    ungroup %>% 
    mutate(interaction = subgroup_mean - (GM + effect1 + effect2)) %>% print %>% 
    mutate(error =val - (GM+effect1+effect2+interaction)) %>% 
dplyr::select(-subgroup_mean,-factor1_mean,-factor2_mean) %>% print %>% 
    mutate(diffSQ = diff^2) %>% 
    mutate(SS1 = effect1^2,SS2=effect2^2,SS3 = interaction^2,err2 = error^2) %>% print

sums2 <- c(NA,NA,NA,NA,sapply(dat2[,5:15],function(x) round(sum(x),3)))

knitr::kable(rbind(dat2,sums2),booktabs=T,format="latex",digits=3)

anovakun(dat2[,2:4],"ABs",2,2)

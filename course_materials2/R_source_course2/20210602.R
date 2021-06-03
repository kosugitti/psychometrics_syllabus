rm(list=ls())
## サンプルデータを生成するためのコード
library(tidyverse)
library(ltm)
library(irtoys)
set.seed(20220602)

# IRT関数の設定
threePL <- function(a,b,c,theta){
    prob = c + ((1-c)/(1+exp(-1.7*a*(theta-b))))
}

# 項目母数の真値を設定
M = 10  #項目数
a_true = rnorm(M,1,0.2)  #識別力パラメータ
b_true = runif(M,-3,3) #困難度パラメータ
c_true = runif(M,0,0.5) #あて推量母数

# データの生成
N <- 500 #サンプルサイズ
X <- rnorm(N,0,1) |> transform()
tmp <- matrix(nrow=N,ncol=M)
for(i in 1:N){
    for(j in 1:M){
        prob = threePL(a_true[j],b_true[j],c_true[j],X$X_data[i])
        tmp[i,j] = rbinom(1,1,prob)
    }
}

sample <- as.data.frame(tmp)

write_csv(sample,file="IRTsample.csv")
sample %>% head %>% knitr::kable(format="latex",caption="IRTで使うサンプルデータ(一部)")


# chapter11 ---------------------------------------------------------------

psych::describe(sample)










ltm::ltm(sample~z1)
irtoys::est(sample,model = "2PL",engine = "ltm")

ltm::rasch(sample)
irtoys::est(sample,model = "1PL",engine = "ltm")

tpm(sample)
irtoys::est(sample,model = "3PL",engine = "ltm")

descript(sample)

retIRT <- psych::fa.poly(sample)
summary(retIRT)
retIRT
library(psych)
ls <- irt.fa(lsat6)
ltm.result <- ltm(lsat6~z1)
round(coefficients(ltm.result)/1.702,3)
fa.poly(lsat6)
ls$fa
ls$irt$difficulty
ls$rho
ls$tau
ret.mirt <- mirt(lsat6,2)
ret.mirt
summary(ret.mirt)
fa.poly(lsat6,2,fm="ML")

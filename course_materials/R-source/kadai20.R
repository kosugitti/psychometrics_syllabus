rm(list=ls())
set.seed(12345)
# 記述統計量を求める
N <- 10
X <- rnorm(N,50,10) %>% round
X

X
## テキスト用出力
print(xtable::xtable(matrix(X,nrow=1), label = "exe:20_1", digits = 0), 
      include.rownames = F, 
      include.colnames = F)

sd(X)
mean((X-mean(X))^2); var(X)*(N-1)/N
# 一標本検定
t.test(X,mu=50)

# 対応のあるt検定
N <- 8
X1 <- rnorm(N,20,10) %>% round
X2 <- rnorm(N,20,10) %>% round

datmat <- matrix(c(X1,X2),nrow=2,byrow = T) 
rownames(datmat) = c("pre","post")
## テキスト用出力
print(xtable::xtable(datmat, label = "exe:20_2", digits = 0), 
      include.rownames = T, 
      include.colnames = F)

t.test(X1,X2,paired = T,alternative = "less")
t.test(X1,X2,paired = T)

# 対応のないt検定
N <- 10
X1 <- rnorm(N,20,1) %>% round
X2 <- rnorm(N,20,1) %>% round

## テキスト用出力
datmat <- matrix(c(X1,X2),nrow=2,byrow = T) 
rownames(datmat) = c("Control","Experimental")
print(xtable::xtable(datmat, label = "exe:20_2", digits = 0), 
      include.rownames = T, 
      include.colnames = F)

t.test(X1,X2,paired = F)
# 対応のないt検定(Welchの補正なし)
t.test(X1,X2,paired = F,var.equal = T)
# 効果量
library(effsize)
cohen.d(X1,X2,hedges.correction = T)


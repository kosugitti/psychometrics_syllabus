rm(list=ls())
pacman::p_load(tidyverse)
set.seed(12345)
## フルランク
A <- matrix(c(1,3,5,2,4,3,3,1,2,2,1,6,3,5,4),ncol=3)
M <- t(A) %*% A
solve(M)
## ランクおちかけ
A[,3] <- A[,2]+rnorm(5)*0.001
A
M <- t(A) %*% A
M
solve(M) %>% knitr::kable(format='latex')
## ランク落ち
A[,3] <- A[,2]
M <- t(A) %*% A
solve(M)


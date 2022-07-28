rm(list=ls())
pacman::p_load(tidyverse)

A <- matrix(c(1,1,0,0,0,0,1,1),ncol=2)
G <- rep(1,4)
PA <- A %*% solve(t(A)%*%A) %*% t(A)
PG <- G %*% solve(t(G)%*%G) %*% t(G)
Pe <- diag(c(1,1,1,1))-PA
PF <- PA-PG

X <- c(1,3,4,6)
t(X)%*%PF %*% X
t(X)%*%Pe %*% X
t(X)%*%X - t(X)%*%PG %*% X


# 　回転 ---------------------------------------------------------------------


cosT <- cos(0.20*pi)
sinT <- sin(0.20*pi)
rotMat <- matrix(c(cosT,sinT,-sinT,cosT),ncol=2)
x1 <- c(-5,0)
x2 <- c(5,0)
y1 <- c(0,-5)
y2 <- c(0,5)
rotMat %*% x1
rotMat %*% x2
rotMat %*% y1
rotMat %*% y2

datMat <- matrix(c(3,3,-0.8,1.5,1.5,1,2,-1,-2,-3,-2,-1.5),ncol=2,byrow=T)
datMat[,1] <- datMat[,1]-colMeans(datMat)[1]
rotatedDat <- datMat%*%rotMat
datMat %>% apply(2,function(x) sum(x^2))
rotatedDat %>% apply(2,function(x) sum(x^2))
datMat %>% apply(2,function(x) sum(x^2)) %>% sum
rotatedDat %>% apply(2,function(x) sum(x^2)) %>% sum

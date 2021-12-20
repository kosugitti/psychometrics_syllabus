rm(list=ls())
source("utilities.R")

model1 <- cmdstan_model("modelComp.stan")
model2 <- cmdstan_model("modelComp2.stan")
N <- 30
head <- 17
tail <- N-head
dataSet <- list(N=N,Y=c(rep(1,head),rep(0,tail)))
fit1 <- model1$sample(data=dataSet,iter_sampling = 10000)
fit2 <- model2$sample(data=dataSet,iter_sampling = 10000)
fit1$summary()
fit2$summary()

rm(list=ls())
source("utilities.R")

model <- cmdstan_model("modelComp.stan")
dataSet <- list(N=9,Y=c(1,1,1,1,1,1,0,0,0),omega1=0.25,kappa1=12,omega2=0.75,kappa2=12)
fit <- model$sample(data=dataSet,iter_sampling = 100000)
fit$output_files() %>% rstan::read_stan_csv() %>% MCMC_result() %>% filter(str_detect(Varname,"t"))

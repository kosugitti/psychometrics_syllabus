rm(list=ls())
library(tidyverse)
set.seed(20220314)
mu <- 50
N <- 5
effectA <- 1
effectB <- 3
effectC <- 0 - (effectA+effectB)
sig <- 3
tau <- 5
base <- rnorm(N,mu,tau) %>% round
T1 <- base + effectA +rnorm(N,0,sig)
T2 <- base + effectB +rnorm(N,0,sig)
T3 <- base + effectC +rnorm(N,0,sig)
dat <- data.frame(ID = LETTERS[1:N],
                  Time1 = T1 %>% round,Time2=T2 %>% round,Time3=T3 %>% round)
dat %>% knitr::kable(format = "latex")


## こたえ
dat %>% pivot_longer(-ID) %>% 
    group_by(name) %>% nest %>% 
    mutate(TimeEffect = purrr::map_dbl(data,~mean(.$value))) %>% 
    unnest(cols=c(data)) %>% 
    group_by(ID) %>% nest %>% 
    mutate(Ind = purrr::map_dbl(data,~mean(.$value))) %>% 
    unnest(cols=c(data)) %>% 
    ungroup() %>% 
    nest(data=everything()) %>% 
    mutate(GM = purrr::map_dbl(data,~mean(.$value))) %>% 
    unnest(cols=c(data)) %>% 
    mutate(Effect = GM-TimeEffect,
           IndEffect = GM - Ind,
           Err = value - GM + Effect + IndEffect)

rm(list=ls())
library(tidyverse)
set.seed(20220314)
mu <- 50
N <- 4
effectA <- 10
effectB <- 3
effectC <- 0 - (effectA+effectB)
sig <- 3
groupA <- mu + effectA + rnorm(N,0,sig)
groupB <- mu + effectB + rnorm(N,0,sig)
groupC <- mu + effectC + rnorm(N,0,sig)

dat <- data.frame(School = rep(LETTERS[1:3],each=N),
           ID = rep(1:N,3),
           Score = c(round(groupA),round(groupB),round(groupC)))
dat %>% knitr::kable(format="latex")

## こたえ
dat %>% 
    group_by(School) %>% 
#    summarise(M = mean(Score))
    nest() %>% 
    mutate(M = purrr::map_dbl(data, ~mean(.$Score))) %>% 
    unnest(data) %>% 
    ungroup() %>% 
    nest(data = everything()) %>% 
    mutate(GM = purrr::map_dbl(data,~mean(.$Score))) %>% 
    unnest(data) %>% 
    mutate(Eff = M - GM) %>% 
    mutate(ERR = Score - M)
    

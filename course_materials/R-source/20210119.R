rm(list=ls())
library(tidyverse)

A <- c(4,4,5,5,5,5,6,6)
B <- c(1,2,3,5,5,7,8,9)
df <- data.frame(A,B)
df %>% rowid_to_column("id") %>% 
    pivot_longer(-id) %>% 
    group_by(name) %>% 
    summarise(mean=mean(value),median=median(value))

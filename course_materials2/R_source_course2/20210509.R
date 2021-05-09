rm(list=ls())
library(tidyverse)
library(psych)
help(bfi)
dat <- psych::bfi %>% dplyr::select(-gender,-education,-age)
dat

corMat <- cor(dat,use="pairwise") 
corMat
eigen(corMat)
fa.parallel(dat)

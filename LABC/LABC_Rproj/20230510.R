rm(list=ls())
library(tidyverse)
eq1 <- function(x){
    -x + 5
}

eq2 <- function(x){
    -2*x + 4
}

eq3 <- function(x){
    -0.5 * x -1
}

ggplot(data = data.frame(X = c(-5, 15)), aes(x = X)) + 
    stat_function(fun = eq1,color="red") + 
    stat_function(fun = eq2,color="blue") + 
    stat_function(fun = eq3)+
    geom_point(x=mean(c(-1,3,11)),y=mean(c(6,-2,-6)))

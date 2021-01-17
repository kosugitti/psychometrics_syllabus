rm(list=ls())
library(tidyverse)
library(xtable)
library(stargazer)
set.seed(20200902)

limitRange <- function(fun,min, max) {
    function(x) {
        y <- fun(x)
        y[x < min  |  x > max] <- NA
        return(y)
    }
}

p <- ggplot(data.frame(x=c(-4, 4)), aes(x=x))
p + stat_function(fun = dnorm,args=list(mean=0,sd=1)) +
    stat_function(fun = limitRange(dnorm,-4,1.5),
                  geom="area", fill="blue", alpha=0.2)
p <- ggplot(data.frame(x=c(-4, 4)), aes(x=x))
p + stat_function(fun = dnorm,args=list(mean=0,sd=1)) +
    stat_function(fun = limitRange(dnorm,-1.96,1.96),
                  geom="area", fill="blue", alpha=0.2)

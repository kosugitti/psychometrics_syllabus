library(tidyverse)
library(ggplot2)
library(gridExtra)
set.seed(12345)
limitRange <- function(fun, min, max) {
    function(x) {
        y <- fun(x)
        y[x =< min | x >= max] <- NA
        return(y)
    }
}

g1 <- ggplot(data.frame(x = c(-3, 3)), aes(x = x)) +
    stat_function(fun = dnorm) +
    stat_function(
        fun = limitRange(dnorm, -4, -1.96),
        geom = "area", fill = palette()[3], alpha = 0.2
    ) +
    stat_function(
        fun = limitRange(dnorm, 1.96, 4),
        geom = "area", fill = palette()[3], alpha = 0.2
    )+
    stat_function(
        fun = limitRange(dnorm, -1.96, 1.96),
        geom = "area", fill = palette()[2], alpha = 0.2
    )+
    theme_classic()

g1

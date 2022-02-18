rm(list = ls())
library(tidyverse)
library(colorBlindness)
library(gridExtra)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
scale_fill_manual(values = colorBlindness::Blue2Orange10Steps)
limitRange <- function(fun, min, max) {
    function(x) {
        y <- fun(x)
        y[x <= min | x >= max] <- NA
        return(y)
    }
}

# 関数を使う
dnorm(x = 0, mean = 0, sd = 1)
pnorm(q = 1.0, mean = 0, sd = 1)
qnorm(p = 0.618, mean = 0, sd = 1)
rnorm(n = 10, mean = 0, sd = 1)

p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
g1 <- p + stat_function(fun = dnorm) +
    stat_function(
        fun = limitRange(dnorm, -4, 1.0),
        geom = "area", fill = palette()[4], alpha = 0.4
    ) + ylab("確率密度")+xlab("")+theme(axis.text = element_text(size=20),
                                       axis.title.y = element_text(size=20))
g1

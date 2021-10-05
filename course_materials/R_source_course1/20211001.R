library(tidyverse)
library(ggplot2)
library(gridExtra)
set.seed(12345)
limitRange <- function(fun, min, max) {
  function(x) {
    y <- fun(x)
    y[x < min | x > max] <- NA
    return(y)
  }
}

g <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, -4, -1.96),
    geom = "area", fill = "blue", alpha = 0.2
  ) +
  stat_function(
    fun = limitRange(dnorm, 1.96, 4),
    geom = "area", fill = "blue", alpha = 0.2
  )
# t分布の描画 ------------------------------------------------------------------
limitRange2 <- function(prob, df, ncp = 0) {
  function(x) {
    y <- dt(x, df = df, ncp = ncp)
    min <- qt(p = (1 - prob) / 2, df = df, ncp = ncp)
    max <- qt(p = 1 - ((1 - prob) / 2), df = df, ncp = ncp)
    y[x < min | x > max] <- NA
    return(y)
  }
}


ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dt, args = list(df = 48)) +
  stat_function(
    fun = limitRange2(prob = .95, df = 48),
    geom = "area", fill = "blue", alpha = 0.2
  ) +
  theme_classic()

limitRange3 <- function(df, min, max, ncp = 0) {
  function(x) {
    y <- dt(x, df, ncp = 0)
    y[x < min | x > max] <- NA
    return(y)
  }
}

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dt, args = list(df = 48)) +
    stat_function(
        fun = limitRange3(min=1.4,max=4, df = 48),
        geom = "area", fill = "blue", alpha = 0.2
    ) +
    theme_classic()


ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dt, args = list(df = 18)) +
    stat_function(
        fun = limitRange2(prob = .95, df = 18),
        geom = "area", fill = "blue", alpha = 0.2
    ) +
    theme_classic()

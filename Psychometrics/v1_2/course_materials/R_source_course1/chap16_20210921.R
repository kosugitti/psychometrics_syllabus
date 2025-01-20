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

g0 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, -1.96, 1.96),
    geom = "area", fill = "blue", alpha = 0.2
  )

N <- 100
X <- rnorm(N, 0, 1) %>% transform()
X %>% ggplot(aes(x = X_data)) +
  geom_histogram() +
  geom_vline(xintercept = mean(X$X_data), color = "red") +
  xlim(-4, 4) -> g1
N <- 100
X <- rnorm(N, 0, 1) %>% transform()
X %>% ggplot(aes(x = X_data)) +
  geom_histogram() +
  geom_vline(xintercept = mean(X$X_data), color = "red") +
  xlim(-4, 4) -> g2
N <- 100
X <- rnorm(N, 0, 1) %>% transform()
X %>% ggplot(aes(x = X_data)) +
  geom_histogram() +
  geom_vline(xintercept = mean(X$X_data), color = "red") +
  xlim(-4, 4) -> g3

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = (1 / sqrt(N))), color = "blue") -> g4

layout <- rbind(c(1, 1, 1), c(2, 3, 4))
gridExtra::grid.arrange(g0, g1, g2, g3, layout_matrix = layout)



# t分布の描画 ------------------------------------------------------------------

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dt, args = list(df = 1), aes(colour = "自由度1")) +
  stat_function(fun = dt, args = list(df = 3), aes(colour = "自由度3")) +
  stat_function(fun = dt, args = list(df = 30), aes(colour = "自由度30"))


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
  stat_function(fun = dt, args = list(df = 8)) +
  stat_function(
    fun = limitRange2(prob = .95, df = 8),
    geom = "area", fill = "blue", alpha = 0.2
  ) +
  theme_classic()

ggplot(data.frame(x = c(-5, 5)), aes(x = x)) +
  stat_function(fun = dt, args = list(df = 2)) +
  stat_function(
    fun = limitRange2(prob = .95, df = 2),
    geom = "area", fill = "blue", alpha = 0.2
  )



ggplot(data.frame(x = c(-10, 10)), aes(x = x)) +
  stat_function(fun = dt, args = list(df = 8)) +
  stat_function(
    fun = limitRange2(prob = .95, df = 8),
    geom = "area", fill = "blue", alpha = 0.2
  ) +
  theme_classic()

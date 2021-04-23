rm(list = ls())
library(tidyverse)
library(colorBlindness)
library(gridExtra)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
scale_fill_manual(values = colorBlindness::Blue2Orange10Steps)
p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = dnorm) +
  stat_function(fun = dnorm, args = list(mean = 1, sd = 1), color = palette()[2]) +
  stat_function(fun = dnorm, args = list(mean = 1, sd = 3), color = palette()[4]) +
  stat_function(fun = dnorm, args = list(mean = -2, sd = 0.5), color = palette()[3])

p
ggsave(p, filename = "../images/text08/Rplot08_01.png", dpi = 600, width = 12, height = 8)


p1 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) x^2) +
  annotate("text", x = 0, y = 1, parse = TRUE, label = "x^2")
p2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) -x^2) +
  annotate("text", x = 0, y = -1, parse = TRUE, label = "-x^2")
p3 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) exp(x)) +
  annotate("text", x = 0, y = 10, parse = TRUE, label = "exp(x)")
p4 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) exp(-x^2)) +
  annotate("text", x = 0, y = 0.3, parse = TRUE, label = "exp(-x^2)")
p5 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) exp(-x^2)) +
  stat_function(fun = function(x) exp(-(x - 1)^2), color = palette()[2]) +
  stat_function(fun = function(x) exp(-(x + 1)^2), color = palette()[4]) +
  annotate("text", x = 0.5, y = 0.3, parse = TRUE, label = "exp(-x^2)") +
  annotate("text", x = 3, y = 0.3, parse = TRUE, label = "exp(-(x-1)^2)", color = palette()[2]) +
  annotate("text", x = -3, y = 0.3, parse = TRUE, label = "exp(-(x+1)^2)", color = palette()[4])
p6 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
  stat_function(fun = function(x) exp(-x^2)) +
  stat_function(fun = function(x) exp(-(x^2) / 4), color = palette()[2]) +
  stat_function(fun = function(x) exp(-(x^2) / 0.25), color = palette()[4]) +
  annotate("text", x = 0.5, y = 0.3, parse = TRUE, label = "exp(-x^2)") +
  annotate("text", x = 3, y = 0.3, parse = TRUE, label = "exp(-(x^2/4))", color = palette()[2]) +
  annotate("text", x = 0, y = 0.1, parse = TRUE, label = "exp(-(x^2/0.25))", color = palette()[4])


g <- gridExtra::grid.arrange(p1, p2, p3, p4, p5, p6)
ggsave(g, filename = "../images/text08/Rplot08_02.png", dpi = 600, width = 12, height = 9)


# 面積を求める ------------------------------------------------------------------


limitRange <- function(fun, min, max) {
  function(x) {
    y <- fun(x)
    y[x < min | x > max] <- NA
    return(y)
  }
}

p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
g <- p + stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, 0.3, 1.0),
    geom = "area", fill = palette()[2], alpha = 0.4
  ) +
  theme(
    axis.text = element_text(size = 16),
    axis.title = element_text(size = 14, face = "bold")
  ) + ylab("Probability density")

g

ggsave(g, filename = "../images/text08/Rplot08_03.png", dpi = 600, width = 8, height = 6)

# 被積分関数の定義
s <- function(x) {
  exp(-x^2 / 2) / sqrt(2 * pi)
}
# 積分の実行
integrate(s, lower = 0.3, upper = 1)

# 数表
library(knitr)
# 標準正規分布の表
x.seq <- seq(0, 3, 0.01)
cbind(
  z = x.seq, lower = pnorm(x.seq, mean = 0, sd = 1) - 0.5,
  upper = 1 - pnorm(x.seq, mean = 0, sd = 1)
) %>%
  round(., 3) %>%
  as.data.frame() -> dt

dt0 <- dt[1:60, ]
dt1 <- dt[61:120, ]
dt2 <- dt[121:180, ]
dt3 <- dt[181:240, ]
dt4 <- dt[241:300, ]

cbind(dt0, dt1, dt2, dt3, dt4) %>% kable(format = "latex", caption = "標準正規分布の表")


p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
g1 <- p + stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, 0, 1.0),
    geom = "area", fill = palette()[4], alpha = 0.4
  ) + annotate("text", x = 1.0, y = -0.01, parse = TRUE, label = "z")
g2 <- p + stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, 1.0, 4),
    geom = "area", fill = palette()[4], alpha = 0.4
  ) + annotate("text", x = 1.0, y = -0.01, parse = TRUE, label = "z")
g1
g2
g <- grid.arrange(g1, g2)

ggsave(g, filename = "../images/text08/Rplot08_04.png", dpi = 600, width = 8, height = 6)

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
    ) + 
    annotate("text", x = 1.0, y = -0.01, parse = TRUE, label = "q") + 
    annotate("text", x = 0, y = 0.405, parse = TRUE, label = "d") +
    annotate("text", x = -0.5, y = 0.2, parse = TRUE, label = "p") + 
    geom_segment(x=0,xend=0,y=0,yend=dnorm(0),lty=2) 
g1
ggsave(g1, filename = "../images/text08/Rplot08_05.png", dpi = 600, width = 8, height = 6)

pnorm(q = 1.0, mean = 0, sd = 1) - pnorm(q = 0.3, mean = 0, sd = 1)

N1 <- 100
N2 <- 1000
N3 <- 10000
N4 <- 100000
X1 <- rnorm(N1)
X2 <- rnorm(N2)
X3 <- rnorm(N3)
X4 <- rnorm(N4)


g <- data.frame(value=c(X1,X2,X3,X4)) %>% as_tibble() %>% 
    mutate(group = c(rep(1,N1),rep(2,N2),rep(3,N3),rep(4,N4)) %>% factor(labels=c("N=100","N=1000","N=10000","N=100000"))) %>% 
    ggplot(aes(x=value))+geom_histogram(binwidth = 0.1)+
    facet_wrap(~group,scales="free")
ggsave(g, filename = "../images/text08/Rplot08_06.png", dpi = 600, width = 8, height = 6)


X <- rnorm(n = 100000 , mean = 0 , sd = 1)
length(X[X>0.3 & X<1.0])
length(X[X>0.3 & X<1.0])/100000


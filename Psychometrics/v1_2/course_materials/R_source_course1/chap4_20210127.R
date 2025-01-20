library(ggplot2)
library(gridExtra)
library(colorBlindness)
library(ggthemes)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))

p1 <- ggplot(data = data.frame(X = c(0, 100)), aes(x = X)) +
  stat_function(
    fun = dnorm, args = list(mean = 90, sd = 8),
    color = 2
  ) +
  scale_colour_colorblind() +
  xlab("") +
  ylab("英語") +
  geom_segment(aes(
    x = 86,
    xend = 86, y = 0, yend = dnorm(86, 90, 8)
  ), lty = 2)

p2 <- ggplot(data = data.frame(X = c(0, 100)), aes(x = X)) +
  stat_function(
    fun = dnorm, args = list(mean = 53, sd = 10),
    color = 3
  ) +
  scale_colour_colorblind() +
  xlab("") +
  ylab("国語") +
  geom_segment(aes(
    x = 67,
    xend = 67, y = 0, yend = dnorm(67, 53, 10)
  ), lty = 2)
p3 <- ggplot(data = data.frame(X = c(0, 100)), aes(x = X)) +
  stat_function(
    fun = dnorm, args = list(mean = 30, sd = 5),
    color = 4
  ) +
  scale_colour_colorblind() +
  xlab("") +
  ylab("数学") +
  geom_segment(aes(
    x = 44,
    xend = 44, y = 0, yend = dnorm(44, 30, 5)
  ), lty = 2)
# まとめて1枚に出力
g <- grid.arrange(p1, p2, p3, ncol = 1)
ggsave(g, filename = "../images/text04/Rplot04_02.png", dpi = 600, width = 6, height = 6)





p2 <- ggplot(data = data.frame(X = c(0, 100)), aes(x = X)) +
  stat_function(
    fun = dnorm, args = list(mean = 53, sd = 10),
    color = "blue"
  ) +
  xlab("") +
  ylab("国語") +
  geom_segment(aes(x = 67, xend = 67, y = 0, yend = dnorm(67, 53, 10)), lty = 2) +
  geom_segment(aes(x = 53, xend = 53, y = 0, yend = dnorm(53, 53, 10)), lty = 1) +
  geom_segment(aes(x = 53, xend = 63, y = dnorm(63, 53, 10), yend = dnorm(63, 53, 10)), lty = 1)

p3 <- ggplot(data = data.frame(X = c(0, 100)), aes(x = X)) +
  stat_function(
    fun = dnorm, args = list(mean = 30, sd = 5),
    color = "green"
  ) +
  xlab("") +
  ylab("数学") +
  geom_segment(aes(x = 44, xend = 44, y = 0, yend = dnorm(44, 30, 5)), lty = 2) +
  geom_segment(aes(x = 30, xend = 30, y = 0, yend = dnorm(30, 30, 5)), lty = 1) +
  geom_segment(aes(x = 30, xend = 35, y = dnorm(35, 30, 5), yend = dnorm(35, 30, 5)), lty = 1)

grid.arrange(p2, p3, ncol = 1)


rm(list = ls())
pacman::p_load(tidyverse, patchwork)
q <- qt(c(0.025, 0.975), df = 9)
# 片側と両側
p1 <- ggplot(data = data.frame(X = c(-5, 5)), aes(x = X)) +
  stat_function(fun = dt, args = list(df = 9)) +
  xlab("") +
  geom_ribbon(data = data.frame(X = x <- seq(-5, q[1], len = 101),
                                Y = dt(x, df = 9)), aes(x = X, ymin = 0, ymax = Y), alpha = 0.3) +
  geom_ribbon(data = data.frame(X = x <- seq(q[2], 5, len = 101),
                                Y = dt(x, df = 9)), aes(x = X, ymin = 0, ymax = Y), alpha = 0.3) +
  geom_vline(xintercept = 2.479, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = 2.479, y = 0.3, label = "t = 2.479", hjust = -0.1, color = "red", size = 4) +
  theme_bw() + ylab("")

p2 <- ggplot(data = data.frame(X = c(-5, 5)), aes(x = X)) +
  stat_function(fun = dt, args = list(df = 9)) +
  xlab("") +
  geom_ribbon(data = data.frame(X = x <- seq(qt(0.95, df = 9), 5, len = 101),
                                Y = dt(x, df = 9)), aes(x = X, ymin = 0, ymax = Y), alpha = 0.3) +
  geom_vline(xintercept = 2.479, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = 2.479, y = 0.3, label = "t = 2.479", hjust = -0.1, color = "red", size = 4) +
  theme_bw() + ylab("")


plot_combined <- p2 / p1
ggsave("direction_of_test.png", plot_combined, width = 8, height = 6)

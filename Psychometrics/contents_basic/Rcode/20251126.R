rm(list = ls())
pacman::p_load(tidyverse)

# フォント設定
if (Sys.info()["sysname"] == "Darwin") {
  quartzFonts(HiraKaku = quartzFont(rep("HiraginoSans-W3", 4)))
}

# ロジスティック関数のグラフ
# theta = 1 / (1 + exp(-y_hat))

# データ作成
x <- seq(-6, 6, by = 0.1)
y <- 1 / (1 + exp(-x))
dat <- data.frame(x = x, y = y)

# グラフ作成
g <- ggplot(dat, aes(x = x, y = y)) +
  geom_line(linewidth = 1.2, color = "black") +
  geom_hline(yintercept = c(0, 1), linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "gray30") +
  geom_vline(xintercept = 0, linetype = "dotted", color = "gray30") +
  labs(
    x = expression(paste("Linear Predictor ", hat(y))),
    y = expression(theta)
  ) +
  scale_y_continuous(breaks = c(0, 0.5, 1), limits = c(-0.05, 1.05)) +
  scale_x_continuous(breaks = seq(-6, 6, by = 2)) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12)
  ) +
  annotate("text", x = 4, y = 0.3,
           label = expression(theta == frac(1, 1 + e^{-hat(y)})),
           size = 5, parse = FALSE) +
  annotate("text", x = 4, y = 0.2,
           label = "logistic function",
           size = 4)

print(g)

# グラフを保存
ggsave("../figures/24_linear_model/logistic_function.png",
       plot = g, width = 8, height = 5, dpi = 300)

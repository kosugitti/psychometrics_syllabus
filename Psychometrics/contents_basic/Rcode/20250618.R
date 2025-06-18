rm(list=ls())
pacman::p_load(tidyverse,cmdstanr)

# xの範囲を設定
x <- seq(-6, 6, length.out = 1000)

# 各正規分布のパラメータを定義
distributions <- data.frame(
  mu = c(0, 1, -2, 1),
  sigma = c(1, 1, 0.5, 3),
  color = c("標準正規分布 (μ=0, σ=1)", "μ=1, σ=1",
            "μ=-2, σ=0.5", "μ=1, σ=3"),
  line_color = c("black", "red", "blue", "#00BB22")
)

# データフレームを作成
plot_data <- data.frame()
for(i in 1:nrow(distributions)) {
  y <- dnorm(x, mean = distributions$mu[i], sd =
               distributions$sigma[i])
  temp_data <- data.frame(
    x = x,
    y = y,
    distribution = distributions$color[i],
    line_color = distributions$line_color[i]
  )
  plot_data <- rbind(plot_data, temp_data)
}

# グラフを作成
p <- ggplot(plot_data, aes(x = x, y = y, color =
                             distribution)) +
  geom_line(size = 1.2) +
  scale_color_manual(values = c("black", "red",
                                "blue", "#00BB22")) +
  labs(
    x = "x",
    y = "確率密度",
    color = "分布"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5, size =
                                14),
    legend.position = "none",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  xlim(-6, 6) +
  ylim(0, max(plot_data$y) * 1.1)

# グラフを表示
print(p)
ggsave(p,filename = "../figures/10_Probability/normal1.png")

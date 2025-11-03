rm(list = ls())
source("https://bit.ly/3WL8VYR")

# ========================================
# 2変量正規分布とマージナルヒストグラム
# ch22でWithin計画の多変量正規分布を説明するための図
# ========================================

library(MASS)
library(ggplot2)
library(tidyr)

# ggExtraのインストール（初回のみ）
if (!require(ggExtra, quietly = TRUE)) {
  install.packages("ggExtra", repos = "https://cran.r-project.org")
  library(ggExtra)
}

# 2変量正規分布のパラメータ設定
set.seed(42)

# 平均ベクトル
mu <- c(X1 = 0, X2 = 0)

# 分散共分散行列
# 対角要素: 分散
# 非対角要素: 共分散
sigma <- matrix(
  c(
    1.0, # X1の分散
    0.6, # X1とX2の共分散
    0.6, # X2とX1の共分散
    1.0
  ), # X2の分散
  nrow = 2, byrow = TRUE
)

# MASSパッケージのmvrnorm()で2変量正規分布からサンプリング
n_samples <- 1000
data_bivariate <- mvrnorm(n = n_samples, mu = mu, Sigma = sigma)

# データフレームに変換
df_bivariate <- as.data.frame(data_bivariate)
colnames(df_bivariate) <- c("X1", "X2")

# ====================================
# ggplot + ggExtraでマージナルヒストグラム付きの図を作成
# ====================================

# メインプロット：2変量正規分布の散布図
p_main <- ggplot(df_bivariate, aes(x = X1, y = X2)) +
  geom_point(alpha = 0.5, size = 2, color = "steelblue") +
  # 相関楕円を追加（分布の形を視覚的に表現）
  stat_ellipse(aes(color = "95% Confidence Ellipse"),
    level = 0.95,
    linewidth = 1.2,
    linetype = "dashed"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    legend.position = "none"
  )

# 理論的な正規分布曲線のためのデータ作成
# X1のマージナル分布データ
x1_range <- seq(mu[1] - 4 * sqrt(sigma[1, 1]), mu[1] + 4 * sqrt(sigma[1, 1]), length.out = 200)
x1_theory <- data.frame(
  x = x1_range,
  y = dnorm(x1_range, mean = mu[1], sd = sqrt(sigma[1, 1]))
)

# X2のマージナル分布データ（正規分布の値をX軸に、X2をY軸に）
x2_range <- seq(mu[2] - 4 * sqrt(sigma[2, 2]), mu[2] + 4 * sqrt(sigma[2, 2]), length.out = 200)
x2_density <- dnorm(x2_range, mean = mu[2], sd = sqrt(sigma[2, 2]))
x2_theory <- data.frame(
  x = x2_density, # 密度はX軸
  y = x2_range # X2の値はY軸
)

# グリッドレイアウト用にgridパッケージを使用
library(grid)
library(gridExtra)

# メインプロット（既存のp_main）はそのまま使用

# X1のマージナルプロット（上部）
p_top <- ggplot(x1_theory, aes(x = x, y = y)) +
  geom_line(linewidth = 1, color = "darkblue") +
  geom_area(alpha = 0.3, fill = "lightblue") +
  xlim(mu[1] - 4 * sqrt(sigma[1, 1]), mu[1] + 4 * sqrt(sigma[1, 1])) +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    plot.margin = margin(0, 0, 0, 0, "cm")
  )

# X2のマージナルプロット（右側）
# geom_pathで接続して正規分布曲線を描画
p_right <- ggplot(x2_theory, aes(x = x, y = y)) +
  geom_path(linewidth = 1, color = "darkblue") +
  geom_ribbon(aes(xmin = 0, xmax = x), alpha = 0.3, fill = "lightblue") +
  ylim(mu[2] - 4 * sqrt(sigma[2, 2]), mu[2] + 4 * sqrt(sigma[2, 2])) +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    plot.margin = margin(0, 0, 0, 0, "cm")
  )

# 空白領域
p_blank <- ggplot() +
  theme_void() +
  theme(plot.margin = margin(0, 0, 0, 0, "cm"))

# レイアウト作成：
# | p_top  | p_blank |
# | p_main | p_right |
# グリッドの行は上から下へ、列は左から右へ
layout_matrix <- matrix(
  c(
    1, 2, # 第1行：p_top, p_blank
    3, 4
  ), # 第2行：p_main, p_right
  nrow = 2, ncol = 2, byrow = TRUE
)

p_marginal <- gridExtra::grid.arrange(
  p_top, p_blank, p_main, p_right,
  layout_matrix = layout_matrix,
  widths = c(4, 1),
  heights = c(1, 4)
)

# 図を表示
print(p_marginal)

# 図を保存
# 作業ディレクトリ（Rcode）から二つ上の層（contents_basic）に移動
output_path_bivariate <- if (dir.exists("../../figures/22_Within_R")) {
  "../../figures/22_Within_R/bivariate_normal_marginal.png"
} else if (dir.exists("../figures/22_Within_R")) {
  "../figures/22_Within_R/bivariate_normal_marginal.png"
} else {
  # ディレクトリがない場合は作成
  dir.create("../figures/22_Within_R", showWarnings = FALSE, recursive = TRUE)
  "../figures/22_Within_R/bivariate_normal_marginal.png"
}

ggsave(output_path_bivariate,
  plot = p_marginal,
  width = 10,
  height = 8,
  dpi = 300
)

print(paste("図を保存しました:", output_path_bivariate))

# ====================================
# 統計量の表示
# ====================================

# 平均値
cat("\n=== 統計量の確認 ===\n")
cat("X1の平均:", mean(df_bivariate$X1), "\n")
cat("X2の平均:", mean(df_bivariate$X2), "\n\n")

# 標準偏差
cat("X1の標準偏差:", sd(df_bivariate$X1), "\n")
cat("X2の標準偏差:", sd(df_bivariate$X2), "\n\n")

# 相関係数
cat("相関係数 r(X1, X2):", cor(df_bivariate$X1, df_bivariate$X2), "\n\n")

# 分散共分散行列
cat("分散共分散行列:\n")
print(cov(df_bivariate))

rm(list = ls())
source("https://bit.ly/3WL8VYR")

# ========================================
# 3変量正規分布の3Dプロット
# ch22でWithin計画の3水準データの多変量正規分布を説明するための図
# ========================================

library(MASS)
library(scatterplot3d)

# 3変量正規分布のパラメータ設定
set.seed(42)

# 平均ベクトル（3つの水準）
mu <- c(X1 = 0, X2 = 0, X3 = 0)

# 分散共分散行列（3x3）
# 対角要素: 各水準の分散
# 非対角要素: 水準間の共分散
sigma <- matrix(
  c(
    1.0, 0.6, 0.5, # X1
    0.6, 1.0, 0.6, # X2
    0.5, 0.6, 1.0  # X3
  ),
  nrow = 3, ncol = 3, byrow = TRUE
)

# MASSパッケージのmvrnorm()で3変量正規分布からサンプリング
n_samples <- 1000
data_trivariate <- mvrnorm(n = n_samples, mu = mu, Sigma = sigma)

# データフレームに変換
df_trivariate <- as.data.frame(data_trivariate)
colnames(df_trivariate) <- c("X1", "X2", "X3")

# ====================================
# scatterplot3dで3D散布図を作成
# ====================================

# 図を保存
output_path_trivariate <- if (dir.exists("../figures/22_Within_R")) {
  "../figures/22_Within_R/trivariate_normal_3d.png"
} else {
  # ディレクトリがない場合は作成
  dir.create("../figures/22_Within_R", showWarnings = FALSE, recursive = TRUE)
  "../figures/22_Within_R/trivariate_normal_3d.png"
}

# PNGファイルに描画開始
png(
  filename = output_path_trivariate,
  width = 1000,
  height = 1000,
  res = 300
)

# scatterplot3dで3D散布図を作成
s3d <- scatterplot3d(
  df_trivariate$X1, df_trivariate$X2, df_trivariate$X3,
  main = "Trivariate Normal Distribution",
  xlab = "X1 (Level 1)",
  ylab = "X2 (Level 2)",
  zlab = "X3 (Level 3)",
  color = rgb(0.4, 0.6, 1.0, 0.4),  # steelblue with transparency
  pch = 16,
  cex.symbols = 0.5,
  angle = 45,  # 視点角度
  xlim = c(-4, 4),
  ylim = c(-4, 4),
  zlim = c(-4, 4)
)

# グリッドラインを追加
s3d$plane3d(
  Intercept = 0,
  x.coef = 0,
  y.coef = 1,
  lty = "dashed",
  col = rgb(0.8, 0.8, 0.8, 0.5)
)

dev.off()

print(paste("図を保存しました:", output_path_trivariate))

# ====================================
# 統計量の表示
# ====================================

# 平均値
cat("\n=== 統計量の確認 ===\n")
cat("X1の平均:", mean(df_trivariate$X1), "\n")
cat("X2の平均:", mean(df_trivariate$X2), "\n")
cat("X3の平均:", mean(df_trivariate$X3), "\n\n")

# 標準偏差
cat("X1の標準偏差:", sd(df_trivariate$X1), "\n")
cat("X2の標準偏差:", sd(df_trivariate$X2), "\n")
cat("X3の標準偏差:", sd(df_trivariate$X3), "\n\n")

# 相関係数行列
cat("相関係数行列:\n")
print(cor(df_trivariate))
cat("\n")

# 分散共分散行列
cat("分散共分散行列:\n")
print(cov(df_trivariate))

# ch08 3D図(surface, partial_slope) を scatterplot3d で生成(日本語はragg)
rm(list = ls()); library(scatterplot3d); library(ragg)
jp <- "Hiragino Sans"
dat <- data.frame(
  x1 = c(6,9,7,13,20,10,16,8,12,22,18,25,19,24,15),   # 勉強時間
  x2 = c(200,150,240,220,460,300,250,180,400,380,480,420,320,500,350), # 単語数
  y  = c(47,51,58,55,85,63,67,60,64,89,78,80,70,92,72)) # テスト点
fit <- lm(y ~ x1 + x2, dat)
b08 <- "figures/08_MultipleRegression"

# surface.png : 3D散布図 + 回帰平面
agg_png(file.path(b08, "surface.png"), width = 7, height = 6, units = "in", res = 300)
par(family = jp)
s <- scatterplot3d(dat$x1, dat$x2, dat$y, pch = 16, type = "h", angle = 50,
  xlab = "勉強時間", ylab = "単語数", zlab = "テスト点", color = "black",
  cex.lab = 1.2, mar = c(3, 3, 1, 3))
s$plane3d(fit, draw_polygon = TRUE, draw_lines = TRUE,
  polygon_args = list(col = rgb(0.3, 0.5, 1, 0.25), border = NA))
dev.off(); cat("saved surface.png\n")

# partial_slope.png : 回帰平面 + 偏回帰係数(単語数を固定し勉強時間を1増やしたときのテスト点上昇)を赤L字
agg_png(file.path(b08, "partial_slope.png"), width = 7, height = 6, units = "in", res = 300)
par(family = jp)
s <- scatterplot3d(dat$x1, dat$x2, dat$y, pch = 16, angle = 50,
  xlab = "勉強時間 (x1)", ylab = "単語数 (x2)", zlab = "テスト点 (y)", color = "gray60",
  cex.lab = 1.2, mar = c(3, 3, 1, 3))
s$plane3d(fit, draw_polygon = TRUE, draw_lines = TRUE,
  polygon_args = list(col = rgb(0.6, 0.6, 0.6, 0.18), border = NA))
# 単語数を一定にして勉強時間を大きめに動かし、テスト点の上昇を見せる
co <- coef(fit); x2f <- 250; x1a <- 9; x1b <- 18
ya <- co[1] + co[2]*x1a + co[3]*x2f      # 始点の高さ
yb <- co[1] + co[2]*x1b + co[3]*x2f      # 移動後の高さ
A <- s$xyz.convert(x1a, x2f, ya); B <- s$xyz.convert(x1b, x2f, ya); C <- s$xyz.convert(x1b, x2f, yb)
segments(A$x, A$y, C$x, C$y, col = "gray30", lwd = 1.2, lty = "dashed")        # 平面上の傾き(斜辺)
arrows(A$x, A$y, B$x, B$y, col = "red",  lwd = 3, length = 0.13)               # 勉強時間の移動(単語数は固定)
arrows(B$x, B$y, C$x, C$y, col = "blue", lwd = 3, length = 0.13)               # テスト点の上昇
text((A$x + B$x)/2, A$y, labels = "勉強時間を動かす\n(単語数は一定)", col = "red",  pos = 1, cex = 0.85, family = jp)
text(C$x, (B$y + C$y)/2, labels = "テスト点の\n上昇", col = "blue", pos = 4, cex = 0.85, family = jp)
text(C$x, C$y, labels = "傾き=b1", col = "gray20", pos = 3, cex = 0.85, family = jp)
dev.off(); cat("saved partial_slope.png\n")

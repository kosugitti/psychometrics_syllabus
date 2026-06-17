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
co <- coef(fit); x2f <- 320; x1a <- 14; x1b <- 15
ya <- co[1] + co[2]*x1a + co[3]*x2f
yb <- co[1] + co[2]*x1b + co[3]*x2f
P1 <- s$xyz.convert(x1a, x2f, ya); P2 <- s$xyz.convert(x1b, x2f, ya); P3 <- s$xyz.convert(x1b, x2f, yb)
segments(P1$x, P1$y, P2$x, P2$y, col = "red", lwd = 3)
segments(P2$x, P2$y, P3$x, P3$y, col = "red", lwd = 3)
text(P3$x, P3$y, labels = "b1", col = "red", pos = 4, family = jp)
dev.off(); cat("saved partial_slope.png\n")

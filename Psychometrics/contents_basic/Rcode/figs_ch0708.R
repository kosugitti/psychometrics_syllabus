# 第7章・第8章 改訂データ(勉強時間・単語数→テスト点)の図を生成
# ggplot2 + ragg(文字化け防止) + theme_bw
rm(list = ls())
library(ggplot2); library(ragg); library(GGally); library(patchwork)

jp <- "Hiragino Sans"
theme_set(theme_bw(base_family = jp, base_size = 14))
update_geom_defaults("text", list(family = jp))

# --- データ ---
dat <- data.frame(
  ID = LETTERS[1:15],
  勉強時間 = c(6,9,7,13,20,10,16,8,12,22,18,25,19,24,15),
  単語数   = c(200,150,240,220,460,300,250,180,400,380,480,420,320,500,350),
  テスト点 = c(47,51,58,55,85,63,67,60,64,89,78,80,70,92,72)
)
base07 <- "figures/07_Regressions"
base08 <- "figures/08_MultipleRegression"

savep <- function(p, path, w = 8, h = 6) {
  agg_png(path, width = w, height = h, units = "in", res = 300)
  print(p); dev.off(); cat("saved:", path, "\n")
}

# --- ch07: 単回帰の図 ---
# 1. 散布図
g_sc <- ggplot(dat, aes(勉強時間, テスト点)) +
  geom_point(size = 2.5) + labs(x = "1週間の勉強時間（時間）", y = "期末テストの点数")
savep(g_sc, file.path(base07, "simple_scatter.png"))

# 2. 線を引くのも難しい（上: 点を結ぶ折れ線 / 下: 直線回帰）
d_ord <- dat[order(dat$勉強時間), ]
g_top <- ggplot(d_ord, aes(勉強時間, テスト点)) + geom_line() + geom_point(size = 2) +
  labs(x = NULL, y = "テスト点") + ggtitle("すべての点を通そうとすると直線にならない")
g_bot <- ggplot(dat, aes(勉強時間, テスト点)) +
  geom_smooth(method = "lm", se = FALSE, color = "black") + geom_point(size = 2) +
  labs(x = "1週間の勉強時間（時間）", y = "テスト点") + ggtitle("直線だが全点は通らない")
savep(g_top / g_bot, file.path(base07, "linerModel.png"), h = 8)

# 3. データ・予測値・誤差（Jさんの残差を強調）
fit1 <- lm(テスト点 ~ 勉強時間, dat); dat$yhat1 <- predict(fit1)
J <- dat[dat$ID == "J", ]
g_yh <- ggplot(dat, aes(勉強時間, テスト点)) +
  geom_smooth(method = "lm", se = FALSE, color = "gray40") +
  geom_segment(data = J, aes(x = 勉強時間, xend = 勉強時間, y = テスト点, yend = yhat1),
               color = "red", linetype = "dashed", linewidth = 0.8) +
  geom_point(size = 2.5) +
  geom_point(data = J, color = "red", size = 3.5) +
  annotate("text", x = J$勉強時間 - 1.2, y = (J$テスト点 + J$yhat1)/2, label = "残差 e", color = "red", hjust = 1) +
  annotate("text", x = J$勉強時間 + 0.6, y = J$テスト点 + 1.5, label = "Jさん", hjust = 0) +
  labs(x = "1週間の勉強時間（時間）", y = "期末テストの点数")
savep(g_yh, file.path(base07, "yhatg.png"))

# 4. 考えうる色々な予測の線（A,B の試し線 + 最小二乗の線）
g_bf <- ggplot(dat, aes(勉強時間, テスト点)) +
  geom_abline(intercept = 25, slope = 3.4, color = "#1b9e77", linewidth = 0.9) +
  geom_abline(intercept = 55, slope = 0.9, color = "#7570b3", linewidth = 0.9) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  geom_point(size = 2.5) +
  annotate("text", x = 21, y = 25 + 3.4*21 + 3, label = "直線A", color = "#1b9e77") +
  annotate("text", x = 24, y = 55 + 0.9*24 - 4, label = "直線B", color = "#7570b3") +
  labs(x = "1週間の勉強時間（時間）", y = "期末テストの点数")
savep(g_bf, file.path(base07, "bestFit.png"))

# --- ch08: 散布図行列 ---
# 2. 3変数の散布図行列
g_cm2 <- ggpairs(dat[, c("勉強時間","単語数","テスト点")]) +
  theme(text = element_text(family = jp))
savep(g_cm2, file.path(base08, "corrMat2.png"), w = 8, h = 7)

# 3. 予測値・残差を含む散布図行列（残差と説明変数・予測値の相関が0付近）
fit2 <- lm(テスト点 ~ 勉強時間 + 単語数, dat)
dat$予測値 <- predict(fit2); dat$残差 <- resid(fit2)
g_cm3 <- ggpairs(dat[, c("勉強時間","単語数","テスト点","予測値","残差")]) +
  theme(text = element_text(family = jp))
savep(g_cm3, file.path(base08, "corrMat3.png"), w = 9, h = 8)

cat("== 完了 ==\n")

# ch20 加筆用：前回(ch19)の一要因3水準と，理論編(ch18)のコーヒーの二要因を anovakun で実行する
rm(list = ls())

# 準備 ----------------------------------------------------------------------
pacman::p_load(tidyverse)
# anovakun
source("https://riseki.cloudfree.jp/?plugin=attach&refer=ANOVA%E5%90%9B&openfile=anovakun_489.txt")

# 1. 前回(ch19)の一要因3水準のデータ -----------------------------------------------
# ch19 code 19_03 と同じもの
Example1 <- data.frame(
  id = 1:12,
  condition = rep(1:3, each = 4),
  value = c(6, 6, 5, 5, 7, 4, 7, 6, 4, 3, 4, 6)
)
# 要因型にする
Example1$condition <- factor(Example1$condition,
  labels = c("control", "exp1", "exp2")
)

# 2. 理論編(ch18)のコーヒーの二要因のデータ -----------------------------------------
# ch18 表18.4(tbl:18_04)。温度(Hot/Cold)×メーカー(銘柄A/銘柄B)，各セル3名・20点満点
Coffee <- data.frame(
  id = 1:12,
  temp = rep(1:2, each = 6),
  maker = rep(rep(1:2, each = 3), 2),
  value = c(13, 11, 12, 7, 6, 8, 9, 9, 9, 13, 11, 9)
)
Coffee$temp <- factor(Coffee$temp, labels = c("Hot", "Cold"))
Coffee$maker <- factor(Coffee$maker, labels = c("A", "B"))

# 3. anovakun で実行する ------------------------------------------------------------
## 一要因群間計画(3水準)。id の列は渡さず，要因と従属変数の列だけを渡す
anovakun(Example1[, -1], "As", 3, eps = TRUE)

## 二要因群間計画(2×2)
anovakun(Coffee[, -1], "ABs", 2, 2, eps = TRUE)

# 4. 下位検定と可視化の説明用：間2×間3のデータ ---------------------------------------
# ANOVA_dataMaker.R で作ったものを数値で固定した(各セル5名)。作り方は次のとおり
#   source("ANOVA_dataMaker.R")
#   make_anova_data("ABs", n = 5, levels = c(2, 3), A = TRUE, B = TRUE, AB = TRUE,
#                   match = TRUE, seed = 1)   # 採用された種は10
# 主効果A・主効果B・交互作用がすべて有意。B(3水準)の主効果の多重比較と，
# 単純効果「B at a1」「B at a2」の中の多重比較まで出力される
Between23 <- data.frame(
  A = rep(1:2, each = 15),
  B = rep(rep(1:3, each = 5), 2),
  value = c(
    46, 44, 32, 40, 49, # a1・b1
    57, 54, 44, 56, 53, # a1・b2
    40, 24, 39, 25, 33, # a1・b3
    50, 34, 42, 30, 43, # a2・b1
    55, 44, 52, 63, 59, # a2・b2
    58, 55, 53, 61, 59 # a2・b3
  )
)
Between23$A <- factor(Between23$A, labels = c("a1", "a2"))
Between23$B <- factor(Between23$B, labels = c("b1", "b2", "b3"))

## 二要因群間計画(2×3)
anovakun(Between23, "ABs", 2, 3, eps = TRUE)

(42.2 + 52.8 + 32.2) / 3

# 5. 間2×間3の可視化 ---------------------------------------------------------------
# テキストの code 20.9〜20.11 と同じ書き方で，Between23 を図にする

## 棒グラフ(平均と標準誤差)
g_bar <- Between23 %>%
  group_by(A, B) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = B, y = mean, fill = A)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(0.9),
    width = 0.8
  ) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
    position = position_dodge(0.9), width = 0.25
  ) +
  labs(
    title = "要因Aと要因Bによる平均値の比較",
    x = "要因B",
    y = "平均値",
    fill = "要因A"
  ) +
  theme_bw()

## 箱ひげ図(個々のデータ点を重ねる)
g_box <- Between23 %>%
  ggplot(aes(x = B, y = value, fill = A)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(aes(color = A),
    position = position_jitterdodge(jitter.width = 0.2),
    size = 2
  ) +
  labs(
    title = "要因Aと要因Bによる測定値の分布",
    x = "要因B",
    y = "測定値",
    fill = "要因A",
    color = "要因A"
  ) +
  theme_bw()

## 折れ線グラフ(交互作用プロット)
g_int <- Between23 %>%
  group_by(A, B) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = B, y = mean, group = A, color = A)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.1) +
  labs(
    title = "要因Aと要因Bの交互作用",
    x = "要因B",
    y = "平均値",
    color = "要因A"
  ) +
  theme_bw()

g_bar
g_box
g_int

# 6. テキストの図として保存する ----------------------------------------------------------
# テキストの figures/20_anovakun/ にある3枚を上書きする(いまの図と同じ 8×6 インチ・300dpi)
# Rcode フォルダを作業ディレクトリにして実行すること
fig_dir <- "../figures/20_anovakun"
ggplot2::ggsave(file.path(fig_dir, "anova_barplot.png"), g_bar,
  width = 8, height = 6, dpi = 300, device = ragg::agg_png
)
ggplot2::ggsave(file.path(fig_dir, "anova_boxplot.png"), g_box,
  width = 8, height = 6, dpi = 300, device = ragg::agg_png
)
ggplot2::ggsave(file.path(fig_dir, "anova_interaction.png"), g_int,
  width = 8, height = 6, dpi = 300, device = ragg::agg_png
)

rm(list = ls())
source("https://bit.ly/3WL8VYR")
pacman::p_load(MASS, tidyverse)
# データフレームの作成
dat <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  m1_t1 = c(47, 60, 79, 54, 55, 84, 63, 41, 53, 57),
  m1_t2 = c(90, 71, 83, 41, 41, 103, 74, 34, 65, 53),
  m1_t3 = c(44, 63, 48, 39, 58, 20, 96, 62, 44, 83),
  m2_t1 = c(38, 39, 60, 49, 45, 62, 46, 28, 35, 40),
  m2_t2 = c(55, 49, 47, 63, 49, 58, 48, 30, 61, 47),
  m2_t3 = c(52, 59, 50, 63, 54, 56, 57, 64, 52, 72)
)

anovakun(dat[, -1], "sAB", 2, 3, eps = T, gg = T)

SimpleEffectA_at_b1 <- dat[, c(2, 5)]
anovakun(SimpleEffectA_at_b1, "sA", 2)

SimpleEffectB_at_a1 <- dat[, c(2, 3, 4)]
anovakun(SimpleEffectB_at_a1, "sA", 3)

# データを長形式に変換
dat_long <- dat %>%
  pivot_longer(
    cols = -id,
    names_to = "condition",
    values_to = "score"
  ) %>%
  separate(condition, into = c("method", "time"), sep = "_") %>%
  mutate(
    method = factor(method, levels = c("m1", "m2"), labels = c("方法1", "方法2")),
    time = factor(time, levels = c("t1", "t2", "t3"), labels = c("時点1", "時点2", "時点3"))
  )

# 各条件の平均値を計算
mean_data <- dat_long %>%
  group_by(method, time) %>%
  summarise(mean_score = mean(score), .groups = "drop")

# Color Blind対応のカラーパレット（グレースケール）
cb_palette <- c("#000000", "#999999")

# グラフ1: 時点別に方法を比較
g1 <- ggplot(mean_data, aes(x = time, y = mean_score, fill = method)) +
  geom_bar(
    stat = "identity", position = position_dodge(width = 0.9),
    color = "black", width = 0.8
  ) +
  scale_fill_manual(values = cb_palette) +
  labs(
    title = "各時点における学習方法別の平均得点",
    x = "時点",
    y = "平均得点",
    fill = "学習方法"
  ) +
  theme_minimal(base_family = "HiraKakuProN-W3") +
  theme(
    legend.position = "bottom",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  ylim(0, max(mean_data$mean_score) * 1.1)

print(g1)

# グラフ2: 方法別に時点を比較
g2 <- ggplot(mean_data, aes(x = method, y = mean_score, fill = time)) +
  geom_bar(
    stat = "identity", position = position_dodge(width = 0.9),
    color = "black", width = 0.8
  ) +
  scale_fill_grey(start = 0.3, end = 0.9) +
  labs(
    x = "学習方法",
    y = "平均得点",
    fill = "時点"
  ) +
  theme_minimal(base_family = "HiraKakuProN-W3") +
  theme(
    legend.position = "bottom",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  ylim(0, max(mean_data$mean_score) * 1.1)

print(g2)

# グラフ3: 交互作用プロット（線グラフ）
g3 <- ggplot(mean_data, aes(
  x = time, y = mean_score, group = method,
  color = method, shape = method
)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 4, fill = "white", stroke = 1.5) +
  scale_color_manual(values = cb_palette) +
  scale_shape_manual(values = c(21, 24)) +
  labs(
    x = "時点",
    y = "平均得点",
    color = "学習方法",
    shape = "学習方法"
  ) +
  theme_minimal(base_family = "HiraKakuProN-W3") +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

print(g3)

# グラフを保存
ggsave("../figures/22_Within_R/method_by_time_barplot.png",
  plot = g2, width = 8, height = 6, dpi = 300
)

ggsave("../figures/22_Within_R/interaction_plot.png",
  plot = g3, width = 8, height = 6, dpi = 300
)

# ========================================
# 群間×群内デザインへのデータ変換
# 要因A（方法）を群間要因として扱う
# ========================================

# 元のデータの前半5人をm1グループ、後半5人をm2グループとして扱う

# m1グループのデータ（被験者A-E）
dat_m1 <- data.frame(
  id = c("A", "B", "C", "D", "E"),
  group = rep("m1", 5),
  t1 = dat$m1_t1[1:5],
  t2 = dat$m1_t2[1:5],
  t3 = dat$m1_t3[1:5]
)

# m2グループのデータ（被験者F-J）
dat_m2 <- data.frame(
  id = c("F", "G", "H", "I", "J"),
  group = rep("m2", 5),
  t1 = dat$m2_t1[6:10],
  t2 = dat$m2_t2[6:10],
  t3 = dat$m2_t3[6:10]
)

# 2つのグループを結合
dat_between <- rbind(dat_m1, dat_m2)
print(dat_between)

# anovakun用のデータフレームに変換（idとgroupを除外）
dat_between_anova <- dat_between[, c("t1", "t2", "t3")]
print(dat_between_anova)

# 群間×群内デザインの分散分析
# "ABs": Aが群間、Bが群内、sが被験者
# A（方法）の水準数: 2、B（時点）の水準数: 3
anovakun(dat_between_anova, "ABs", 2, 3, gg = T)

rm(list = ls())
library(tidyverse)
MixedDesign <- data.frame(
  id = rep(1:4, 3),
  condition = rep(1:3, each = 4),
  stimuli1 = c(6, 6, 5, 5, 7, 4, 7, 6, 4, 3, 4, 6),
  stimuli2 = c(8, 3, 2, 5, 9, 7, 1, 6, 4, 9, 2, 3)
)
# 要因型にする
MixedDesign$condition <- factor(MixedDesign$condition,
  labels = c("control", "exp1", "exp2")
)

MixedDesign

MixedDesign_long <- MixedDesign %>%
  pivot_longer(
    cols = c(stimuli1, stimuli2),
    names_to = "stimuli",
    values_to = "value"
  )
print(MixedDesign_long)


# Bet2 --------------------------------------------------------------------

Between2 <- data.frame(
  temp = rep(1:2, each = 6),
  maker = rep(rep(1:2, each = 3), 2),
  value = c(13, 11, 12, 7, 6, 8, 9, 9, 9, 13, 11, 9)
)
Between2$temp <- factor(Between2$temp,
  labels = c("Hot", "Cold")
)
Between2$maker <- factor(Between2$maker,
  labels = c("A", "B")
)

source("https://bit.ly/3WL8VYR")

anovakun(Between2, "ABs", 2, 2, eps = T)





result.lm <- lm(value ~ temp * maker, data = Between2)
summary(result.lm)
anova(result.lm)

# ggplot2による可視化 -------------------------------------------------------

# 基本的な棒グラフ（平均値 + エラーバー）
Between2 %>%
  group_by(temp, maker) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = temp, y = mean, fill = maker)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(0.9),
    width = 0.8
  ) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
    position = position_dodge(0.9), width = 0.25
  ) +
  labs(
    title = "温度とメーカーによる評価値の比較",
    x = "温度条件",
    y = "評価値の平均",
    fill = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))


# 図を保存
ggsave("../figures/20_anovakun/anova_figures.png", plot = g1, width = 8, height = 6, dpi = 300)

# 交互作用を見やすくした折れ線グラフ
g2 <- Between2 %>%
  group_by(temp, maker) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = temp, y = mean, group = maker, color = maker)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.1) +
  labs(
    title = "温度とメーカーの交互作用",
    x = "温度条件",
    y = "評価値の平均",
    color = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))
print(g2)

# 個別データ点も含めた可視化
g3 <- Between2 %>%
  ggplot(aes(x = temp, y = value, fill = maker)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(aes(color = maker), position = position_jitterdodge(jitter.width = 0.2), size = 2) +
  labs(
    title = "温度とメーカーによる評価値の分布",
    x = "温度条件",
    y = "評価値",
    fill = "メーカー",
    color = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))
print(g3)
